//
//  PhotoModel.h
//  LO_ClickTabBar
//
//  Created by ejt_ios on 2017/6/22.
//  Copyright © 2017年 ejt_ios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoModel : NSObject<NSCoding>

@property (nonatomic , strong) UIImage *photoImg;
@property (nonatomic , strong) NSString *photoDate;
@property (nonatomic , strong) NSString *photoName;
@property (nonatomic , assign) BOOL isSelect;

@end
