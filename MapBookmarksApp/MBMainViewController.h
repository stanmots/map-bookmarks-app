//
//  ViewController.h
//  MapBookmarksApp
//
//  Created by Admin on 09.12.15.
//  Copyright © 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "Bookmark+CoreDataProperties.h"

@interface MBMainViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, NSFetchedResultsControllerDelegate, UIPopoverPresentationControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mainMapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *routingModeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *bookmarksButton;

@property (readonly, strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContex;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) UITableView *sharedTableView;
@property (strong, nonatomic) Bookmark *routingEndPoint;
@property (nonatomic) BOOL isInRoutingMode;

- (BOOL)compareCoordinate:(CLLocationCoordinate2D)startCoordinate withCoordinate:(CLLocationCoordinate2D)endCoordinate;
- (void)saveManagedContext;
- (void)zoomToLocation:(CLLocationCoordinate2D)coordinate WithSpanDistance:(CLLocationDistance) distance;
- (void)handleChangedAuthorizationStatus:(CLAuthorizationStatus)authorizationStatus;
- (void)zoomToCurrentLocation;
- (void)authorizeLocationServices;
- (void)synchronizeMapViewWithPersistentStore;
- (void)showRouteFromCurrentLocationToChosenPoint;
- (void)handleTapOnCalloutDisclosure:(UIGestureRecognizer *)gestureRecognizer;

- (IBAction)handleLongTapOnMapView:(UIGestureRecognizer *)gestureRecognizer;
- (IBAction)handleExitFromPopover:(UIStoryboardSegue *)sender;
- (void)activateRoutingMode;
- (void)deactivateRoutingMode;
- (void)hideNotInRouteAnnotations;
- (void)showAllAnnotations;

@end

