//
//  MBAlertViewHelper.m
//  MapBookmarksApp
//
//  Created by Admin on 10.12.15.
//  Copyright © 2015 Admin. All rights reserved.
//

#import "MBAlertViewHelper.h"

@implementation MBAlertViewHelper

+ (void)showAlertFromViewController:(UIViewController *)viewController withError:(NSError *)error {
    
    if(!viewController || !error) {
        NSLog(@"Failed to initialize Alert View...");
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[error localizedDescription] message:[error localizedFailureReason] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:defaultAction];
    [viewController presentViewController:alertController animated:YES completion:nil];
}

+ (void)showAlertFromViewController:(UIViewController *)viewController withTitle:(NSString *)title andMessage:(NSString *)message {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:defaultAction];
    [viewController presentViewController:alertController animated:YES completion:nil];
}

@end
