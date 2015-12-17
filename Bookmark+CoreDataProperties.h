//
//  Bookmark+CoreDataProperties.h
//  
//
//  Created by Admin on 17.12.15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Bookmark.h"

NS_ASSUME_NONNULL_BEGIN

@interface Bookmark (CoreDataProperties)

@property (nullable, nonatomic, retain) id bookmarkLocation;
@property (nullable, nonatomic, retain) NSString *bookmarkTitle;
@property (nullable, nonatomic, retain) NSNumber *isNamed;
@property (nullable, nonatomic, retain) NSDate *creationDate;

@end

NS_ASSUME_NONNULL_END
