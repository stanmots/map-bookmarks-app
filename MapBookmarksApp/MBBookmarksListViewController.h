//
//  MBBookmarksListViewControllerTableViewController.h
//  MapBookmarksApp
//
//  Created by Admin on 11.12.15.
//  Copyright © 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MBManagedObjectFetching.h"

@interface MBBookmarksListViewController : UITableViewController <MBManagedObjectFetching>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContex;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
