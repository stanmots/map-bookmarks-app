//
//  MBBookmarksPopoverTableViewController.h
//  MapBookmarksApp
//
//  Created by Admin on 12.12.15.
//  Copyright © 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MBManagedObjectFetching.h"

@interface MBBookmarksPopoverTableViewController : UITableViewController <MBManagedObjectFetching>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContex;

@end
