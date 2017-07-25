//
//  PhotoModel.m
//  LO_ClickTabBar
//
//  Created by ejt_ios on 2017/6/22.
//  Copyright © 2017年 ejt_ios. All rights reserved.
//

#import "PhotoModel.h"

@implementation PhotoModel

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_photoImg forKey:@"_photoImg"];
    [aCoder encodeObject:_photoName forKey:@"_photoName"];
    [aCoder encodeObject:_photoDate forKey:@"_photoDate"];
    [aCoder encodeBool:_isSelect forKey:@"_isSelect"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
       _photoImg = [aDecoder decodeObjectForKey:@"_photoImg"];
        _photoName = [aDecoder decodeObjectForKey:@"_photoName"];
       _photoDate = [aDecoder decodeObjectForKey:@"_photoDate"];
        _isSelect = [aDecoder decodeBoolForKey:@"_isSelect"];
    }
    return self;
}

@end
