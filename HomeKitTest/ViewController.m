//
//  ViewController.m
//  HomeKitTest
//
//  Created by hhliu on 2018/7/23.
//  Copyright © 2018年 hhliu. All rights reserved.
//

#import "ViewController.h"

#import "RoomViewController.h"

#import <HomeKit/HomeKit.h>

@interface ViewController ()
<HMHomeManagerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) HMHomeManager *homeManager;
@property (nonatomic,strong) NSArray *homes; // home列表

@property (nonatomic,readonly) UITableView *tableView;


@end

@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  
  self.view.backgroundColor = [UIColor lightGrayColor];
  
  self.homeManager = [[HMHomeManager alloc] init];
  self.homeManager.delegate = self;
  
  [self loadTableView];
}

- (void)loadTableView
{
  
  UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 64, 80, 35)];
  [button setTitle:@"添加" forState:UIControlStateNormal];
  [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
  
  [button addTarget:self action:@selector(addNewHome) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:button];
  
  UIButton *removeButton = [[UIButton alloc] initWithFrame:CGRectMake(110, 64, 80, 35)];
  [removeButton setTitle:@"移除" forState:UIControlStateNormal];
  [removeButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
  
  [removeButton addTarget:self action:@selector(removeHome) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:removeButton];
  
  CGFloat width = [[UIScreen mainScreen] bounds].size.width;
  CGFloat height = [[UIScreen mainScreen] bounds].size.height;
  
  _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 110, width, height - 110)];
  _tableView.delegate = self;
  _tableView.dataSource = self;
  
  [self.view addSubview:_tableView];
}

- (void)removeHome
{
  [self.homeManager removeHome:self.homeManager.primaryHome completionHandler:^(NSError * _Nullable error) {
    [self reloadTableView];
    
  }];
}
- (void)addNewHome
{
  
  __block ViewController *blockSelf = self;
  
  UIAlertController *inputNameAlter = [UIAlertController alertControllerWithTitle:@"请输入新home的名字" message:@"请确保这个名字的唯一性" preferredStyle:1];
  
  [inputNameAlter addTextFieldWithConfigurationHandler:^(UITextField *textField){
    textField.placeholder = @"请输入新家的名字";
  }];
  
  UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:0 handler:^(UIAlertAction * _Nonnull action) {
  }];
  UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:0 handler:^(UIAlertAction * _Nonnull action) {
    NSString *newName =inputNameAlter.textFields.firstObject.text;
    [self.homeManager addHomeWithName:newName completionHandler:^(HMHome * _Nullable home, NSError * _Nullable error) {
      
      [blockSelf reloadTableView];
      
      NSLog(@"%@",error);
    }];
    
  }];
  [inputNameAlter addAction:action1];
  [inputNameAlter addAction:action2];
  [self presentViewController:inputNameAlter animated:YES completion:^{}];
}

- (void)reloadTableView
{
  self.homes = self.homeManager.homes;
  [self.tableView reloadData];
}


#pragma mark -
#pragma mark HMHomeManager代理方法（4个）
- (void)homeManagerDidUpdateHomes:(HMHomeManager *)manager
{
  [self reloadTableView];
  NSLog(@"已经获取到homes数据：%@",manager.homes);
}
- (void)homeManagerDidUpdatePrimaryHome:(HMHomeManager *)manager
{
  NSLog(@"已经更新了primaryHome：%@",manager.primaryHome);
}
- (void)homeManager:(HMHomeManager *)manager didAddHome:(HMHome *)home
{
  NSLog(@"已经添加了home：%@",home);
}
- (void)homeManager:(HMHomeManager *)manager didRemoveHome:(HMHome *)home
{
  NSLog(@"已经移除了home：%@",home);
}

#pragma mark -
#pragma mark UITableView代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.homes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeCell"];
  
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"HomeCell"];
  }
  
  HMHome *home = self.homes[indexPath.row];
  
  cell.textLabel.text = home.name;
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  RoomViewController *controller = [[RoomViewController alloc] init];
  
  controller.home = self.homes[indexPath.row];
  
  [self.navigationController pushViewController:controller animated:YES];
  
}


@end
