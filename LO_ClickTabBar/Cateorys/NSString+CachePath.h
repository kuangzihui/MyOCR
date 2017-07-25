//
//  NSString+CachePath.h
//  LO_TabBar
//
//  Created by ejt_ios on 17/5/5.
//  Copyright © 2017年 ejt_ios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CachePath)

- (NSString *) cacheWithPath;
- (BOOL) isEmpty;
- (BOOL) isNotEmpty;
- (NSString *)trim;
@end
