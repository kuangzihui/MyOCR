//
//  UITableView+EmptyData.h
//  LO_ClickTabBar
//
//  Created by ejt_ios on 2017/6/22.
//  Copyright © 2017年 ejt_ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (EmptyData)

- (void)tableViewDisplayWitMsg:(NSString *) message ifNecessaryForRowCount:(NSUInteger) rowCount;

@end
