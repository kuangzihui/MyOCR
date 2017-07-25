//
//  UIViewController+Helper.m
//  LO_ClickTabBar
//
//  Created by ejt_ios on 2017/6/19.
//  Copyright © 2017年 ejt_ios. All rights reserved.
//

#import "UIViewController+Helper.h"

@implementation UIViewController (Helper)

@dynamic appDelegate;

- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

@end
