//
//  LOTabBarVC.m
//  LO_ClickTabBar
//
//  Created by ejt_ios on 2017/6/5.
//  Copyright © 2017年 ejt_ios. All rights reserved.
//

#import "LOTabBarVC.h"
#import "LOTabBar.h"
#import "OneVC.h"
#import "TwoVC.h"
#import "LONavVC.h"
#import "CameraViewController.h"

@interface LOTabBarVC ()<LOTabBarDelegate,UITabBarControllerDelegate>

@end

@implementation LOTabBarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置tintColor -> 统一设置tabBar的选中颜色
    // 越早设置越好，一般放到AppDelegate中
    // 或者：设置图片渲染模式、设置tabBar文字
    [[UITabBar appearance] setTintColor:[UIColor orangeColor]];
    [[UITabBar appearance] setShadowImage:[UIImage new]];

    
    LOTabBar *tabBar = [[LOTabBar alloc] init];
    tabBar.loBarDelegate = self;
    self.delegate = self;
    // self.tabBar只读，使用kvc给只读属性赋值
    [self setValue:tabBar forKey:@"tabBar"];
    
    [self addChildViewController:[[OneVC alloc] init] text:@"图库" imageName:@"tabbar1"];
    [self addChildViewController:nil text:@"" imageName:@""];
    [self addChildViewController:[[TwoVC alloc] init] text:@"我的" imageName:@"tabbar4"];

    
    
    [tabBar updateFrame];
    
}
// 点击中间时不跳转
- (BOOL) tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    LONavVC *nav = (LONavVC *) viewController;
    
    if (nav.viewControllers.count == 0) {
        [self centerButtonClick];
        return NO;
    }
    return YES;
}

- (void) addChildViewController:(UIViewController *) childController text:(NSString *) text imageName:(NSString *) imageName
{
    if (childController == nil) {
        LONavVC *nav = [[LONavVC alloc] init];
        [self addChildViewController:nav];
        return;
    }
    
    // 设置item图片不渲染
    childController.tabBarItem.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childController.tabBarItem.selectedImage = [[UIImage imageNamed:[imageName stringByAppendingString:@"_press"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // 设置标题的属性
    [childController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:12] forKey:NSFontAttributeName] forState:UIControlStateNormal];
    [childController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:THEME_COLOR forKey:NSForegroundColorAttributeName] forState:UIControlStateSelected];
    
    // 设置item的标题
    childController.tabBarItem.title = text;
    childController.navigationItem.title = text;
    
    LONavVC *nav = [[LONavVC alloc] initWithRootViewController:childController];
    [self addChildViewController:nav];
}

- (void)centerButtonClick
{
    NSLog(@"点击了中心的大加号按扭");
    CameraViewController *cameraVC = [[CameraViewController alloc] init];
    LONavVC *nav = [[LONavVC alloc] initWithRootViewController:cameraVC];
    cameraVC.navigationItem.title = @"文档拍照";
    [self presentViewController:nav animated:YES completion:nil];
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
