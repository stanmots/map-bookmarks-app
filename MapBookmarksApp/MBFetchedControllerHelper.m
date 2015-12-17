//
//  MBFetchedControllerHelper.m
//  MapBookmarksApp
//
//  Created by Admin on 11.12.15.
//  Copyright © 2015 Admin. All rights reserved.
//

#import "MBFetchedControllerHelper.h"

NSString * const MBEntityNameKey = @"EntityNameKey";
NSString * const MBFirstDescriptorKey = @"FirstDescriptorKey";
NSString * const MBCacheNameKey = @"CacheNameKey";

@implementation MBFetchedControllerHelper

+ (NSFetchedResultsController *)createFetchedControllerInContex:(NSManagedObjectContext *)contex withUserOptions:(NSDictionary *)options {
    
    if(![options objectForKey:MBEntityNameKey] || ![options objectForKey:MBFirstDescriptorKey]) {
        NSLog(@"Failed to create NSFetchedResultsController in method %@ (File Name %s) due to the wrong options keys.", NSStringFromSelector(_cmd), __FILE__);
        return nil;
    }
    
    //cache might be nil
    NSString *chosenCacheName = [options objectForKey:MBCacheNameKey];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[options objectForKey:MBEntityNameKey] inManagedObjectContext:contex];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc]initWithKey:[options objectForKey:MBFirstDescriptorKey] ascending:YES];
    
    [fetchRequest setSortDescriptors:@[firstDescriptor]];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:contex sectionNameKeyPath:nil cacheName:chosenCacheName];
    
    return frc;
}

@end
