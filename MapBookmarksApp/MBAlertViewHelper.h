//
//  MBAlertViewHelper.h
//  MapBookmarksApp
//
//  Created by Admin on 10.12.15.
//  Copyright © 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface MBAlertViewHelper : NSObject

+(void)showAlertFromViewController:(UIViewController *)viewController withError:(NSError *)error;
+(void)showAlertFromViewController:(UIViewController *)viewController withTitle:(NSString *)title andMessage:(NSString *)message;

@end
