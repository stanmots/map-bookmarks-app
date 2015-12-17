//
//  ViewController.m
//  MapBookmarksApp
//
//  Created by Admin on 09.12.15.
//  Copyright © 2015 Admin. All rights reserved.
//

#import "MBMainViewController.h"
#import "MBAlertViewHelper.h"
#import "MBFetchedControllerHelper.h"
#import "MBCurrentLocationAnnotationView.h"
#import "Bookmark+CoreDataProperties.h"
#import "MBBookmarksListViewController.h"
#import "MBBookmarkDetailsViewController.h"
#import "MBBookmarksPopoverTableViewController.h"
#import "SVProgressHUD.h"

typedef NS_ENUM(NSUInteger, MBCoreLocationErrorCodes) {
    kCoreLocationErrorFailedToAuthorize = 200
};

static const CLLocationDistance kSpanDistanceInMeters = 2000;
static const float kCLCoordinatesEpsilon = 0.0005f;
static const float kPopoverWidthScaleFactor = 0.8f;
static const float kPopoverHeigthScaleFactor = 0.5f;

static NSString * const kToBookmarksListSegueID = @"ToBookmarksListSegue";
static NSString * const kToBookmarkDetailSegueID = @"ToBookmarkDetailSegue";
static NSString * const kToBookmarksPopoverSegueID = @"ToBookmarksPopoverSegue";


@interface MBMainViewController ()

@end

@implementation MBMainViewController

@synthesize locationManager = _locationManager;
@synthesize mainMapView = _mainMapView;
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.mainMapView setDelegate:self];

    [self authorizeLocationServices];
    [self synchronizeMapViewWithPersistentStore];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    [self deactivateRoutingMode];
    id<MBManagedObjectFetching> destinationController = [segue destinationViewController];
    destinationController.fetchedResultsController = self.fetchedResultsController;
    destinationController.managedObjectContex = self.managedObjectContex;
    
    NSString *segueId = [segue identifier];
    if([segueId isEqualToString:kToBookmarksPopoverSegueID]) {
        
        UIPopoverPresentationController *popoverPresentationController = [(MBBookmarksPopoverTableViewController *)destinationController popoverPresentationController];
        popoverPresentationController.delegate = self;
        CGRect mainScreenBounds = [[UIScreen mainScreen]bounds];
        [(MBBookmarksPopoverTableViewController*)destinationController setPreferredContentSize: CGSizeMake(mainScreenBounds.size.width * kPopoverWidthScaleFactor, mainScreenBounds.size.height * kPopoverHeigthScaleFactor)];
    } else if( [segueId isEqualToString:kToBookmarkDetailSegueID]) {
        
        [(MBBookmarkDetailsViewController *)destinationController setChosenBookmark:[[self.mainMapView selectedAnnotations]lastObject]];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if([[self.fetchedResultsController fetchedObjects]count] == 0) {
        [MBAlertViewHelper showAlertFromViewController:self withTitle:NSLocalizedString(@"Warning!", @"Warning alert (no bookmarks) title") andMessage:NSLocalizedString(@"You must create at least one bookmark before proceeding further!", @"Warting alert (no bookmarks) message")];
        return NO;
    } else if([identifier isEqualToString:kToBookmarksPopoverSegueID] == YES &&
              self.isInRoutingMode == YES) {
        
        [self deactivateRoutingMode];
        return NO;
    }
    
    return YES;
}

- (IBAction)handleExitFromPopover:(UIStoryboardSegue *)sender {

    [self activateRoutingMode];
}

- (void)activateRoutingMode {
    
    self.isInRoutingMode = YES;
    [self.bookmarksButton setEnabled:NO];
    [self.routingModeButton setTitle:NSLocalizedString(@"Clear route", @"Switched route mode button title")];
    [self hideNotInRouteAnnotations];
    [self showRouteFromCurrentLocationToChosenPoint];
}

- (void)deactivateRoutingMode {
    
    self.isInRoutingMode = NO;
    [self.bookmarksButton setEnabled:YES];
    [self.routingModeButton setTitle:NSLocalizedString(@"Route", @"Default route mode button title")];
    [self showAllAnnotations];
    [self.mainMapView removeOverlays:[self.mainMapView overlays]];
    [self zoomToCurrentLocation];
}

- (void)hideNotInRouteAnnotations {
    
    for(id<MKAnnotation> annotation in [self.mainMapView annotations]) {
        
        if([annotation isKindOfClass:[MKUserLocation class]] == NO &&
           [self compareCoordinate:annotation.coordinate withCoordinate:[self.routingEndPoint coordinate]] == NO) {
            
            MKAnnotationView *annotationView = [self.mainMapView viewForAnnotation:annotation];
            if(annotationView != nil) {
                annotationView.hidden = YES;
            }
        }
    }
}

- (void)showAllAnnotations {
    
    for(id<MKAnnotation> annotation in [self.mainMapView annotations]) {
        
        MKAnnotationView *annotationView = [self.mainMapView viewForAnnotation:annotation];
        if(annotationView != nil) {
            annotationView.hidden = NO;
        }
        
    }
}

- (void)showRouteFromCurrentLocationToChosenPoint {
    
    [self zoomToCurrentLocation];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
    request.source = [MKMapItem mapItemForCurrentLocation];
    
    MKPlacemark *endPointPlacemark = [[MKPlacemark alloc]initWithCoordinate:self.routingEndPoint.coordinate addressDictionary:nil];
    MKMapItem *endPointMapItem = [[MKMapItem alloc]initWithPlacemark:endPointPlacemark];
    
    request.destination = endPointMapItem;
    request.requestsAlternateRoutes = NO;
    
    MKDirections *directions = [[MKDirections alloc]initWithRequest:request];
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Calculating route...", @"Calculating route status title")];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        
        [SVProgressHUD dismiss];
        
        if(error) {
            
            NSLog(@"Failed to get routing directions. More info: %@, %@", error, [error userInfo]);
            [self deactivateRoutingMode];
            [MBAlertViewHelper showAlertFromViewController:self withError:error];
            
        } else {
            MKRoute *route = [response.routes lastObject];
            [self.mainMapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        }
    }];
}

- (BOOL)compareCoordinate:(CLLocationCoordinate2D)startCoordinate withCoordinate:(CLLocationCoordinate2D)endCoordinate {
    
    return fabs(startCoordinate.latitude - endCoordinate.latitude) <= kCLCoordinatesEpsilon &&
    fabs(startCoordinate.longitude - endCoordinate.longitude) <= kCLCoordinatesEpsilon;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)synchronizeMapViewWithPersistentStore {
    
    //clear map view
    [self.mainMapView removeAnnotations:[self.mainMapView annotations]];
    
    NSError *error = nil;
    if(![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Failed to perform fetch with error %@%@", error, [error userInfo]);
        [MBAlertViewHelper showAlertFromViewController:self withError:error];
    } else {
        [self.mainMapView addAnnotations:[self.fetchedResultsController fetchedObjects]];
    }
}

- (void)saveManagedContext {
    
    NSError *error = nil;
    if ([self.managedObjectContex hasChanges] && ![self.managedObjectContex save:&error]) {
        // Handle the error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        [MBAlertViewHelper showAlertFromViewController:self withError:error];
    }
}

- (NSFetchedResultsController *)fetchedResultsController {
    if(_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
        
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    options[MBEntityNameKey] = [Bookmark entityName];
    options[MBFirstDescriptorKey] = [Bookmark bookmarksCreationDatePropertyName];
    options[MBCacheNameKey] = @"MainMapViewCache";
    
    _fetchedResultsController = [MBFetchedControllerHelper createFetchedControllerInContex:self.managedObjectContex withUserOptions:options];
    
    if(_fetchedResultsController != nil) {
        _fetchedResultsController.delegate = self;
    }
    return _fetchedResultsController;
}

- (void)zoomToLocation:(CLLocationCoordinate2D)coordinate WithSpanDistance:(CLLocationDistance)distance {
    MKCoordinateRegion currentRegion = MKCoordinateRegionMakeWithDistance(coordinate, distance, distance);
    
    //[self.mainMapView setCenterCoordinate:coordinate];
    [self.mainMapView setRegion:currentRegion animated:YES];
    [self.mainMapView regionThatFits:currentRegion];
}

- (void)zoomToCurrentLocation {
    
    //go to current user's location
    MKUserLocation *userLocation = self.mainMapView.userLocation;
    [self zoomToLocation:userLocation.location.coordinate WithSpanDistance:kSpanDistanceInMeters];
}

- (void)authorizeLocationServices {
    
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    [self handleChangedAuthorizationStatus:authorizationStatus];
}

- (IBAction)handleLongTapOnMapView:(UIGestureRecognizer *)gestureRecognizer {

    //cancel continuous states
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    //get selected coordinates
    CGPoint longTapPoint = [gestureRecognizer locationInView:self.mainMapView];
    CLLocationCoordinate2D selectedPointInMap = [self.mainMapView convertPoint:longTapPoint toCoordinateFromView:self.mainMapView];
    
    //check if there are annotations on the same coordinates
    NSSet<id<MKAnnotation>> *visibleAnnotationsWithSameCoordinates = [[self.mainMapView annotationsInMapRect:[self.mainMapView visibleMapRect]]objectsPassingTest: ^ BOOL(id<MKAnnotation> currentVisibleAnnotation, BOOL *stop) {
        
        return [self compareCoordinate:selectedPointInMap withCoordinate:currentVisibleAnnotation.coordinate];
    }];
    
    if (visibleAnnotationsWithSameCoordinates.count == 0) {
        
        //create new record in persistent store for selected point in map
        NSEntityDescription *entity = [NSEntityDescription entityForName:[Bookmark entityName] inManagedObjectContext:self.managedObjectContex];
        Bookmark *record = [[Bookmark alloc]initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContex];
        
        [record setValue:NSLocalizedString(@"Unnamed", @"Default bookmarks' title.") forKey:[Bookmark bookmarksTitlePropertyName]];
        
        CLLocation *location = [[CLLocation alloc]initWithLatitude:selectedPointInMap.latitude longitude:selectedPointInMap.longitude];
        [record setValue:location forKey:[Bookmark bookmarksLocationPropertyName]];
        record.isNamed = [NSNumber numberWithBool:NO];
        
        [self saveManagedContext];
    }
}

- (void)handleTapOnCalloutDisclosure:(UIGestureRecognizer *)gestureRecognizer {
    
    @try {
        [self performSegueWithIdentifier:kToBookmarkDetailSegueID sender:self];
    }
    @catch (NSException *exception) {
        
        NSLog(@"Failed to perform segue with identifier %@. More Info: %@", NSStringFromClass([MBBookmarkDetailsViewController class]), exception);
    }
}

- (void)handleChangedAuthorizationStatus:(CLAuthorizationStatus)authorizationStatus {
    
    switch (authorizationStatus) {
        case kCLAuthorizationStatusNotDetermined: {
            
            if(self.locationManager == nil) {
                _locationManager = [[CLLocationManager alloc]init];
                [self.locationManager setDelegate:self];
                if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                    [self.locationManager requestWhenInUseAuthorization];
                }
            }

            break;
        }
            
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse: {

            [self.mainMapView setShowsUserLocation:YES];
            [self zoomToCurrentLocation];
            
            break;
        }
            
        default: {
            
            [self.mainMapView setShowsUserLocation:NO];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[NSLocalizedDescriptionKey] = @"Cannot get the locations!";
            dict[NSLocalizedFailureReasonErrorKey] = @"Failed to authorize the location services!";
            NSError *error;
            error = [NSError errorWithDomain:@"com.admin.mapbookmarksapp" code:kCoreLocationErrorFailedToAuthorize  userInfo:dict];
            if(self.presentedViewController == nil) {
                [MBAlertViewHelper showAlertFromViewController:self withError:error];
            }
            
            break;
        }
    }
}

#pragma mark - NSFetchedResultsController delegate methods
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {

    switch (type) {
        case NSFetchedResultsChangeInsert: {
            
            [self.mainMapView addAnnotation:anObject];
            
            if(self.sharedTableView != nil) {
                [self.sharedTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            break;
        }
        case NSFetchedResultsChangeDelete: {
            
            [self.mainMapView removeAnnotation:anObject];
            
            if(self.sharedTableView != nil) {
                [self.sharedTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            break;
        }
            
        case NSFetchedResultsChangeUpdate: {
            [self.sharedTableView reloadData];
            break;
        }
        
        //Due to the bug in iOS 9 SDK we can't handle the following case
        //You can check discussion of this issue here:https://forums.developer.apple.com/thread/4999
            
        case NSFetchedResultsChangeMove: {
            break;
        }
        default:
            break;
    }
}
#pragma mark - Popover delegate methods
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    
    return UIModalPresentationNone;
}

- (void)prepareForPopoverPresentation:(UIPopoverPresentationController *)popoverPresentationController {
    
    [self.bookmarksButton setEnabled:NO];
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    
    [self.bookmarksButton setEnabled: YES];
}

#pragma mark - MKMapView delegate methods
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    if(self.isInRoutingMode == NO) {
        
        [self zoomToLocation:userLocation.location.coordinate WithSpanDistance:kSpanDistanceInMeters];
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    MKPolylineRenderer *polylineRenderer = [[MKPolylineRenderer alloc]initWithOverlay:overlay];
    polylineRenderer.strokeColor = [UIColor greenColor];
    polylineRenderer.lineWidth = 4.0f;
    
    return polylineRenderer;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    static NSString *bookmarksAnnotationIdentifier = @"BookmarkAnnotationReusable";

    if([annotation isKindOfClass:[MKUserLocation class]]) {
        MBCurrentLocationAnnotationView *currentLocationView = [[MBCurrentLocationAnnotationView alloc]initWithAnnotation:annotation  reuseIdentifier:nil];
        UIImage *currentLocationArrow = [UIImage imageNamed:@"UserLocation_DarkGreenArrow"];
        currentLocationView.image = currentLocationArrow;
        currentLocationView.canShowCallout = YES;

        return currentLocationView;
    }
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:bookmarksAnnotationIdentifier];
    if(annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation  reuseIdentifier:bookmarksAnnotationIdentifier];
        //annotationView.pinTintColor = [MKPinAnnotationView redPinColor];
        annotationView.animatesDrop = YES;
        annotationView.canShowCallout = YES;
    
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom
                                 ];
        rightButton.frame = CGRectMake(0, 0, 25, 25);
        UITableViewCell *disclosure = [[UITableViewCell alloc]init];
        disclosure.frame = CGRectMake(0, 0, 25, 25);
        disclosure.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapOnCalloutDisclosure:)];
        tapRecognizer.numberOfTapsRequired = 1;
        tapRecognizer.numberOfTouchesRequired = 1;
        [disclosure addGestureRecognizer:tapRecognizer];
        [rightButton addSubview:disclosure];
        annotationView.rightCalloutAccessoryView = rightButton;
        
    } else {
        annotationView.annotation = annotation;
    }
    
    return annotationView;
}

#pragma mark - CLLocationManager delegate methods
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    [self handleChangedAuthorizationStatus:status];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"Location Manager failed with error %@, %@", error, [error userInfo]);
}

@end
