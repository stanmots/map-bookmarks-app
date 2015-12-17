//
//  Bookmark.m
//  MapBookmarksApp
//
//  Created by Admin on 10.12.15.
//  Copyright © 2015 Admin. All rights reserved.
//

#import "Bookmark.h"

@implementation Bookmark

@synthesize title = _title;
@synthesize coordinate = _coordinate;

// Insert code here to add functionality to your managed object subclass
+ (NSString *)entityName {
    return NSStringFromClass(self);
}

+ (NSString *)bookmarksTitlePropertyName {
    return NSStringFromSelector(@selector(bookmarkTitle));
}

+ (NSString *)bookmarksLocationPropertyName {
    return NSStringFromSelector(@selector(bookmarkLocation));
}

+ (NSString *)bookmarksCreationDatePropertyName {
    return NSStringFromSelector(@selector(creationDate));
}

- (NSString *)title {
    return self.bookmarkTitle;
}

- (void)setTitle:(NSString *)title {
    [self willChangeValueForKey:@"title"];
    self.bookmarkTitle = [title copy];
    [self didChangeValueForKey:@"title"];
}
- (CLLocationCoordinate2D)coordinate {
    CLLocation *location = (CLLocation *)self.bookmarkLocation;
    return location.coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate {
    [self willChangeValueForKey:@"coordinate"];
    self.coordinate = coordinate;
    [self didChangeValueForKey:@"coordinate"];
}

- (void)awakeFromInsert {
    
    [super awakeFromInsert];
    [self setValue:[NSDate date] forKey:@"creationDate"];
}

@end
