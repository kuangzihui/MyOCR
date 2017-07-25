//
//  UITableView+EmptyData.m
//  LO_ClickTabBar
//
//  Created by ejt_ios on 2017/6/22.
//  Copyright © 2017年 ejt_ios. All rights reserved.
//

#import "UITableView+EmptyData.h"

@implementation UITableView (EmptyData)


- (void)tableViewDisplayWitMsg:(NSString *) message ifNecessaryForRowCount:(NSUInteger) rowCount
{
    if (rowCount == 0) {
        // Display a message when the table is empty
        // 没有数据的时候，UILabel的显示样式
        
        UIView *backV = [[UIView alloc] initWithFrame:CGRectMake(0,20, SCREEN_WIDTH, SCREEN_HEIGHT-64-49)];
        backV.backgroundColor = [UIColor clearColor];
        
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
        imgV.image = [UIImage imageNamed:@"noData"];
        imgV.center = backV.center;
        [backV addSubview:imgV];
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(30,CGRectGetMaxY(imgV.frame)+10, SCREEN_WIDTH-60, 20)];
        messageLabel.text = message;
        messageLabel.font = [UIFont boldSystemFontOfSize:15];
        messageLabel.textColor = [UIColor lightGrayColor];
        messageLabel.textAlignment = NSTextAlignmentCenter;
       // [messageLabel sizeToFit];
        [backV addSubview:messageLabel];
        
        self.backgroundView = backV;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
    } else {
        self.backgroundView = nil;
        self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
}
@end
