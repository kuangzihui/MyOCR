//
//  IPDFCameraViewController.m
//  InstaPDF
//
//  Created by Maximilian Mackh on 06/01/15.
//  Copyright (c) 2015 mackh ag. All rights reserved.
//

#import "IPDFCameraViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <GLKit/GLKit.h>

@interface IPDFCameraViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

{
    
    CGFloat imageW;
    CGFloat imageH;
}

@property (nonatomic,strong) AVCaptureSession *captureSession;
@property (nonatomic,strong) AVCaptureDevice *captureDevice;
@property (nonatomic,strong) EAGLContext *context;

@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;

@property (nonatomic, assign) BOOL forceStop;

@end

@implementation IPDFCameraViewController
{
    CIContext *_coreImageContext;
    GLuint _renderBuffer;
    GLKView *_glkView;
    
    BOOL _isStopped;
    
    CGFloat _imageDedectionConfidence;
    NSTimer *_borderDetectTimeKeeper;
    BOOL _borderDetectFrame;
    CIRectangleFeature *_borderDetectLastRectangleFeature;
    
    BOOL _isCapturing;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_backgroundMode) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_foregroundMode) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)_backgroundMode
{
    self.forceStop = YES;
}

- (void)_foregroundMode
{
    self.forceStop = NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createGLKView
{
    if (self.context) return;
    
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *view = [[GLKView alloc] initWithFrame:self.bounds];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.translatesAutoresizingMaskIntoConstraints = YES;
    view.context = self.context;
    view.backgroundColor = [UIColor clearColor];
    view.contentScaleFactor = 1.0f;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [self insertSubview:view atIndex:0];
    _glkView = view;
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    _coreImageContext = [CIContext contextWithEAGLContext:self.context];
    [EAGLContext setCurrentContext:self.context];
}

- (void)setupCameraView
{
    [self createGLKView];
    
    // 获取设备
    NSArray *possibleDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *device = [possibleDevices firstObject];
    if (!device) return;
    
    _imageDedectionConfidence = 0.0;
    // 设备协调输入输出中心
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    self.captureSession = session;
    [session beginConfiguration];
    self.captureDevice = device;
    
    session.sessionPreset = AVCaptureSessionPresetHigh;
    
    NSError *error = nil;
    // 输入源
    AVCaptureDeviceInput* input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    session.sessionPreset = AVCaptureSessionPresetPhoto;
    [session addInput:input];
    
    // 输出源
    AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [dataOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)}];
    [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    [session addOutput:dataOutput];
    
    // 输出图片
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    [session addOutput:self.stillImageOutput];
    
    AVCaptureConnection *connection = [dataOutput.connections firstObject];
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    if (device.isFlashAvailable)
    {
        [device lockForConfiguration:nil];
        [device setFlashMode:AVCaptureFlashModeOff];
        [device unlockForConfiguration];
        
        if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
        {
            [device lockForConfiguration:nil];
            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            [device unlockForConfiguration];
        }
    }
    
    [session commitConfiguration];
}

- (void)setCameraViewType:(IPDFCameraViewType)cameraViewType
{
    UIBlurEffect * effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *viewWithBlurredBackground =[[UIVisualEffectView alloc] initWithEffect:effect];
    viewWithBlurredBackground.frame = self.bounds;
    viewWithBlurredBackground.backgroundColor = [UIColor clearColor];
    [self insertSubview:viewWithBlurredBackground aboveSubview:_glkView];
    
    _cameraViewType = cameraViewType;
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        [viewWithBlurredBackground removeFromSuperview];
    });
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (self.forceStop) return;
    if (_isStopped || _isCapturing || !CMSampleBufferIsValid(sampleBuffer)) return;
    
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    
    
    
    if (self.cameraViewType != IPDFCameraViewTypeNormal)
    {
        image = [self filteredImageUsingEnhanceFilterOnImage:image];
    }
    else
    {
        image = [self filteredImageUsingContrastFilterOnImage:image];
    }
    
    
    
    if (self.isBorderDetectionEnabled)
    {
        if (_borderDetectFrame)
        {
            _borderDetectLastRectangleFeature = [self biggestRectangleInRectangles:[[self highAccuracyRectangleDetector] featuresInImage:image]];
            _borderDetectFrame = NO;
        }
        
        if (_borderDetectLastRectangleFeature)
        {
            _imageDedectionConfidence += .5;
            
            
            
            image = [self drawHighlightOverlayForPoints:image topLeft:_borderDetectLastRectangleFeature.topLeft topRight:_borderDetectLastRectangleFeature.topRight bottomLeft:_borderDetectLastRectangleFeature.bottomLeft bottomRight:_borderDetectLastRectangleFeature.bottomRight];
            
            
           
//            _downLeft = bottomLeft;  // 上右
//            _downRight = bottomRight; // 下右
//            _topLeft = topLeft; // 上左
//            _topRight = topRight; //下左
            
           // imageW = fabsf((float)(_downLeft.x-_topLeft.x));
            //imageH = fabsf((float)(_downRight.y-_downLeft.y));
            
            imageW = _imageRect.size.width;
            imageH = _imageRect.size.height;
            
            CGFloat whScale = imageH/imageW;
            NSLog(@"w = %f ,h = %f,",scaleA3,whScale);
            
            CGFloat jumpScale = 0.0f;
            if (_imageDedectionConfidence>10.0 && (image.extent.size.width-imageW) <= 250) {
                
                switch (_sizeScale) {
                    case IPDFSizeA3Scale:
                        jumpScale = whScale-scaleA3;
                        break;
                    case IPDFSizeA4Scale:
                        jumpScale = whScale-scaleA4;
                        break;
                    case IPDFSizeA5Scale:
                        jumpScale = whScale-scaleA5;
                        break;
                    case IPDFSizeSquareScale:
                        jumpScale = whScale-scaleSquare;
                        break;
                        
                    default:
                        jumpScale = 0.05;
                        break;
                }
                
                if ( fabsf((float)jumpScale) <= 0.08 ) {
                    
                    NSLog(@"%@--%@",NSStringFromCGPoint(_downLeft),NSStringFromCGPoint(_downRight));
                    
                    self.forceStop = YES;
                    [_borderDetectTimeKeeper invalidate];
                    [_delegate capPhoto];
                }
               

            }
            
        }
        else
        {
            _imageDedectionConfidence = 0.0f;
        }
    }
    
    if (self.context && _coreImageContext)
    {
        [_coreImageContext drawImage:image inRect:self.bounds fromRect:image.extent];
        [self.context presentRenderbuffer:GL_RENDERBUFFER];
        [_glkView setNeedsDisplay];
    }
}

- (void)captureImageWithCompletionHander:(void(^)(id data))completionHandler
{
    if (_isCapturing) return;
    
    __weak typeof(self) weakSelf = self;
    
    [weakSelf hideGLKView:YES completion:^
     {
         [weakSelf hideGLKView:NO completion:^
          {
              [weakSelf hideGLKView:YES completion:nil];
          }];
     }];
    
    _isCapturing = YES;
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) break;
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         
         if (weakSelf.cameraViewType == IPDFCameraViewTypeBlackAndWhite || weakSelf.isBorderDetectionEnabled)
         {
             CIImage *enhancedImage = [CIImage imageWithData:imageData];
             
             UIImage *img = [UIImage imageWithData:imageData];
             UIImageOrientation oldOrientation = img.imageOrientation;
             
             
             
             
             if (weakSelf.cameraViewType == IPDFCameraViewTypeBlackAndWhite)
             {
                 enhancedImage = [self filteredImageUsingEnhanceFilterOnImage:enhancedImage];
             }
             else
             {
                 enhancedImage = [self filteredImageUsingContrastFilterOnImage:enhancedImage];
             }
             
             if (weakSelf.isBorderDetectionEnabled && rectangleDetectionConfidenceHighEnough(_imageDedectionConfidence))
             {
                 _imageDedectionConfidence = 0.0f;
                 
                 CIDetector *tector = [self highAccuracyRectangleDetector];
                 NSArray *arr = [tector featuresInImage:enhancedImage];
                 CIRectangleFeature *rectangleFeature = [self biggestRectangleInRectangles:arr];
                 
                 if (rectangleFeature)
                 {
                     enhancedImage = [self correctPerspectiveForImage:enhancedImage withFeatures:rectangleFeature];
                     isRote = YES;
                 }
             }
             
             
             if (fabsf((float)_downRight.y)  > fabsf((float)_downLeft.y)) {
                 if (fabsf((float)_downLeft.x) < fabsf((float)_downRight.x)) {
                     if(fabsf((float)_downRight.x) - fabsf((float)_downLeft.x) >= 10)
                         oldOrientation = UIImageOrientationLeft;
                 } else if (fabsf((float)_downRight.x) - fabsf((float)_downRight.x) <= 5) {
                     oldOrientation = UIImageOrientationLeft;
                 }
             }
             
             UIGraphicsBeginImageContext(CGSizeMake(enhancedImage.extent.size.height, enhancedImage.extent.size.width));
             [[UIImage imageWithCIImage:enhancedImage scale:1.0 orientation:UIImageOrientationRight] drawInRect:CGRectMake(0,0, enhancedImage.extent.size.height, enhancedImage.extent.size.width)];
             UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
             UIGraphicsEndImageContext();
             
             
             
             [weakSelf hideGLKView:NO completion:nil];
             if (isRote) {

                 image = [self image:image rotation:oldOrientation];
                 isRote = NO;
             }
             
             completionHandler(image);
         }
         else
         {
             [weakSelf hideGLKView:NO completion:nil];
             completionHandler(imageData);
         }
         
         _isCapturing = NO;
     }];
}


- (void)enableBorderDetectFrame
{
    _borderDetectFrame = YES;
}

// 生成捕捉到颜色块
- (CIImage *)drawHighlightOverlayForPoints:(CIImage *)image topLeft:(CGPoint)topLeft topRight:(CGPoint)topRight bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight
{
    int caha = fabs(_topLeft.x -_topRight.x);
    CIImage *overlay = nil;
    
    if (caha <110) {
        overlay = [CIImage imageWithColor:[CIColor colorWithRed:0.0 green:0.8 blue:0.0 alpha:0.4]];
    } else {
        _imageDedectionConfidence = 0;
       
         overlay = [CIImage imageWithColor:[CIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:0.4]];
    }
   
    //overlay = [CIImage imageWithCGImage:[UIImage imageNamed:@"ocr29"].CGImage];
    
    //overlay = [CIImage imageWithColor:[UIColor clearColor].CIColor];
    
    overlay = [overlay imageByCroppingToRect:image.extent];
   
    
    overlay = [overlay imageByApplyingFilter:@"CIPerspectiveTransformWithExtent" withInputParameters:@{@"inputExtent":[CIVector vectorWithCGRect:image.extent],@"inputTopLeft":[CIVector vectorWithCGPoint:topLeft],@"inputTopRight":[CIVector vectorWithCGPoint:topRight],@"inputBottomLeft":[CIVector vectorWithCGPoint:bottomLeft],@"inputBottomRight":[CIVector vectorWithCGPoint:bottomRight]}];
    
    
    _imageRect = overlay.extent;
    
    NSLog(@"overlay = %@",NSStringFromCGRect(overlay.extent));
    
    //UIImage *newImg = [self addBpolygonToImage:[UIImage imageWithCIImage:overlay] withLineWidth:2.0f andColor:[UIColor redColor]];
   // CIImage *ciimage = [CIImage imageWithCGImage:newImg.CGImage];
 
    
   

    
    _downLeft = bottomLeft;  // 上右
    _downRight = bottomRight; // 下右
    _topLeft = topLeft; // 上左
    _topRight = topRight; //下左
    
    overlay = [overlay imageByCompositingOverImage:image];
     
    
    return overlay;
    
}

- (UIImage *)addBpolygonToImage:(UIImage *)image withLineWidth:(CGFloat)lineW andColor:(UIColor *)color{
    //
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
    //
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    //
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -rect.size.height);
    //
    CGFloat lineWidth = lineW;
    
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
   
    [path closePath];
    
    path.lineWidth = lineWidth;
    path.lineJoinStyle = kCGLineJoinMiter;
    [color setStroke];
    [path stroke];
    //
    CGContextSaveGState(ctx);
    [path addClip];
    CGContextDrawImage(ctx, rect, image.CGImage);
    CGContextRestoreGState(ctx);
    //
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (void)start
{
    _isStopped = NO;
    _forceStop = NO;
    [self.captureSession startRunning];
    
    _borderDetectTimeKeeper = [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(enableBorderDetectFrame) userInfo:nil repeats:YES];
    [self hideGLKView:NO completion:nil];
}

- (void)stop
{
    _isStopped = YES;
    _forceStop = YES;
    _imageDedectionConfidence = 0.0f;
    [self.captureSession stopRunning];
    
    [_borderDetectTimeKeeper invalidate];
    
    [self hideGLKView:YES completion:nil];
}

- (void)setEnableTorch:(BOOL)enableTorch
{
    _enableTorch = enableTorch;
    
    AVCaptureDevice *device = self.captureDevice;
    if ([device hasTorch] && [device hasFlash])
    {
        [device lockForConfiguration:nil];
        if (enableTorch)
        {
            [device setTorchMode:AVCaptureTorchModeOn];
        }
        else
        {
            [device setTorchMode:AVCaptureTorchModeOff];
        }
        [device unlockForConfiguration];
    }
}

- (void)focusAtPoint:(CGPoint)point completionHandler:(void(^)())completionHandler
{
    AVCaptureDevice *device = self.captureDevice;
    CGPoint pointOfInterest = CGPointZero;
    CGSize frameSize = self.bounds.size;
    pointOfInterest = CGPointMake(point.y / frameSize.height, 1.f - (point.x / frameSize.width));
    
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus])
    {
        NSError *error;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
            {
                [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
                [device setFocusPointOfInterest:pointOfInterest];
                //[device setFocusModeLockedWithLensPosition:<#(float)#> completionHandler:^(CMTime syncTime) {
                    
                //}];
            }
            
            if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
            {
                [device setExposurePointOfInterest:pointOfInterest];
                [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                completionHandler();
            }
            
            [device unlockForConfiguration];
        }
    }
    else
    {
        completionHandler();
    }
}


- (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    
    return newPic;
}


- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (void)hideGLKView:(BOOL)hidden completion:(void(^)())completion
{
    [UIView animateWithDuration:0.1 animations:^
    {
        _glkView.alpha = (hidden) ? 0.0 : 1.0;
    }
    completion:^(BOOL finished)
    {
        if (!completion) return;
        completion();
    }];
}

- (CIImage *)filteredImageUsingEnhanceFilterOnImage:(CIImage *)image
{
    return [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, image, @"inputBrightness", [NSNumber numberWithFloat:0.0], @"inputContrast", [NSNumber numberWithFloat:1.14], @"inputSaturation", [NSNumber numberWithFloat:0.0], nil].outputImage;
}

- (CIImage *)filteredImageUsingContrastFilterOnImage:(CIImage *)image
{
    return [CIFilter filterWithName:@"CIColorControls" withInputParameters:@{@"inputContrast":@(1.1),kCIInputImageKey:image}].outputImage;
}

- (CIImage *)correctPerspectiveForImage:(CIImage *)image withFeatures:(CIRectangleFeature *)rectangleFeature
{
    NSMutableDictionary *rectangleCoordinates = [NSMutableDictionary new];
    rectangleCoordinates[@"inputTopLeft"] = [CIVector vectorWithCGPoint:rectangleFeature.topLeft];
    rectangleCoordinates[@"inputTopRight"] = [CIVector vectorWithCGPoint:rectangleFeature.topRight];
    rectangleCoordinates[@"inputBottomLeft"] = [CIVector vectorWithCGPoint:rectangleFeature.bottomLeft];
    rectangleCoordinates[@"inputBottomRight"] = [CIVector vectorWithCGPoint:rectangleFeature.bottomRight];
    return [image imageByApplyingFilter:@"CIPerspectiveCorrection" withInputParameters:rectangleCoordinates];
}

- (CIDetector *)rectangleDetetor
{
    static CIDetector *detector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
          detector = [CIDetector detectorOfType:CIDetectorTypeRectangle context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyLow,CIDetectorTracking : @(YES)}];
    });
    return detector;
}

- (CIDetector *)highAccuracyRectangleDetector
{
    static CIDetector *detector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        // 矩形检测探测器类型   CIDetectorTypeRectangle
        detector = [CIDetector detectorOfType:CIDetectorTypeRectangle context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
    });
    return detector;
}

- (CIRectangleFeature *)biggestRectangleInRectangles:(NSArray *)rectangles
{
    if (![rectangles count]) return nil;
    
    float halfPerimiterValue = 0;
    
    CIRectangleFeature *biggestRectangle = [rectangles firstObject];
    
    for (CIRectangleFeature *rect in rectangles)
    {
        CGPoint p1 = rect.topLeft;
        CGPoint p2 = rect.topRight;
        CGFloat width = hypotf(p1.x - p2.x, p1.y - p2.y);
        
        CGPoint p3 = rect.topLeft;
        CGPoint p4 = rect.bottomLeft;
        CGFloat height = hypotf(p3.x - p4.x, p3.y - p4.y);
        
        CGFloat currentHalfPerimiterValue = height + width;
        
        if (halfPerimiterValue < currentHalfPerimiterValue)
        {
            halfPerimiterValue = currentHalfPerimiterValue;
            biggestRectangle = rect;
        }
    }
    
    return biggestRectangle;
}

BOOL rectangleDetectionConfidenceHighEnough(float confidence)
{
    return (confidence > 1.0);
}

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
