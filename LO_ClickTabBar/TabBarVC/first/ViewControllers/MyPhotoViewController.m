//
//  MyPhotoViewController.m
//  LO_ClickTabBar
//
//  Created by ejt_ios on 2017/6/26.
//  Copyright © 2017年 ejt_ios. All rights reserved.
//

#import "MyPhotoViewController.h"

#import "PhotoItemCell.h"
#import "XLPhotoBrowser.h"
#import "PhotoModel.h"
#import "UICollectionView+EmptyData.h"
#import "NSDate+Category.h"


static NSInteger rowCount = 3;
static CGFloat marginX = 5;
static CGFloat marginY = 5;

@interface MyPhotoViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,XLPhotoBrowserDelegate,XLPhotoBrowserDatasource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UICollectionView *collectionV;
    NSMutableArray *dataArray;
    NSMutableArray *selectArray;
    BOOL isLoading;
    UIButton *rightBtn;
    
}

@property (nonatomic ,strong) NSMutableIndexSet *indexSets;

@end

@implementation MyPhotoViewController

- (NSMutableIndexSet *)indexSets
{
    if (!_indexSets) {
        _indexSets = [[NSMutableIndexSet alloc] init];
    }
    return _indexSets;
}

- (void)dealloc
{
    _delegate = nil;
}

- (void) rightNavBarItemPressed
{
    if (selectArray.count == 0) {
        [self showHint:@"请选择图片"];
        return;
    }
    if (_delegate) {
        [_delegate finishPhotoWithSelectPhotos:selectArray deleteIndexs:self.indexSets];
    }
    [self leftNavBarItemPressed];
}
- (void)leftNavBarItemPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"我的图库";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UIButton * leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 30 )];
    [leftBtn setShowsTouchWhenHighlighted:YES];
    [leftBtn addTarget:self action:@selector(leftNavBarItemPressed) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setImage:[UIImage imageNamed:@"backs"] forState:UIControlStateNormal];
  
    [leftBtn setImage:nil forState:UIControlStateHighlighted];
    leftBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [rightBtn setShowsTouchWhenHighlighted:YES];
    
    [rightBtn addTarget:self action:@selector(rightNavBarItemPressed) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    isLoading = YES;
    
    dataArray = [[NSMutableArray alloc] init];
    selectArray = [NSMutableArray array];
    
    [self loadPhotoData];
    
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
    
   
}
// 加载数据
- (void) loadPhotoData
{
    [self showHudInView:self.view hint:@"加载中"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if ([self getCacheImgae]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                [collectionV reloadData];
            });
        }
    });
}
- (BOOL) getCacheImgae
{
    if (dataArray.count>0) {
        [dataArray removeAllObjects];
    }
    NSMutableArray *imgArray = [NSMutableArray arrayWithContentsOfFile:[@"我的图库" cacheWithPath]];
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



#pragma collectionView dataSoure
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
    [myCell.delBtn addTarget:self action:@selector(delFilePhoto:) forControlEvents:UIControlEventTouchUpInside];
    myCell.delBtn.tag = indexPath.item;
   
    PhotoModel *photoInfo = dataArray[indexPath.item];
    
    if ([selectArray containsObject:photoInfo]) {
        [myCell.delBtn setImage:[UIImage imageNamed:@"man"] forState:UIControlStateNormal];
    } else {
        [myCell.delBtn setImage:[UIImage imageNamed:@"null"] forState:UIControlStateNormal];
    }
    
    myCell.imgV.image = photoInfo.photoImg;
    myCell.lblName.text = photoInfo.photoName;
    
    return myCell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    XLPhotoBrowser *browser = [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:indexPath.item imageCount:dataArray.count datasource:self];
    browser.browserStyle = XLPhotoBrowserStyleIndexLabel;
}

- (void) delFilePhoto:(UIButton *) sender
{
    PhotoModel *photoInfo = dataArray[sender.tag];
    if ([selectArray containsObject:photoInfo]) {
        [selectArray removeObject:photoInfo];
        [self.indexSets removeIndex:sender.tag];
    } else {
        [selectArray addObject:photoInfo];
        [self.indexSets addIndex:sender.tag];
    }
   
    [collectionV reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:sender.tag inSection:0]]];
}


#pragma mark    -   XLPhotoBrowserDatasource

- (UIImage *)photoBrowser:(XLPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    PhotoModel *photoInfo = dataArray[index];
    return photoInfo.photoImg;
}

- (UIView *)photoBrowser:(XLPhotoBrowser *)browser sourceImageViewForIndex:(NSInteger)index
{
    PhotoItemCell *myCell =(PhotoItemCell *) [collectionV cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    
    return myCell.imgV;
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
