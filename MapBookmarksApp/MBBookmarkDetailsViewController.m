//
//  MBBookmarkDetailsViewController.m
//  MapBookmarksApp
//
//  Created by Admin on 11.12.15.
//  Copyright © 2015 Admin. All rights reserved.
//

#import "MBBookmarkDetailsViewController.h"
#import "MBMainViewController.h"
#import "MBAlertViewHelper.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"

//IMPORTANT: Please, use your own credentials!
static NSString * const kClientID = @"LRU4HLR0BDWHB0WYNTRYMZ5EGQVL14FCZ1DA5UJXSQXSIKEG";
static NSString * const kClientSecret = @"NA0PL4VCTLXUSUC32A1ZNPUDXA33QYZKBO2HIMJV1ORJ0H0J";
static NSString * const kFoursquareApiDate = @"20151212";
static NSString * const kResponsesStyle = @"foursquare";
static NSString * const kGETPath = @"/v2/venues/search";

@interface MBBookmarkDetailsViewController ()

@property (strong, nonatomic) NSArray *nearbyPlacesNames;
@property (weak, nonatomic) NSTimer *timer;

- (void)loadNearbyPlacesFormFoursquare;
- (void)saveManagedContex;
- (void)startTimer;
- (void)stopTimer;
- (void)showProgressBar;

@end

@implementation MBBookmarkDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem setTitle:[self.chosenBookmark title]];
    if ([[self.chosenBookmark isNamed]boolValue] == NO) {
        [self activateUnnamedMode];
    } else {
        [self activateNamedMode];
    }
}

- (IBAction)loadNearbyPlaces:(id)sender {
    
    [self activateUnnamedMode];
}

- (void)activateNamedMode {
    
    [self.loadNearbyPlacesButton setHidden:NO];
    [self.tableView setHidden:YES];
}

- (void)activateUnnamedMode {
    
    [self.loadNearbyPlacesButton setHidden:YES];
    [self.tableView setHidden:NO];
    
    if([self.nearbyPlacesNames count] == 0) {
        
        [self loadNearbyPlacesFormFoursquare];
    }
}

- (void)startTimer {
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(showProgressBar) userInfo:nil repeats:NO];
}

- (void)stopTimer {
    
    [self.timer invalidate];
    self.timer = nil;
    [SVProgressHUD dismiss];
}

- (void)showProgressBar {
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading nearby places...", @"Loading nearby places status title")];

}

- (void)loadNearbyPlacesFormFoursquare {
    NSURL *baseURL = [NSURL URLWithString:@"https://api.foursquare.com"];
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc]initWithBaseURL:baseURL];
    sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    sessionManager.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
    CLLocationCoordinate2D coordinate = [self.chosenBookmark coordinate];
    
    NSString *locationParameter = [NSString stringWithFormat:@"%f,%f", coordinate.latitude, coordinate.longitude];
                                   
    NSDictionary *requestParameters = @{@"ll": locationParameter,
                                        @"client_id": kClientID,
                                        @"client_secret": kClientSecret,
                                        @"v": kFoursquareApiDate,
                                        @"m": kResponsesStyle
                                        
                                        };
    
    [sessionManager GET:kGETPath parameters:requestParameters progress:nil
                success:^(NSURLSessionDataTask *operation, id responseObject) {
                    
                    [self stopTimer];
                    if([responseObject isKindOfClass:[NSDictionary class]]) {
                        
                        NSArray *parsedNames;
                        parsedNames = [self exctractNearbyPlacesNamesFromJSONResponse:responseObject];
                        
                        if(parsedNames != nil) {
                            
                            self.nearbyPlacesNames = parsedNames;
                            [self.tableView reloadData];
                        }
                    } else {
                        
                        NSLog(@"Invalid JSON response...");
                    }
                }
     
                failure: ^(NSURLSessionDataTask *operation, NSError *error) {
                    
                    [SVProgressHUD dismiss];
                    NSLog(@"Failed to load nearby places from Foursquare servers. More Info: %@ %@", error, [error userInfo]);
                    [MBAlertViewHelper showAlertFromViewController:self withError:error];
                }];
}

- (NSArray *)exctractNearbyPlacesNamesFromJSONResponse:(NSDictionary *)JSONResponse {
    
    NSArray *parsedVenues = [JSONResponse valueForKeyPath:@"response.venues"];
    if(parsedVenues != nil) {
        NSArray *parsedNames = [parsedVenues valueForKey:@"name"];
        return parsedNames;
    }
    
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveManagedContex {
    NSError *error = nil;
    if ([self.managedObjectContex hasChanges] && ![self.managedObjectContex save:&error]) {
        // Handle the error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        [MBAlertViewHelper showAlertFromViewController:self withError:error];
    }
}

- (IBAction)buildRoute:(id)sender {

    MBMainViewController *mvc = [[self.navigationController viewControllers]firstObject];
    if(mvc.isInRoutingMode == NO) {
        mvc.routingEndPoint = self.chosenBookmark;
        [mvc activateRoutingMode];
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)centerInMapView:(id)sender {
    
    MBMainViewController *mvc = [[self.navigationController viewControllers]firstObject];
    CLLocationCoordinate2D coordinate = [self.chosenBookmark coordinate];
    
    [mvc zoomToLocation:coordinate WithSpanDistance:2000];
    [mvc.mainMapView selectAnnotation:self.chosenBookmark animated:YES];
    
    [self.navigationController popToRootViewControllerAnimated:YES];

}

- (IBAction)trashBookmark:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Warning", @"Warning alert title (confirmation for bookmark removing") message:NSLocalizedString(@"Do you really want to remove current bookmark?", @"Confirmation for bookmark removing alert message") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK alert button") style:UIAlertActionStyleDefault handler: ^(UIAlertAction *alertAction){
        
        [self.managedObjectContex deleteObject:self.chosenBookmark];
        [self.navigationController popViewControllerAnimated:YES];
    }];

    [alertController addAction:okAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"Cancel alert button") style:UIAlertActionStyleDefault handler: ^(UIAlertAction *alertAction){
        
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.nearbyPlacesNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MBNearbyPlacesCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.nearbyPlacesNames objectAtIndex:indexPath.row];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UITableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"MBNearbyPlacesHeaderCell"];
    headerCell.textLabel.text = NSLocalizedString(@"Nearby Places List:", @"Nearby Places Table Header");
    [[headerCell textLabel]setTextColor:[UIColor brownColor]];
    [[headerCell textLabel]setFont:[UIFont systemFontOfSize:20.0f]];
    
    return headerCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.chosenBookmark setTitle:[self.nearbyPlacesNames objectAtIndex:indexPath.row]];
    [self.chosenBookmark setIsNamed:[NSNumber numberWithBool:YES]];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationItem setTitle:[self.chosenBookmark title]];
    [self activateNamedMode];
    
    [self saveManagedContex];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 70.0f;
}

@end
