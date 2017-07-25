//
//  LOUserLoginView.h
//  LO_ClickTabBar
//
//  Created by ejt_ios on 2017/6/19.
//  Copyright © 2017年 ejt_ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LOUserLoginView : UIView

+ (instancetype) loadLoginView;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UITextField *userText;

@property (weak, nonatomic) IBOutlet UITextField *passText;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadView;
@end
