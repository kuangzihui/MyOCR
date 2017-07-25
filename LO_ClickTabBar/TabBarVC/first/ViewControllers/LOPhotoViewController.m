//
//  LOPhotoViewController.m
//  LO_ClickTabBar
//
//  Created by ejt_ios on 2017/6/19.
//  Copyright © 2017年 ejt_ios. All rights reserved.
//

#import "LOPhotoViewController.h"
#import "PhotoItemCell.h"
#import "XLPhotoBrowser.h"
#import "PhotoModel.h"
#import "UICollectionView+EmptyData.h"
#import "CameraViewController.h"
#import "LONavVC.h"
#import "NSDate+Category.h"
#import "PublicView.h"
#import "MyPhotoViewController.h"
#import "UIColor+LOColor.h"
#import "SaveImageToFileViewController.h"
#import "PhotoCell.h"
#import "UITableView+EmptyData.h"

typedef NS_ENUM(NSInteger , ListShowStyle) {
    
    ListShowCollectionView,
    ListShowTabView
    
};

static NSInteger rowCount = 3;
static CGFloat marginX = 5;
static CGFloat marginY = 5;

@interface LOPhotoViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,XLPhotoBrowserDelegate,XLPhotoBrowserDatasource,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,MyPhotoViewControllerDelegate,SaveImageToFileViewControllerDelegate,UITableViewDelegate,UITableViewDataSource>
{
    UICollectionView *collectionV;
    UITableView *tabView;
    NSMutableArray *dataArray;
    
    BOOL isLoading;
    UIButton *rightBtn;
    BOOL isDel;
    PublicView *pubView;
    
    NSInteger sheetCount;
    UIButton *downBtn;
    ListShowStyle showStyle;
    
    UIButton *styleBtn;
}

@property (nonatomic , strong) PhotoModel *photoInfo;
@property (nonatomic ,strong)  NSString *defaultText;

@property (nonatomic , strong) NSMutableIndexSet *indexSets;

@end

@implementation LOPhotoViewController

- (NSMutableIndexSet *)indexSets
{
    if (!_indexSets) {
        _indexSets = [[NSMutableIndexSet alloc] init];
    }
    return _indexSets;
}

- (PhotoModel *)photoInfo
{
    if (!_photoInfo) {
        _photoInfo = [[PhotoModel alloc] init];
    }
    return _photoInfo;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (pubView) {
        [pubView removeFromSuperview];
    }
}

- (BOOL) getCacheImgae
{
    if (dataArray.count>0) {
        [dataArray removeAllObjects];
    }
    NSMutableArray *imgArray = [NSMutableArray arrayWithContentsOfFile:[self.fileName cacheWithPath]];
    if (imgArray) {
        for (int i = 0; i<imgArray.count; i++) {
            NSMutableData *mData= imgArray[i];
            //2.创建一个反归档对象，将二进制数据解成正行的oc数据
            NSKeyedUnarchiver *unArchiver=[[NSKeyedUnarchiver alloc] initForReadingWithData:mData];
            PhotoModel *photoInfo = [unArchiver decodeObjectForKey:@"photo"];
            [dataArray addObject:photoInfo];
        }
        
    }
    isLoading = NO;
    return YES;
}

- (instancetype)initWithFileName:(NSString *)file_name
{
    if (self = [super init]) {
        self.fileName = file_name;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.fileName;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    showStyle = ListShowCollectionView;
    
    isDel = NO;
    
    
    rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    [rightBtn setTitle:@"操作" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [rightBtn setShowsTouchWhenHighlighted:YES];
    [rightBtn addTarget:self action:@selector(rightNavBarItemPressed) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    isLoading = YES;
    
    dataArray = [[NSMutableArray alloc] init];
   
    [self fileNameChange];
   
   
    tabView = [[UITableView alloc] initWithFrame:CGRectMake(-SCREEN_WIDTH, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStylePlain];
    tabView.backgroundColor = [UIColor clearColor];
    tabView.delegate  = self;
    tabView.dataSource = self;
    tabView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tabView.separatorColor = [UIColor groupTableViewBackgroundColor];
    [tabView registerNib:[UINib nibWithNibName:@"PhotoCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"photoCell"];
    tabView.hidden = YES;
    [self.view addSubview:tabView];
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = marginX;
    layout.minimumInteritemSpacing = marginY;
    layout.sectionInset = UIEdgeInsetsMake(marginY, marginX, marginY, marginX);
    CGFloat itemWdith = (SCREEN_WIDTH-((rowCount+1)*marginX))/rowCount;
    layout.itemSize = CGSizeMake(itemWdith, itemWdith+25);
    
    collectionV = [[UICollectionView alloc] initWithFrame:CGRectMake(0,64, SCREEN_WIDTH, SCREEN_HEIGHT-64) collectionViewLayout:layout];
    collectionV.delegate = self;
    collectionV.dataSource = self;
    collectionV.backgroundColor = [UIColor clearColor];
    [collectionV registerNib:[UINib nibWithNibName:@"PhotoItemCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"photoCell"];
    
    [self.view addSubview:collectionV];
    
    
    downBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    downBtn.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 40);
    [downBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
   
    [downBtn setBackgroundImage:[UIColor colorRepImageWithColor:THEME_COLOR] forState:UIControlStateNormal];
    [downBtn setBackgroundImage:[UIColor colorRepImageWithColor:LOGBTN_COLOR] forState:UIControlStateHighlighted];
    downBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [downBtn addTarget:self action:@selector(downBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:downBtn];
    
    styleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    styleBtn.frame = CGRectMake(SCREEN_WIDTH - 70, SCREEN_HEIGHT-70, 50, 50);
    [styleBtn setTitle:@"列表" forState:UIControlStateNormal];
    styleBtn.backgroundColor = [UIColor grayColor];
    styleBtn.layer.shadowColor = [UIColor blackColor].CGColor;
    styleBtn.layer.shadowOpacity = 0.8;
    styleBtn.layer.shadowOffset = CGSizeMake(20, 20);
    styleBtn.layer.cornerRadius = 25;
    styleBtn.layer.masksToBounds = YES;
    
    [styleBtn addTarget:self action:@selector(styleBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    styleBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [self.view addSubview:styleBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileNameChange) name:IMAGE_CHANGE object:nil];
}


- (void) styleBtnAction:(UIButton *) sender
{
    [self showCurrentListWithAnimation:YES];
}

- (void) showCurrentListWithAnimation:(BOOL) isAnimation
{
    if (showStyle == ListShowCollectionView) {
        showStyle = ListShowTabView;
        [styleBtn setTitle:@"九宫格" forState:UIControlStateNormal];
        CGRect rect = tabView.frame;
        rect.origin.x = 0;
        CGRect collRect = collectionV.frame;
        collRect.origin.x = SCREEN_WIDTH;
        
        collectionV.hidden = YES;
        tabView.hidden = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            tabView.frame = rect;
            collectionV.frame = collRect;
            
        }];
        [tabView reloadData];
    } else {
        showStyle = ListShowCollectionView;
        [styleBtn setTitle:@"列表" forState:UIControlStateNormal];
        CGRect rect = tabView.frame;
        rect.origin.x = -SCREEN_WIDTH;
        CGRect collRect = collectionV.frame;
        collRect.origin.x = 0;
        
        collectionV.hidden = NO;
        tabView.hidden = YES;
        
        [UIView animateWithDuration:0.3 animations:^{
            tabView.frame = rect;
            collectionV.frame = collRect;
        }];
        [collectionV reloadData];
    }
}

- (void) fileNameChange
{
    [self showHudInView:self.view hint:@"加载中"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if ([self getCacheImgae]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                if (showStyle == ListShowCollectionView) {
                    [collectionV reloadData];
                } else {
                    [tabView reloadData];
                }
                
            });
        }
    });
}

- (void) StyleBtnshowHidden
{
    if (isDel) {
        styleBtn.hidden = YES;
        styleBtn.enabled = NO;
    } else {
        styleBtn.hidden = NO;
        styleBtn.enabled = YES;
    }
}
- (void) rightNavBarItemPressed
{
    if (isDel) {
        isDel = NO;
        [self StyleBtnshowHidden];
        if (self.indexSets.count > 0) {
            [self.indexSets removeAllIndexes];
        }
        [rightBtn setTitle:@"操作" forState:UIControlStateNormal];
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rect = downBtn.frame;
            rect.origin.y += 40;
            downBtn.frame = rect;
            
            if (showStyle == ListShowCollectionView) {
                rect = collectionV.frame;
                rect.size.height += 40;
                collectionV.frame = rect;
            } else {
                rect = tabView.frame;
                rect.size.height += 40;
                tabView.frame = rect;
            }
           
        }];
        if (showStyle == ListShowCollectionView) {
            [collectionV reloadData];
        } else {
            [tabView reloadData];
        }
        return;
    }
    
    
    if (dataArray.count == 0) {
        
        UIActionSheet *sheet =  [[UIActionSheet alloc] initWithTitle:@"操作选项" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"添加图片",@"拍摄图片", nil];
        [sheet showInView:self.view];
        
    } else {
        
        UIActionSheet *sheet =  [[UIActionSheet alloc] initWithTitle:@"操作选项" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"OCR解析" otherButtonTitles:@"添加图片",@"拍摄图片",@"移动到",@"删除", nil];
        [sheet showInView:self.view];
        
    }
    
}

- (void) rightBtnStatuChange
{
    isDel = YES;
    [self StyleBtnshowHidden];
    [rightBtn setTitle:@"取消" forState:UIControlStateNormal];
    if (sheetCount == 3) { // 移动过
        [downBtn setTitle:@"移动" forState:UIControlStateNormal];
    } else if (sheetCount == 4) { // 删除
        [downBtn setTitle:@"删除" forState:UIControlStateNormal];
    }
    
    CGRect rect = downBtn.frame;
    rect.origin.y -= 40;
    
    CGRect collRect = collectionV.frame;
    if (showStyle == ListShowTabView) {
        collRect = tabView.frame;
    }
    
    collRect.size.height -= 40;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        downBtn.frame = rect;
        if (showStyle == ListShowTabView) {
            tabView.frame = collRect;
        } else {
            collectionV.frame = collRect;
        }
    }];
    
    if (showStyle == ListShowCollectionView) {
        [collectionV reloadData];
    } else {
        [tabView reloadData];
    }
}

- (void)centerButtonClick
{
    CameraViewController *cameraVC = [[CameraViewController alloc] init];
    LONavVC *nav = [[LONavVC alloc] initWithRootViewController:cameraVC];
    cameraVC.navigationItem.title = @"文档拍照";
    [self presentViewController:nav animated:YES completion:nil];
}

- (void) addPhoto
{
    if (![self.fileName isEqualToString:@"我的图库"]) {
        [self addReplyMenuShow];
    } else {
        UIImagePickerController *imgVC = [[UIImagePickerController alloc] init];
        imgVC.allowsEditing = NO;
        imgVC.delegate = self;
        [imgVC setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self presentViewController:imgVC animated:YES completion:nil];
    }
}

#pragma mark - UIImagePicker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    if ([picker respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    self.photoInfo.photoImg =[info objectForKey:UIImagePickerControllerOriginalImage];
    if (self.photoInfo.photoImg != nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入图片名称" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField *txtName = [alert textFieldAtIndex:0];
        txtName.returnKeyType = UIReturnKeyDone;
        
        NSString *dateStr = [[NSDate date] formattedDateYearYueRi:@"yyyy-MM-dd"];
        NSInteger currentCount =[[NSUserDefaults standardUserDefaults] integerForKey:dateStr];
        currentCount += 1;
        self.defaultText = [dateStr stringByAppendingFormat:@"-%zd",currentCount];
        txtName.text = self.defaultText;
        
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
        
        PhotoModel *photo = [[PhotoModel alloc] init];
        photo.photoImg = self.photoInfo.photoImg;
        photo.photoDate = [[NSDate date] formattedDateYearYueRi:@"yyyy-MM-dd"];
        
        if ([txt.text.trim isEqualToString:self.defaultText]) {
            NSInteger currentCount =[[NSUserDefaults standardUserDefaults] integerForKey:photo.photoDate];
            currentCount += 1;
            [[NSUserDefaults standardUserDefaults] setInteger:currentCount forKey:photo.photoDate];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
        photo.photoName = txt.text.trim;
        [self selectSaveFileName:[self.fileName cacheWithPath] withPhoto:photo];
    }
}

- (void)selectSaveFileName:(NSString *)fileName withPhoto:(PhotoModel *) photo
{
    [self savePhotoFileName:fileName withPhotos:[NSMutableArray arrayWithObject:photo]];
}

- (void) savePhotoFileName: (NSString *) fileName withPhotos:(NSMutableArray *) photos
{
    [self showHudInView:self.view hint:@"操作中.."];
    __weak typeof(self)  bSelf= self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        BOOL isScueess = [bSelf archiverPhotoInfo:fileName withPhotos:photos];
        if (isScueess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (sheetCount != 3) {
                    [dataArray addObjectsFromArray:photos];
                    if (showStyle == ListShowCollectionView) {
                        [collectionV reloadData];
                    } else {
                        [tabView reloadData];
                    }
                    
                } else {
                    [bSelf rightNavBarItemPressed];
                }
                
                [bSelf showHint:@"操作成功"];
                [bSelf hideHud];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [bSelf showHint:@"操作失败"];
                [bSelf hideHud];
            });
        }
        
        
    });
}

- (BOOL) archiverPhotoInfo:(NSString *) fileName withPhotos:(NSMutableArray *) photos
{
    BOOL isSuccess = YES;
    for (int i = 0; i<photos.count; i++) {
        //1.创建一个可变的二进制流
        NSMutableData *data=[[NSMutableData alloc]init];
        //2.创建一个归档对象(有将自定义类转化为二进制流的功能)
        NSKeyedArchiver *archiver=[[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
        //3.用该归档对象，把自定义类的对象，转为二进制流
        [archiver encodeObject:photos[i] forKey:@"photo"];
        //4归档完毕
        [archiver finishEncoding];
        //将data写入文件
        NSMutableArray *writeArr = [NSMutableArray arrayWithContentsOfFile:fileName];
        if (writeArr == nil) {
            writeArr = [NSMutableArray array];
            
        }
        [writeArr addObject:data];
        if (![writeArr writeToFile:fileName atomically:YES]) {
            isSuccess = NO;
        }
    }
   
    return isSuccess;
}


- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    sheetCount = buttonIndex;
    
    switch (buttonIndex) {
        case 0:
            if (dataArray.count == 0) {
                [self addPhoto];
            } else {
                // OCR
            }
            break;
           case 1:
            if (dataArray.count == 0) {
                [self centerButtonClick];
            } else {
                [self addPhoto];
            }
            break;
            case 2:
            [self centerButtonClick];
            break;
            case 3:
            [self rightBtnStatuChange];
            break;
            case 4:
            [self rightBtnStatuChange];
            break;
        default:
            break;
    }
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (!isLoading) {
        if (dataArray.count == 0) {
            [collectionView tableViewDisplayWitMsg:@"暂无图片" ifNecessaryForRowCount:dataArray.count];
        } else {
            if (collectionView.backgroundView) {
                [collectionView tableViewDisplayWitMsg:@"暂无图片" ifNecessaryForRowCount:dataArray.count];
            }
        }
    }
    
    
     return dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellDef = @"photoCell";
    PhotoItemCell *myCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellDef forIndexPath:indexPath];
    if (isDel) {
        myCell.delBtn.hidden = NO;
        myCell.delBtn.enabled = YES;
        
        if ([self.indexSets containsIndex:indexPath.item]) {
            [myCell.delBtn setImage:[UIImage imageNamed:@"man"] forState:UIControlStateNormal];
        } else {
            [myCell.delBtn setImage:[UIImage imageNamed:@"null"] forState:UIControlStateNormal];
        }
        
    } else {
        myCell.delBtn.hidden = YES;
        myCell.delBtn.enabled = NO;
    }
    [myCell.delBtn addTarget:self action:@selector(delFilePhoto:) forControlEvents:UIControlEventTouchUpInside];
    myCell.delBtn.tag = indexPath.item;
    PhotoModel *photoInfo = dataArray[indexPath.item];
    myCell.imgV.image = photoInfo.photoImg;
    myCell.lblName.text = photoInfo.photoName;
    
//    myCell.imgV.userInteractionEnabled = YES;
//    myCell.imgV.tag = indexPath.item;
//    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longImgVGesture:)];
//    longGesture.minimumPressDuration = 0.5;
//    [myCell.imgV addGestureRecognizer:longGesture];
    
    return myCell;
}

- (void) deletePhtoWithRow:(NSInteger) photoRow
{
    [self deleteCacheData:photoRow];
    [dataArray removeObjectAtIndex:photoRow];
    [collectionV deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:photoRow inSection:0]]];
}

- (void) delFilePhoto:(UIButton *) sender
{
    if ([self.indexSets containsIndex:sender.tag]) {
        [self.indexSets removeIndex:sender.tag];
    } else {
        [self.indexSets addIndex:sender.tag];
    }
    
    if (sheetCount == 3) {
        
        [downBtn setTitle:[NSString stringWithFormat:@"移动(共%zd张)",self.indexSets.count] forState:UIControlStateNormal];
    } else {
        [downBtn setTitle:[NSString stringWithFormat:@"删除(共%zd张)",self.indexSets.count] forState:UIControlStateNormal];
    }
    if (showStyle == ListShowCollectionView) {
        [collectionV reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:sender.tag inSection:0]]];
    } else {
        [tabView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:sender.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
    
}

- (void) deleteCacheData:(NSInteger) row
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:[self.fileName cacheWithPath]];
        [array removeObjectAtIndex:row];
        [array writeToFile:[self.fileName cacheWithPath] atomically:YES];
    });
   
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    XLPhotoBrowser *browser = [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:indexPath.item imageCount:dataArray.count datasource:self];
    browser.browserStyle = XLPhotoBrowserStyleIndexLabel;
    
    // 设置长按手势弹出的地步ActionSheet数据,不实现此方法则没有长按手势
    [browser setActionSheetWithTitle:@"操作列表" delegate:self cancelButtonTitle:nil deleteButtonTitle:nil otherButtonTitles:@"发送给朋友",@"保存图片",nil];
}

#pragma mark    -   XLPhotoBrowserDatasource

- (void)photoBrowser:(XLPhotoBrowser *)browser clickActionSheetIndex:(NSInteger)actionSheetindex currentImageIndex:(NSInteger)currentImageIndex
{
    switch (actionSheetindex) {
        case 0:
           // [self deletePhtoWithRow:currentImageIndex];
            break;
        case 1:
            [browser saveCurrentShowImage];
            break;
        default:
            break;
    }
}

- (UIImage *)photoBrowser:(XLPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    PhotoModel *photoInfo = dataArray[index];
    return photoInfo.photoImg;
}

- (UIView *)photoBrowser:(XLPhotoBrowser *)browser sourceImageViewForIndex:(NSInteger)index
{
    if (showStyle == ListShowCollectionView) {
        PhotoItemCell *myCell =(PhotoItemCell *) [collectionV cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        
        return myCell.imgV;
    } else {
        PhotoCell *myCell =(PhotoCell *) [tabView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        
        return myCell.photoImagV;
    }
    
}





// 添加图片
- (void) addReplyMenuShow
{
    if (pubView == nil) {
        pubView =[[PublicView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [self.appDelegate.window addSubview:pubView];
        
        [pubView.btn1 addTarget:self action:@selector(publicGongGaoAction:) forControlEvents:UIControlEventTouchUpInside];
        [pubView.btn2 addTarget:self action:@selector(publicGongGaoAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    [pubView showPublicView];
}

- (void) publicGongGaoAction:(UIButton *) sender
{
    [pubView hiddenPublicView];
    if (sender.tag == 50) {
        
        MyPhotoViewController *photoVC = [[MyPhotoViewController alloc] init];
        photoVC.delegate = self;
        LONavVC *nav = [[LONavVC alloc] initWithRootViewController:photoVC];
        [self presentViewController:nav animated:YES completion:nil];
        
    } else {
        
        UIImagePickerController *imgVC = [[UIImagePickerController alloc] init];
        imgVC.allowsEditing = NO;
        imgVC.delegate = self;
        [imgVC setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self presentViewController:imgVC animated:YES completion:nil];
        
    }
}

#pragma MyPhotoViewController 完成选择
- (void)finishPhotoWithSelectPhotos:(NSMutableArray *)photos deleteIndexs:(NSMutableIndexSet *)indexSets
{
    [self savePhotoFileName:[self.fileName cacheWithPath] withPhotos:photos];
    
     __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [wself deleteWithIndexSets:indexSets withFileName:@"我的图库"];
    });
    
}

- (BOOL) deleteWithIndexSets:(NSMutableIndexSet *) indexSets withFileName:(NSString *) fileName
{
   
    NSMutableArray *imgArray = [NSMutableArray arrayWithContentsOfFile:[fileName cacheWithPath]];
    [imgArray removeObjectsAtIndexes:indexSets];
    if ([imgArray writeToFile:[fileName cacheWithPath] atomically:YES]) {
        
        return YES;
    }
   
    return NO;
}

// downbtn 方法
- (void) downBtnAction:(UIButton *) sender
{
    if (self.indexSets.count == 0) {
        [self showHint:@"请选择图片"];
        return;
    }
    if (sheetCount == 3) { // 移动
        
        SaveImageToFileViewController *saveVC = [[SaveImageToFileViewController alloc] initWithFileName:self.fileName];
        saveVC.delegate = self;
        [self presentViewController:saveVC animated:YES completion:nil];
        
    } else { // 删除
        __weak typeof(self) wself = self;
        [self showHudInView:self.view hint:@"删除中..."];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            if ([wself deleteWithIndexSets:wself.indexSets withFileName:self.fileName]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [wself hideHud];
                    [wself showHint:@"删除成功"];
                    [dataArray removeObjectsAtIndexes:wself.indexSets];
                    [wself rightNavBarItemPressed];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [wself hideHud];
                    [wself showHint:@"删除失败"];
                });
            }
        });
    }
}

- (void)selectSaveFileName:(NSString *)fileName
{
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if ([wself deleteWithIndexSets:[[NSMutableIndexSet alloc] initWithIndexSet:wself.indexSets] withFileName:wself.fileName]) {
            
        }
    });
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:self.indexSets.count];
    [self.indexSets enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [arr addObject:dataArray[idx]];
    }];
    [self savePhotoFileName:[fileName cacheWithPath] withPhotos:arr];
    [dataArray removeObjectsAtIndexes:self.indexSets];
    
}






#pragma TABDATASOURE

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!isLoading) {
        if (dataArray.count == 0) {
            [tableView tableViewDisplayWitMsg:@"图库暂无照片" ifNecessaryForRowCount:dataArray.count];
        } else {
            if (tableView.backgroundView) {
                [tableView tableViewDisplayWitMsg:@"图库暂无照片" ifNecessaryForRowCount:dataArray.count];
            }
        }
    }
    
   return dataArray.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellDef = @"photoCell";
    PhotoCell *myCell = [tabView dequeueReusableCellWithIdentifier:cellDef];
    if (isDel) {
        myCell.selectBtnContraintW.constant = 25;
        myCell.selctBtnContraintX.constant = 10;
        if ([self.indexSets containsIndex:indexPath.row]) {
            [myCell.selectBtn setImage:[UIImage imageNamed:@"man"] forState:UIControlStateNormal];
        } else {
            [myCell.selectBtn setImage:[UIImage imageNamed:@"null"] forState:UIControlStateNormal];
        }
        
    } else {
        myCell.selectBtnContraintW.constant = 0;
        myCell.selctBtnContraintX.constant = 0;
    }
    [myCell.selectBtn addTarget:self action:@selector(delFilePhoto:) forControlEvents:UIControlEventTouchUpInside];
    myCell.selectBtn.tag = indexPath.row;
    PhotoModel *photoInfo = dataArray[indexPath.item];
    myCell.photoImagV.image = photoInfo.photoImg;
    myCell.lblName.text = photoInfo.photoName;
    return myCell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tabView deselectRowAtIndexPath:indexPath animated:YES];
    XLPhotoBrowser *browser = [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:indexPath.item imageCount:dataArray.count datasource:self];
    browser.browserStyle = XLPhotoBrowserStyleIndexLabel;
    
    // 设置长按手势弹出的地步ActionSheet数据,不实现此方法则没有长按手势
    [browser setActionSheetWithTitle:@"操作列表" delegate:self cancelButtonTitle:nil deleteButtonTitle:nil otherButtonTitles:@"发送给朋友",@"保存图片",nil];
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
