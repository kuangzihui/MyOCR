//
//  UIColor+LOColor.m
//  LO_ClickTabBar
//
//  Created by ejt_ios on 2017/6/19.
//  Copyright © 2017年 ejt_ios. All rights reserved.
//

#import "UIColor+LOColor.h"

@implementation UIColor (LOColor)

+ (UIImage *) colorRepImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

@end
