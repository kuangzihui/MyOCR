//
//  TableViewHeadView.m
//  LO_ClickTabBar
//
//  Created by ejt_ios on 2017/6/19.
//  Copyright © 2017年 ejt_ios. All rights reserved.
//

#import "TableViewHeadView.h"

@implementation TableViewHeadView

+ (instancetype) loadHeadView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"TableViewHeadView" owner:self options:nil] lastObject];
}

- (void)awakeFromNib
{
    _headImgV.layer.cornerRadius = 30;
    _headImgV.layer.masksToBounds = YES;
    self.clipsToBounds = YES;
    [super awakeFromNib];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
