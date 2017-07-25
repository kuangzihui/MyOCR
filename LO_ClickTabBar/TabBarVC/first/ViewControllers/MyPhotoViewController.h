//
//  MyPhotoViewController.h
//  LO_ClickTabBar
//
//  Created by ejt_ios on 2017/6/26.
//  Copyright © 2017年 ejt_ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyPhotoViewControllerDelegate <NSObject>

@optional
- (void) finishPhotoWithSelectPhotos:(NSMutableArray *) photos deleteIndexs:(NSMutableIndexSet *) indexSets;

@end

@interface MyPhotoViewController : UIViewController

@property (nonatomic ,assign) id<MyPhotoViewControllerDelegate> delegate;

@end
