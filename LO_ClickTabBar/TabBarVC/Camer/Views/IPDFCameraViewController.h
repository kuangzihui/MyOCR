//
//  IPDFCameraViewController.h
//  InstaPDF
//
//  Created by Maximilian Mackh on 06/01/15.
//  Copyright (c) 2015 mackh ag. All rights reserved.
//

#import <UIKit/UIKit.h>

static const CGFloat scaleA3 = 420.0/297.0;
static const CGFloat scaleA4 = 297.0/210.0;
static const CGFloat scaleA5 = 210.0/148.0;
static const CGFloat scaleSquare = 1.0;

typedef NS_ENUM(NSInteger,IPDFCameraViewType)
{
    IPDFCameraViewTypeBlackAndWhite,
    IPDFCameraViewTypeNormal
    
};

typedef NS_ENUM(NSInteger , IPDFSizeScale)
{
    IPDFSizeA3Scale, // A3
    IPDFSizeA4Scale, // A4
    IPDFSizeA5Scale, // A5
    IPDFSizeSquareScale, // 正方形
    IPDFSizeOtherScale // 随意
};

@protocol IPDFCameraViewControllerDelegate <NSObject>

- (void) capPhoto;

@end

@interface IPDFCameraViewController : UIView
{
    BOOL isRote;
}
- (void)setupCameraView;

- (void)start;
- (void)stop;

@property (nonatomic , assign) CGPoint topLeft;
@property (nonatomic , assign) CGPoint topRight;
@property (nonatomic , assign) CGPoint downLeft;
@property (nonatomic , assign) CGPoint downRight;
@property (nonatomic , assign) CGRect imageRect;
@property (nonatomic ,assign) id<IPDFCameraViewControllerDelegate> delegate;
@property (nonatomic,assign,getter=isBorderDetectionEnabled) BOOL enableBorderDetection;
@property (nonatomic,assign,getter=isTorchEnabled) BOOL enableTorch;

@property (nonatomic,assign) IPDFCameraViewType cameraViewType;
@property (nonatomic,assign) IPDFSizeScale sizeScale;

- (void)focusAtPoint:(CGPoint)point completionHandler:(void(^)())completionHandler;

- (void)captureImageWithCompletionHander:(void(^)(id data))completionHandler;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
