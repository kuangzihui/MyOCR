//
//  OneVC.m
//  LO_ClickTabBar
//
//  Created by ejt_ios on 2017/6/5.
//  Copyright © 2017年 ejt_ios. All rights reserved.
//

#import "OneVC.h"
#import "LOPhotoViewController.h"
#import "UITableView+EmptyData.h"

@interface OneVC ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    NSMutableArray *dataArray;
    UITableView *tableV;
    UIButton *rightBtn;
    NSInteger currentRow;
}
@end

@implementation OneVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appDelegate.clientID = @"1";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    dataArray = [[NSMutableArray alloc] init];
    
    rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    //[rightBtn setTitle:@"新建目录" forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"fileAdd"] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    rightBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [rightBtn setShowsTouchWhenHighlighted:YES];
    [rightBtn addTarget:self action:@selector(rightNavBarItemPressed) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    [self getCacheWithData];
    
    tableV = [[UITableView alloc] initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT-49) style:UITableViewStylePlain];
    tableV.delegate = self;
    tableV.dataSource = self;
    tableV.backgroundColor = [UIColor clearColor];
    tableV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [tableV registerClass:[UITableViewCell class] forCellReuseIdentifier:@"oneCell"];
    tableV.separatorColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:tableV];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileNameChange) name:FILE_NAME_CHANGE object:nil];
}

- (void) rightNavBarItemPressed
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"新建目录" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 100;
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *txtName = [alert textFieldAtIndex:0];
    txtName.returnKeyType = UIReturnKeyDone;
    txtName.placeholder = @"请输入目录名称";
    [alert show];
}

#pragma mark - 点击代理
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        UITextField *txt = [alertView textFieldAtIndex:0];
        
            if ([txt.text.trim isEmpty]) {
                [self showHint:@"目录名不能为空"];
                return;
            }
        if (alertView.tag == 100) {
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
            if ([arr writeToFile:[LO_FILE_NAME cacheWithPath] atomically:YES]) {
                [self showHint:@"添加成功"];
                [dataArray addObject:txt.text];
                [tableV reloadData];
            }
            
        } else {
            if (![txt.text.trim isEqualToString:dataArray[currentRow]]) {
                
                NSMutableArray *arr = [NSMutableArray arrayWithContentsOfFile:[LO_FILE_NAME cacheWithPath]];
                if ([arr containsObject:txt.text.trim]) {
                    [self showHint:@"目录名已存在"];
                    return;
                }
                
                if (arr == nil) {
                    arr = [NSMutableArray arrayWithObject:txt.text];
                } else {
                    [arr removeObjectAtIndex:currentRow];
                    [arr insertObject:txt.text.trim atIndex:currentRow];
                }
                
                if ([arr writeToFile:[LO_FILE_NAME cacheWithPath] atomically:YES]) {
                    
                    [self showHint:@"重命名成功"];
                    NSString *fileName = dataArray[currentRow];
                    
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        NSMutableArray *imgArray = [NSMutableArray arrayWithContentsOfFile:[fileName cacheWithPath]];
                        if (imgArray && imgArray.count > 0) {
                            
                            [imgArray writeToFile:[txt.text.trim cacheWithPath] atomically:YES];
                            
                            [imgArray removeAllObjects];
                            [imgArray writeToFile:[fileName cacheWithPath] atomically:YES];
                        }
                    });
                    
                    [dataArray removeObjectAtIndex:currentRow];
                    [dataArray insertObject:txt.text.trim atIndex:currentRow];
                    [tableV reloadData];
                }
            }
        }
        
    }
}



// 目录发生改变通知方法
- (void) fileNameChange
{
    [self getCacheWithData];
    [tableV reloadData];
}

- (void) getCacheWithData
{
    NSArray *array = [NSArray arrayWithContentsOfFile:[LO_FILE_NAME cacheWithPath]];
    
    if (array && array.count>0) {
        if (dataArray.count>0) {
            [dataArray removeAllObjects];
        }
        [dataArray addObjectsFromArray:array];
    }
}

- (void) deleteCacheData:(NSInteger) row
{
     NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:[LO_FILE_NAME cacheWithPath]];
     [array removeObjectAtIndex:row];
    [array writeToFile:[LO_FILE_NAME cacheWithPath] atomically:YES];
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 添加一个删除按钮
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        [tableView beginUpdates];
        
        [self deleteCacheData:indexPath.row];
        [dataArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [tableView endUpdates];
  
    }];
    
    // 添加一个更多按钮
    UITableViewRowAction *moreRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"重命名" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        currentRow = indexPath.row;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"重命名" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 200;
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField *txtName = [alert textFieldAtIndex:0];
        txtName.returnKeyType = UIReturnKeyDone;
        txtName.text = dataArray[indexPath.row];
        txtName.placeholder = @"请输入目录名称";
        [alert show];
        
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }];
    
    moreRowAction.backgroundColor = THEME_COLOR;
    
    return @[deleteRowAction,moreRowAction];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [tableView beginUpdates];
        
        [self deleteCacheData:indexPath.row];
        [dataArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        
        [tableView endUpdates];
        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (dataArray.count == 0) {
         [tableView tableViewDisplayWitMsg:@"图库暂无照片" ifNecessaryForRowCount:dataArray.count];
    } else {
        if (tableView.backgroundView) {
            [tableView tableViewDisplayWitMsg:@"图库暂无照片" ifNecessaryForRowCount:dataArray.count];
        }
        
    }
    return dataArray.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellDef = @"oneCell";
    UITableViewCell *myCell = [tableView dequeueReusableCellWithIdentifier:cellDef];
    if (myCell == nil) {
        myCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellDef];
    }
    if (indexPath.row == 0) {
        myCell.imageView.image = [UIImage imageNamed:@"defaultFile"];
    } else {
        myCell.imageView.image = [UIImage imageNamed:@"file"];
    }
    myCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    myCell.textLabel.text = dataArray[indexPath.row];
    myCell.textLabel.font = [UIFont systemFontOfSize:15];
    myCell.textLabel.textColor = [UIColor darkGrayColor];
    return myCell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LOPhotoViewController *photoVC = [[LOPhotoViewController alloc] initWithFileName:dataArray[indexPath.row]];
    [self.navigationController pushViewController:photoVC animated:YES];
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
