//
//  TwoVC.m
//  LO_ClickTabBar
//
//  Created by ejt_ios on 2017/6/5.
//  Copyright © 2017年 ejt_ios. All rights reserved.
//

#import "TwoVC.h"
#import "TableViewHeadView.h"
#import "LOUserLoginView.h"

static CGFloat imgH = 150;

@interface TwoVC ()<UITableViewDelegate,UITableViewDataSource>
{
    
}
@property(nonatomic,strong)NSArray *moreArray;
@property(nonatomic,strong)TableViewHeadView *headView;

@end

@implementation TwoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self onInitView];
}

-(void)onInitView{
    UITableView *moreTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-40) style:UITableViewStylePlain];
    moreTableView.delegate = self;
    moreTableView.dataSource = self;
    moreTableView.backgroundColor = [UIColor clearColor];
    moreTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    moreTableView.separatorColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:moreTableView];
    
    
    moreTableView.contentInset = UIEdgeInsetsMake(imgH, 0, 0, 0);
    self.headView = [TableViewHeadView loadHeadView];
    self.headView.frame = CGRectMake(0, -imgH, SCREEN_WIDTH, imgH);
    [moreTableView addSubview:_headView];
    
    if (!_moreArray) {
        _moreArray = [[NSArray alloc]initWithObjects:@"清理缓存",@"操作指南",@"偏好设置",nil];
    }
    
   
}

- (void) outLogin
{
    self.tabBarController.selectedIndex = 0;
    LOUserLoginView *loginView = [LOUserLoginView loadLoginView];
    [ self.appDelegate.window addSubview:loginView];

}

#pragma mark -TableView Delegate and Datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 1) {
        return 1;
    }
    return _moreArray.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 20;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        return 40;
    }
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *Identifier = @"Identifier";
    static NSString *Identifier1 = @"Identifier1";
    if (indexPath.section == 0) {
      UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:Identifier];
        if (cell==nil) {
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
            cell.textLabel.font = [UIFont systemFontOfSize:14];
        }
        
        cell.textLabel.text = _moreArray[indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    } else {
        UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:Identifier1];
        if (cell==nil) {
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier1];
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            UIButton *outBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            outBtn.frame = CGRectMake(20, 0, SCREEN_WIDTH-40, 40);
            [outBtn setBackgroundImage:[UIColor colorRepImageWithColor:THEME_COLOR] forState:UIControlStateNormal];
            [outBtn setBackgroundImage:[UIColor colorRepImageWithColor:LOGBTN_COLOR] forState:UIControlStateHighlighted];
            [outBtn setBackgroundImage:[UIColor colorRepImageWithColor:LOGBTN_COLOR] forState:UIControlStateSelected];
            [outBtn addTarget:self action:@selector(outLogin) forControlEvents:UIControlEventTouchUpInside];
            [outBtn setTitle:@"退出登录" forState:UIControlStateNormal];
            outBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
            outBtn.layer.cornerRadius = 5.0f;
            outBtn.layer.masksToBounds = YES;
            [outBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [cell.contentView addSubview:outBtn];
        }
        return cell;
    }
    
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat y = scrollView.contentOffset.y+64; //如果有导航控制器，这里应该加上导航控制器的高度64
    if (y< -imgH) {
        CGRect frame = _headView.frame;
        frame.origin.y = y;
        frame.size.height = -y;
        _headView.frame = frame;
    }
    
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
