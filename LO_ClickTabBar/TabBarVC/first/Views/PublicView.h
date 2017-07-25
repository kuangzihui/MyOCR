//
//  PublicView.h
//  微企
//
//  Created by ejt_ios on 16/6/3.
//  Copyright © 2016年 WJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PublicView : UIView

@property (nonatomic , strong) UIButton *btn1;
@property (nonatomic , strong) UIButton *btn2;

- (void) showPublicView;
- (void) hiddenPublicView;
@end
