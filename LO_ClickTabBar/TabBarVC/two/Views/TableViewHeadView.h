//
//  TableViewHeadView.h
//  LO_ClickTabBar
//
//  Created by ejt_ios on 2017/6/19.
//  Copyright © 2017年 ejt_ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewHeadView : UIView

+ (instancetype) loadHeadView;

@property (weak, nonatomic) IBOutlet UIImageView *headImgV;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@end
