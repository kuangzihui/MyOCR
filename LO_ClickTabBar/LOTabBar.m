//
//  LOTabBar.m
//  LO_ClickTabBar
//
//  Created by ejt_ios on 2017/6/5.
//  Copyright © 2017年 ejt_ios. All rights reserved.
//

#import "LOTabBar.h"

static NSInteger itemCount = 3;
@implementation LOTabBar

- (instancetype)init
{
    if (self = [super init]) {
        [self setUI];
    }
    return self;
}

- (void) setUI {
    self.backgroundImage = [UIImage imageNamed:@"tb_background"];
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.3)];
    lineV.backgroundColor = THEME_COLOR;
    [self addSubview:lineV];
    [self addSubview:self.centerPlusBtn];
}

- (UIButton *) centerPlusBtn {
    if (_centerPlusBtn == nil) {
        _centerPlusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _centerPlusBtn.frame = CGRectMake(0, 0, 75, 75);
        [_centerPlusBtn addTarget:self action:@selector(centerPlusBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_centerPlusBtn setImage:[UIImage imageNamed:@"tb_compose_add"] forState:UIControlStateNormal];
        _centerPlusBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        //[_centerPlusBtn setImage:[UIImage imageNamed:@"tb_compose_add_highlighted"] forState:UIControlStateHighlighted];
        _centerPlusBtn.backgroundColor = RGBA(8, 100, 180, 1.0);
        _centerPlusBtn.layer.borderColor = [UIColor greenColor].CGColor;
        _centerPlusBtn.layer.borderWidth = 0.5f;
        
        _centerPlusBtn.layer.masksToBounds = YES;
        _centerPlusBtn.layer.cornerRadius = 37.5;
    }
    
    return _centerPlusBtn;
}

- (void) centerPlusBtnClick {
    [_loBarDelegate centerButtonClick];
}

- (void) layoutSubviews
{
    self.centerPlusBtn.center = CGPointMake(self.bounds.size.width*0.5, self.bounds.size.height*0.5-25);
    
    CGFloat itemWidth = self.bounds.size.width/itemCount;
    
    NSInteger index = 0;
    
    for (UIView *itemView  in  self.subviews) {
         // 找到我们关心的按钮，UITabBarButton系统的私有类，不能直接使用
        if ([itemView isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            CGRect rect = itemView.frame;
            rect.size.width = itemWidth;
            rect.origin.x = (CGFloat) index*itemWidth;
            itemView.frame = rect;
            index++;
            
            if (index == (NSInteger)(itemCount/2)) {
                index ++;
            }
        }
    }
    
    [super layoutSubviews];
}

- (void) updateFrame
{
    CGFloat itemWidth = self.bounds.size.width/itemCount;
    
    NSInteger index = 0;
    
    for (UIView *itemView  in  self.subviews) {
        // 找到我们关心的按钮，UITabBarButton系统的私有类，不能直接使用
        if ([itemView isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            CGRect rect = itemView.frame;
            rect.size.width = itemWidth;
            rect.origin.x = (CGFloat) index*itemWidth;
            itemView.frame = rect;
            index++;
            
            if (index == (NSInteger)(itemCount/2)) {
                index ++;
            }
        }
    }

}

// MARK: - 关键方法，超出范围仍能点击

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    
    
    for (UIView *itemView in self.subviews) {
        if (CGRectContainsPoint(itemView.frame, point)) {
            return true;
        }
    }
    return false;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
