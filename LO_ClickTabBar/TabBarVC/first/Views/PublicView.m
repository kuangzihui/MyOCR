//
//  PublicView.m
//  微企
//
//  Created by ejt_ios on 16/6/3.
//  Copyright © 2016年 WJ. All rights reserved.
//

#import "PublicView.h"

@implementation PublicView



- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.backgroundColor = [UIColor blackColor];
        backBtn.alpha = 0.5;
        [backBtn addTarget:self action:@selector(hiddenPublicView) forControlEvents:UIControlEventTouchUpInside];
        backBtn.tag = 121;
        backBtn.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.alpha = 0.0f;
        [self addSubview:backBtn];
        
        UIView *btnBackView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-280)/2, (SCREEN_HEIGHT-150)/2, 280, 150)];
        btnBackView.backgroundColor = [UIColor whiteColor];
        btnBackView.layer.cornerRadius = 3.0f;
        btnBackView.layer.masksToBounds = YES;
        btnBackView.clipsToBounds = YES;
        [self addSubview:btnBackView];
        
        _btn1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 140, 150)];
        _btn1.backgroundColor = [UIColor clearColor];
        _btn1.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _btn1.layer.borderWidth = 0.5;
        _btn1.tag = 50;
        [_btn1 setTitle:@"我的图库" forState:UIControlStateNormal];
        _btn1.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [_btn1 setTitleColor:THEME_COLOR forState:UIControlStateNormal];
        [btnBackView addSubview:_btn1];
        
        
        _btn2 = [[UIButton alloc] initWithFrame:CGRectMake(140, 0, 140, 150)];
        _btn2.backgroundColor = [UIColor clearColor];
        _btn2.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _btn2.layer.borderWidth = 0.5;
        _btn2.tag = 51;
        _btn2.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [_btn2 setTitle:@"我的相册" forState:UIControlStateNormal];
        [_btn2 setTitleColor:THEME_COLOR forState:UIControlStateNormal];
        
        [btnBackView addSubview:_btn2];
        
    }
    return self;
}

- (void) hiddenPublicView
{
    __weak PublicView *bSef = self;
    [UIView animateWithDuration:0.3 animations:^{
        bSef.alpha = 0.0f;
    }];
}

- (void) showPublicView
{
    __weak PublicView *bSef = self;
    [UIView animateWithDuration:0.3 animations:^{
        bSef.alpha = 1.0f;
    }];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
