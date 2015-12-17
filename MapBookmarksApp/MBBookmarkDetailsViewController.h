//
//  MBBookmarkDetailsViewController.h
//  MapBookmarksApp
//
//  Created by Admin on 11.12.15.
//  Copyright © 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBManagedObjectFetching.h"
#import "Bookmark+CoreDataProperties.h"

@interface MBBookmarkDetailsViewController : UIViewController <MBManagedObjectFetching, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContex;
@property (strong, nonatomic) Bookmark *chosenBookmark;
@property (strong, nonatomic) NSIndexPath *currentIndexPath;
@property (weak, nonatomic) IBOutlet UIButton *loadNearbyPlacesButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


- (IBAction)trashBookmark:(id)sender;
- (IBAction)buildRoute:(id)sender;
- (IBAction)centerInMapView:(id)sender;
- (IBAction)loadNearbyPlaces:(id)sender;

- (void)activateUnnamedMode;
- (void)activateNamedMode;

- (NSArray *)exctractNearbyPlacesNamesFromJSONResponse:(NSDictionary *)JSONResponse;

@end
