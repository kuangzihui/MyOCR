//
//  NSString+CachePath.m
//  LO_TabBar
//
//  Created by ejt_ios on 17/5/5.
//  Copyright © 2017年 ejt_ios. All rights reserved.
//

#import "NSString+CachePath.h"

@implementation NSString (CachePath)

- (NSString *)cacheWithPath
{
    NSString *docUrl = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    return [docUrl stringByAppendingPathComponent:self];
}

- (BOOL)isEmpty
{
    BOOL res = NO;
    if (self == nil || [@"" isEqualToString:self]) {
        res = YES;
    }
    return res;
}

- (BOOL)isNotEmpty
{
     return ![self isEmpty];
}

- (NSString *)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
@end
