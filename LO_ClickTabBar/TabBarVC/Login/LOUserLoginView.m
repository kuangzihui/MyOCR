//
//  LOUserLoginView.m
//  LO_ClickTabBar
//
//  Created by ejt_ios on 2017/6/19.
//  Copyright © 2017年 ejt_ios. All rights reserved.
//

#import "LOUserLoginView.h"
#import "UIColor+LOColor.h"

@implementation LOUserLoginView

+ (instancetype)loadLoginView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"LOUserLoginView" owner:self options:nil] lastObject];
}

- (void)awakeFromNib
{
    
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    _loadView.hidden = YES;
    [_loginBtn setBackgroundImage:[UIColor colorRepImageWithColor:[UIColor colorWithRed:20/255.0f green:150/255.0f blue:220/255.0f alpha:0.8]] forState:UIControlStateNormal];
    [_loginBtn setBackgroundImage:[UIColor colorRepImageWithColor:[UIColor colorWithRed:20/255.0f green:150/255.0f blue:220/255.0f alpha:0.7]] forState:UIControlStateSelected];
    [_loginBtn setBackgroundImage:[UIColor colorRepImageWithColor:[UIColor colorWithRed:20/255.0f green:150/255.0f blue:220/255.0f alpha:0.7]] forState:UIControlStateHighlighted];
    _loginBtn.layer.cornerRadius = 5;
    _loginBtn.layer.masksToBounds = YES;
    
    // 修改usertext place的颜色
    [_userText setValue:RGBA(235, 235, 235, 0.8) forKeyPath:@"_placeholderLabel.textColor"];
    [_passText setValue:RGBA(235, 235, 235, 0.8) forKeyPath:@"_placeholderLabel.textColor"];
    _passText.secureTextEntry = YES;
    [super awakeFromNib];
}

- (IBAction)login:(id)sender {
    _loadView.hidden = NO;
    [_loadView startAnimating];
    [_loginBtn setTitle:@"" forState:UIControlStateNormal];
    [self performSelector:@selector(loginSuccess) withObject:self afterDelay:2.0f];
}

- (void) loginSuccess
{
    [_loadView stopAnimating];
    

    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.frame;
        rect.origin.y = SCREEN_HEIGHT;
        self.alpha = 0.0f;
        self.frame = rect;
    } completion:^(BOOL finished) {
         _loadView.hidden = YES;
         [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        [self removeFromSuperview];
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
