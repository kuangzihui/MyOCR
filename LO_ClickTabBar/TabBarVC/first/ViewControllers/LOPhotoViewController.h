//
//  LOPhotoViewController.h
//  LO_ClickTabBar
//
//  Created by ejt_ios on 2017/6/19.
//  Copyright © 2017年 ejt_ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LOPhotoViewController : UIViewController

@property (nonatomic , strong) NSString *fileName;

- (instancetype)initWithFileName:(NSString *) file_name;

@end
