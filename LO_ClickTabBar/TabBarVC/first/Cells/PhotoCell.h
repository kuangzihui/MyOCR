//
//  PhotoCell.h
//  LO_ClickTabBar
//
//  Created by ejt_ios on 2017/6/30.
//  Copyright © 2017年 ejt_ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photoImagV;

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectBtnContraintW;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selctBtnContraintX;
@end
