//
//  Bookmark.h
//  MapBookmarksApp
//
//  Created by Admin on 10.12.15.
//  Copyright © 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Bookmark : NSManagedObject <MKAnnotation>

// Insert code here to declare functionality of your managed object subclass
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;

+ (NSString *)entityName;
+ (NSString *)bookmarksTitlePropertyName;
+ (NSString *)bookmarksLocationPropertyName;
+ (NSString *)bookmarksCreationDatePropertyName;

@end

NS_ASSUME_NONNULL_END

#import "Bookmark+CoreDataProperties.h"
