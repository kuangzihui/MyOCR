//
//  SaveImageToFileViewController.m
//  LO_ClickTabBar
//
//  Created by ejt_ios on 2017/6/22.
//  Copyright © 2017年 ejt_ios. All rights reserved.
//

#import "SaveImageToFileViewController.h"
#import "UITableView+EmptyData.h"

@interface SaveImageToFileViewController ()
{
    UITableView *myTab;
    NSMutableArray *dataArray;
    UIButton *rightBtn;
    NSInteger selectRow;
    BOOL isLoading;
}
@end

@implementation SaveImageToFileViewController

- (void)dealloc
{
    _delegate = nil;
}

- (void) showView {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.view.frame;
        rect.origin.y = 0;
        self.view.frame = rect;
    }];
    
    selectRow = -10;
    if (rightBtn.tag == 200) {
        rightBtn.tag = 100;
        [rightBtn setTitle:@"新建目录" forState:UIControlStateNormal];
        [myTab reloadData];
    }
    
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
    
    CGRect rect = self.view.frame;
    rect.origin.y = SCREEN_HEIGHT;
    self.view.frame = rect;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    selectRow = -10;
    
    dataArray =[[NSMutableArray alloc] init];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    topView.backgroundColor = THEME_COLOR;
    [self.view addSubview:topView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"移到图片到";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [topView addSubview:titleLabel];
    
    rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-70, 20, 60, 44)];
    [rightBtn setTitle:@"新建目录" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    rightBtn.tag = 100;
    [rightBtn setShowsTouchWhenHighlighted:YES];
    [rightBtn addTarget:self action:@selector(rightNavBarItemPressed) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:rightBtn];
    
    
    UIButton * leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 60, 44)];
    [leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    leftBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [leftBtn setShowsTouchWhenHighlighted:YES];
    [leftBtn addTarget:self action:@selector(leftNavBarItemPressed) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:leftBtn];
    isLoading = YES;
    [self getCacheWithData];
    
    
    
    myTab = [[UITableView alloc] initWithFrame:CGRectMake(0,64, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStylePlain];
    myTab.delegate = self;
    myTab.dataSource = self;
    myTab.backgroundColor = [UIColor clearColor];
    myTab.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [myTab registerClass:[UITableViewCell class] forCellReuseIdentifier:@"oneCell"];
    [self.view addSubview:myTab];
    
}

- (void) getCacheWithData
{
    NSArray *array = [NSArray arrayWithContentsOfFile:[LO_FILE_NAME cacheWithPath]];
    
    if (array && array.count>0) {
        [dataArray addObjectsFromArray:array];
        if ([dataArray containsObject:self.fileName]) {
            [dataArray removeObject:self.fileName];
        }
    }
    isLoading = NO;
}

// 新建目录
- (void) rightNavBarItemPressed
{
    if (rightBtn.tag == 100) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"新建目录" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField *txtName = [alert textFieldAtIndex:0];
        txtName.returnKeyType = UIReturnKeyDone;
        txtName.placeholder = @"请输入目录名称";
        [alert show];
    } else {
        if (_delegate) {
            [_delegate selectSaveFileName:dataArray[selectRow]];
        }
        [self leftNavBarItemPressed];
    }
    
}

#pragma mark - 点击代理
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        UITextField *txt = [alertView textFieldAtIndex:0];
        if ([txt.text.trim isEmpty]) {
            [self showHint:@"目录名不能为空"];
            return;
        }
        //获取txt内容即可
        NSMutableArray *arr = [NSMutableArray arrayWithContentsOfFile:[LO_FILE_NAME cacheWithPath]];
        if ([arr containsObject:txt.text.trim]) {
            [self showHint:@"目录名已存在"];
            return;
        }
        if (arr == nil) {
            arr = [NSMutableArray arrayWithObject:txt.text];
        } else {
            [arr addObject:txt.text];
        }
        
        [arr writeToFile:[LO_FILE_NAME cacheWithPath] atomically:YES];
        [dataArray addObject:txt.text];
        selectRow = 0;
        rightBtn.tag = 200;
        [rightBtn setTitle:@"保存" forState:UIControlStateNormal];
        [myTab reloadData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:FILE_NAME_CHANGE object:nil];
    }
}

- (void) leftNavBarItemPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
//    [UIView animateWithDuration:0.3 animations:^{
//        
//        CGRect rect = self.view.frame;
//        rect.origin.y = SCREEN_HEIGHT;
//        self.view.frame = rect;
//        
//    } completion:^(BOOL finished) {
//        
//        [self.view removeFromSuperview];
//        
//    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!isLoading) {
        if (dataArray.count == 0) {
            [tableView tableViewDisplayWitMsg:@"暂无目录" ifNecessaryForRowCount:dataArray.count];
        } else {
            if (tableView.backgroundView) {
                [tableView tableViewDisplayWitMsg:@"暂无目录" ifNecessaryForRowCount:dataArray.count];
            }
        }
    }
    
    
    return dataArray.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellDef = @"oneCell";
    UITableViewCell *myCell = [tableView dequeueReusableCellWithIdentifier:cellDef];
    if (myCell == nil) {
        myCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellDef];
    }
    if (selectRow == indexPath.row) {
        myCell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        myCell.accessoryType = UITableViewCellAccessoryNone;
    }
    myCell.imageView.image = [UIImage imageNamed:@"file"];
    myCell.textLabel.font = [UIFont systemFontOfSize:15];
    myCell.textLabel.textColor = [UIColor darkGrayColor];
    myCell.textLabel.text = dataArray[indexPath.row];
    return myCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (selectRow == indexPath.row) {
        selectRow = -10;
        rightBtn.tag = 100;
        [rightBtn setTitle:@"新建目录" forState:UIControlStateNormal];
    } else {
        selectRow = indexPath.row;
        rightBtn.tag = 200;
        [rightBtn setTitle:@"保存" forState:UIControlStateNormal];
    }
    [tableView reloadData];
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
