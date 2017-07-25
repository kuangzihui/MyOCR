//
//  SaveImageToFileViewController.h
//  LO_ClickTabBar
//
//  Created by ejt_ios on 2017/6/22.
//  Copyright © 2017年 ejt_ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SaveImageToFileViewControllerDelegate <NSObject>

@optional
- (void) selectSaveFileName:(NSString *) fileName;

@end

@interface SaveImageToFileViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>

@property (nonatomic ,assign) id<SaveImageToFileViewControllerDelegate> delegate;
@property (nonatomic ,strong) NSString *fileName;
- (instancetype)initWithFileName:(NSString *) file_name;
- (void) showView;
@end
