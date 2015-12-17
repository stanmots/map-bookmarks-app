//
//  MBFetchedControllerHelper.h
//  MapBookmarksApp
//
//  Created by Admin on 11.12.15.
//  Copyright © 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

//required
extern NSString * const MBEntityNameKey;
extern NSString * const MBFirstDescriptorKey;

//optional
extern NSString * const MBCacheNameKey;

@interface MBFetchedControllerHelper : NSObject

+ (NSFetchedResultsController *)createFetchedControllerInContex:(NSManagedObjectContext *)contex withUserOptions:(NSDictionary *)options;

@end
