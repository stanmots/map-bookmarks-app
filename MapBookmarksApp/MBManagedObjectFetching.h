//
//  MBManagedObjectFetching.h
//  MapBookmarksApp
//
//  Created by Admin on 13.12.15.
//  Copyright © 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSFetchedResultsController;

@protocol MBManagedObjectFetching <NSObject>

@required
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContex;

@end
