//
//  LOTabBar.h
//  LO_ClickTabBar
//
//  Created by ejt_ios on 2017/6/5.
//  Copyright © 2017年 ejt_ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LOTabBarDelegate <NSObject>

@required
- (void) centerButtonClick;

@end

@interface LOTabBar : UITabBar

@property (nonatomic , assign) id<LOTabBarDelegate> loBarDelegate;
@property (nonatomic , strong) UIButton *centerPlusBtn;

- (void) updateFrame;
@end
