//
//  MBCurrentLocationAnnotationView.m
//  MapBookmarksApp
//
//  Created by Admin on 10.12.15.
//  Copyright © 2015 Admin. All rights reserved.
//

#import "MBCurrentLocationAnnotationView.h"

@implementation MBCurrentLocationAnnotationView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        CGRect viewRect = CGRectMake(-20, -20, 40, 40);
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:viewRect];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView = imageView;
        [self addSubview: self.imageView];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

@end
