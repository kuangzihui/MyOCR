//
//  UIFont+size.m
//  LO_ClickTabBar
//
//  Created by ejt_ios on 2017/6/21.
//  Copyright © 2017年 ejt_ios. All rights reserved.
//

#import "UIFont+size.h"

@implementation UIFont (size)

+ (UIFont *) fontWithIntegerOption:(CGFloat) fontType
{
    return [UIFont systemFontOfSize:fontType];
}

@end
