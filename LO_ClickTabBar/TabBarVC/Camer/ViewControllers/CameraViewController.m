//
//  CameraViewController.m
//  微企
//
//  Created by ejt_ios on 2017/5/23.
//  Copyright © 2017年 WJ. All rights reserved.
//

#import "CameraViewController.h"
#import "IPDFCameraViewController.h"
#import "LMJScrollTextView.h"
#import "UIImage+CropRotate.h"
#import "TOCropViewController.h"
#import "NSDate+Category.h"
#import "PhotoModel.h"

@interface CameraViewController ()<IPDFCameraViewControllerDelegate,TOCropViewControllerDelegate>
{
    LMJScrollTextView *scrollTextView1;
    UIButton *rightBtn;
}
@property (nonatomic ,strong) TOCropViewController *cropVC;
@property (nonatomic ,strong) UIImage *selectImg;
@property (nonatomic ,strong) NSString *fileName;
@property (nonatomic, assign) TOCropViewCroppingStyle croppingStyle; //The cropping style
@property (weak, nonatomic) IBOutlet IPDFCameraViewController *cameraViewController;
@property (weak, nonatomic) IBOutlet UIImageView *focusIndicator;
@property (weak, nonatomic) IBOutlet UIView *borderView;
@property (weak, nonatomic) IBOutlet UILabel *lblTs;

//- (IBAction)focusGesture:(id)sender;

- (IBAction)captureButton:(id)sender;

@end

@implementation CameraViewController


- (void) viewWillDisappear:(BOOL)animated
{
    if (self.cameraViewController) {
        [self.cameraViewController stop];
    }
    [super viewWillDisappear:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.cameraViewController start];
}

- (void) viewWillAppear:(BOOL)animated
{
    if (self.cameraViewController) {
       // [self.cameraViewController start];
        _lblTs.text = @"捕捉中...";
        
        __weak typeof(self) weakSelf = self;
        
        [self.cameraViewController focusAtPoint:weakSelf.cameraViewController.center completionHandler:^
         {
             [self focusIndicatorAnimateToPoint:weakSelf.cameraViewController.center];
         }];
    }
    [super viewWillAppear:YES];
}



- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //self.navigationController.navigationBarHidden = YES;
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 20, 30 );
    [backBtn setImage:[UIImage imageNamed:@"backs"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(leftNavBarItemPressed) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:nil forState:UIControlStateHighlighted];
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
     
    
    rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [rightBtn setTitle:@"黑白色" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [rightBtn setShowsTouchWhenHighlighted:YES];
    [rightBtn addTarget:self action:@selector(rightNavBarItemPressed) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    _borderView.alpha = 0.0;
    
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    borderLayer.bounds = CGRectMake(0, 0,_borderView.frame.size.width, _borderView.frame.size.height);//虚线框的大小
    borderLayer.position = CGPointMake(CGRectGetMidX(_borderView.bounds),CGRectGetMidY(_borderView.bounds));//虚线框锚点
    
    borderLayer.path = [UIBezierPath bezierPathWithRect:borderLayer.bounds].CGPath;//矩形路径
    
    borderLayer.strokeColor = [[UIColor greenColor] CGColor];
    borderLayer.lineWidth = 2.0;//1. / [[UIScreen mainScreen] scale];//虚线宽度
    borderLayer.fillColor = nil;
    //虚线边框
    borderLayer.lineDashPattern = @[@8, @8];
    
    [_borderView.layer addSublayer:borderLayer];
    
    
    self.cameraViewController.delegate = self;
    [self.cameraViewController setupCameraView];
    [self.cameraViewController setEnableBorderDetection:YES];
    [self.cameraViewController setCameraViewType:IPDFCameraViewTypeNormal];
    [self.cameraViewController setSizeScale:IPDFSizeA4Scale];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusGesture:)];
    
    [self.cameraViewController addGestureRecognizer:tapGesture];
    
    scrollTextView1 = [[LMJScrollTextView alloc] initWithFrame:CGRectMake(0, 70, SCREEN_WIDTH,25) textScrollModel:LMJTextScrollContinuous direction:LMJTextScrollMoveLeft];
    scrollTextView1.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    [self.view addSubview:scrollTextView1];
    
    [scrollTextView1 startScrollWithText:@"请将被拍摄物体放置在于手机平行处，待系统显示绿色取景框并稳定后自动拍摄" textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:15]];
   
}

- (void) leftNavBarItemPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void ) rightNavBarItemPressed
{
    [self.cameraViewController setCameraViewType:(self.cameraViewController.cameraViewType == IPDFCameraViewTypeBlackAndWhite) ? IPDFCameraViewTypeNormal : IPDFCameraViewTypeBlackAndWhite];
    
    if (self.cameraViewController.cameraViewType == IPDFCameraViewTypeBlackAndWhite) {
        [rightBtn setTitle:@"原色" forState:UIControlStateNormal];
    } else {
        [rightBtn setTitle:@"黑白色" forState:UIControlStateNormal];
    }
}


#pragma mark -
#pragma mark CameraVC Actions

- (void) focusGesture:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized)
    {
        CGPoint location = [sender locationInView:self.cameraViewController];
        
        [self focusIndicatorAnimateToPoint:location];
        __weak typeof(self) weakSelf = self;
        [self.cameraViewController focusAtPoint:location completionHandler:^
         {
             [weakSelf focusIndicatorAnimateToPoint:location];
         }];
    }
}

- (void)focusIndicatorAnimateToPoint:(CGPoint)targetPoint
{
    [self.focusIndicator setCenter:targetPoint];
    self.focusIndicator.alpha = 0.0;
    self.focusIndicator.hidden = NO;
    
    [UIView animateWithDuration:0.4 animations:^
     {
         self.focusIndicator.alpha = 1.0;
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.4 animations:^
          {
              self.focusIndicator.alpha = 0.0;
          }];
     }];
}

// 闪光灯开关方法
- (IBAction)torchToggle:(id)sender
{
    BOOL enable = !self.cameraViewController.isTorchEnabled;
    [self changeButton:sender targetTitle:(enable) ? @"闪光灯关" : @"闪光灯开" toStateEnabled:enable];
    self.cameraViewController.enableTorch = enable;
}

- (void)changeButton:(UIButton *)button targetTitle:(NSString *)title toStateEnabled:(BOOL)enabled
{
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:(enabled) ? [UIColor colorWithRed:1 green:0.81 blue:0 alpha:1] : [UIColor whiteColor] forState:UIControlStateNormal];
}

// 捕捉开关方法
- (IBAction)borderDetectToggle:(id)sender
{
    BOOL enable = !self.cameraViewController.isBorderDetectionEnabled;
    [self changeButton:sender targetTitle:(enable) ? @"关闭捕捉" : @"开启捕捉" toStateEnabled:enable];
    
    __weak typeof(self) weakSelf = self;
    
    if (!enable) {
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.borderView.alpha = 1.0f;
            weakSelf.lblTs.hidden = YES;
            scrollTextView1.hidden = YES;
        }];
        
    } else {
        
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.borderView.alpha = 0.0f;
            weakSelf.lblTs.hidden = NO;
            scrollTextView1.hidden = NO;
        }];
    }
    self.cameraViewController.enableBorderDetection = enable;
}

#pragma mark -
#pragma mark CameraVC Capture Image

- (void) capPhoto
{
    _lblTs.text = @"捕捉成功";
    [self captureButton:nil];
}

- (IBAction)captureButton:(id)sender
{
    
    __weak typeof(self) weakSelf = self;
    [self.cameraViewController captureImageWithCompletionHander:^(id data)
     {
         UIImage *image = ([data isKindOfClass:[NSData class]]) ? [UIImage imageWithData:data] : data;
         
         if (_borderView.alpha >0) {
             
             CGFloat wbl =  image.size.width/SCREEN_WIDTH;
             CGFloat hbl =  image.size.height/(SCREEN_HEIGHT-64);
             
             CGFloat cropX = _borderView.frame.origin.x *wbl;
             CGFloat cropY = _borderView.frame.origin.y *hbl;
             CGFloat cropH = _borderView.frame.size.height *hbl;
             
             image = [image croppedImageWithFrame:CGRectMake(cropX, cropY, image.size.width-(cropX*2), cropH) angle:0 circularClip:NO];
         }
         
         // [self saveImageToPhotos:image];
         
         if (_cropVC) {
             _cropVC = nil;
         }
         _cropVC = [[TOCropViewController alloc] initWithCroppingStyle:weakSelf.croppingStyle image:image];
         _cropVC.delegate = weakSelf;
         
         [weakSelf presentViewController:_cropVC animated:YES completion:nil];
         
     }];
}

- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(nonnull UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    
   
    if (image) {
        
        self.selectImg = image;
      
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入图片名称" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField *txtName = [alert textFieldAtIndex:0];
        txtName.returnKeyType = UIReturnKeyDone;
        
        
        NSString *dateStr = [[NSDate date] formattedDateYearYueRi:@"yyyy-MM-dd"];
        NSInteger currentCount =[[NSUserDefaults standardUserDefaults] integerForKey:dateStr];
        currentCount += 1;
        self.fileName = [dateStr stringByAppendingFormat:@"-%zd",currentCount];
        txtName.text = self.fileName;
        txtName.placeholder = @"请输入图片名称";
        [alert show];

    }
}

#pragma mark - 点击代理
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        UITextField *txt = [alertView textFieldAtIndex:0];
        if ([txt.text.trim isEmpty]) {
            [self showHint:@"图片名不能为空"];
            return;
        }
        
        NSString *key = [[NSDate date] formattedDateYearYueRi:@"yyyy-MM-dd"];
        
        if ([txt.text.trim isEqualToString:self.fileName]) {
            NSInteger currentCount =[[NSUserDefaults standardUserDefaults] integerForKey:key];
            currentCount += 1;
            [[NSUserDefaults standardUserDefaults] setInteger:currentCount forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        } else {
            self.fileName = txt.text.trim;
        }
        
        [self selectSaveFileName:@"我的图库"];
    }
}

- (void)selectSaveFileName:(NSString *)fileName
{
//            [self showView:self.view hint:@""];
//            NSData *_data = UIImageJPEGRepresentation(self.photoInfo.photoImg, 1.0f);
//            NSString *filePath = [fileName cacheWithPath];
//            NSMutableArray *arr = [NSMutableArray arrayWithContentsOfFile:filePath];
//            NSString *dataString = [_data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
//            if (arr == nil) {
//                arr = [NSMutableArray arrayWithObject:dataString];
//            } else {
//                [arr addObject:dataString];
//            }
//            if ([arr writeToFile:filePath atomically:YES]) {
//                [self showHint:@"保存成功"];
//                  [_cropVC.presentingViewController dismissViewControllerAnimated:YES completion:nil];
//            } else {
//                 [self showHint:@"保存失败"];
//            }
    
    NSString *filePath = [fileName cacheWithPath];
    [self savePhotoFileName:filePath];
}


- (void) savePhotoFileName: (NSString *) fileName
{
    [self showHudInView:_cropVC.view hint:@"保存中.."];
    __weak typeof(self)  bSelf= self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        BOOL isScueess = [bSelf archiverPhotoInfo:fileName];
        if (isScueess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [bSelf showHint:@"保存成功"];
                [bSelf hideHud];
                [[NSNotificationCenter defaultCenter] postNotificationName:IMAGE_CHANGE object:nil];
                [_cropVC.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [bSelf showHint:@"保存失败"];
                [bSelf hideHud];
            });
        }
        
        
    });
}

- (BOOL) archiverPhotoInfo:(NSString *) fileName
{
    
    PhotoModel *photo = [[PhotoModel alloc] init];
    photo.photoImg = self.selectImg;
    photo.photoDate = [[NSDate date] formattedDateYearYueRi:@"yyyy-MM-dd"];
    photo.photoName = self.fileName;
    
    //1.创建一个可变的二进制流
    NSMutableData *data=[[NSMutableData alloc]init];
    //2.创建一个归档对象(有将自定义类转化为二进制流的功能)
    NSKeyedArchiver *archiver=[[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    //3.用该归档对象，把自定义类的对象，转为二进制流
    [archiver encodeObject:photo forKey:@"photo"];
    //4归档完毕
    [archiver finishEncoding];
    //将data写入文件
    NSMutableArray *writeArr = [NSMutableArray arrayWithContentsOfFile:fileName];
    if (writeArr == nil) {
        writeArr = [NSMutableArray array];
       
    }
    [writeArr addObject:data];
    if ([writeArr writeToFile:fileName atomically:YES]) {
        return YES;
    }
    return NO;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
