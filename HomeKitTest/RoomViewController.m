//
//  RoomViewController.m
//  HomeKitTest
//
//  Created by hhliu on 2018/7/23.
//  Copyright © 2018年 hhliu. All rights reserved.
//

#import "RoomViewController.h"

@interface RoomViewController ()
<HMHomeDelegate,HMAccessoryBrowserDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) HMAccessoryBrowser *browser;
@property (nonatomic,strong) NSMutableArray *accArray;

@property (nonatomic,readonly) UITableView *tableView;

@end

@implementation RoomViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor whiteColor];
  
  UIButton *addRoomButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 64, 80, 35)];
  [addRoomButton setTitle:@"添加房间" forState:UIControlStateNormal];
  [addRoomButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
  
  [addRoomButton addTarget:self action:@selector(addNewRoom) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:addRoomButton];
  
  UIButton *allRoomButton = [[UIButton alloc] initWithFrame:CGRectMake(120, 64, 80, 35)];
  [allRoomButton setTitle:@"查看房间" forState:UIControlStateNormal];
  [allRoomButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
  
  [allRoomButton addTarget:self action:@selector(showAllRoom) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:allRoomButton];
  
  UIButton *removeButton = [[UIButton alloc] initWithFrame:CGRectMake(210, 64, 80, 35)];
  [removeButton setTitle:@"移除房间" forState:UIControlStateNormal];
  [removeButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
  
  [removeButton addTarget:self action:@selector(removeRoom) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:removeButton];
  
  [self searchAllAccessory];
  
  CGFloat width = [[UIScreen mainScreen] bounds].size.width;
  CGFloat height = [[UIScreen mainScreen] bounds].size.height;
  
  _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 110, width, height - 110)];
  _tableView.delegate = self;
  _tableView.dataSource = self;
  
  [self.view addSubview:_tableView];
  
  self.browser = [[HMAccessoryBrowser alloc] init];
  self.browser.delegate = self;
  
}

/* 添加一个房间 */
- (void)addNewRoom
{
  UIAlertController *inputNameAlter = [UIAlertController alertControllerWithTitle:@"请输入新home的名字" message:@"请确保这个名字的唯一性" preferredStyle:1];
  
  [inputNameAlter addTextFieldWithConfigurationHandler:^(UITextField *textField){
    textField.placeholder = @"请输入新家的名字";
  }];
  
  UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:0 handler:^(UIAlertAction * _Nonnull action) {
  }];
  UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:0 handler:^(UIAlertAction * _Nonnull action) {
    NSString *newName =inputNameAlter.textFields.firstObject.text;
    [self.home addRoomWithName:newName completionHandler:^(HMRoom * _Nullable room, NSError * _Nullable error) {
      
    }];
    
  }];
  [inputNameAlter addAction:action1];
  [inputNameAlter addAction:action2];
  [self presentViewController:inputNameAlter animated:YES completion:^{}];
}

/* 显示所有的房间 */
- (void)showAllRoom
{
  NSArray *rooms =self.home.rooms;
  /*  展示得到的home   */
  UIAlertController *roomList = [UIAlertController alertControllerWithTitle:@"" message:@"我的所有home" preferredStyle:0];
  for (int a=0; a<rooms.count; a++) {
    HMRoom *room = rooms[a];
    NSString *name = room.name;
    UIAlertAction *action = [UIAlertAction actionWithTitle:name style:0 handler:^(UIAlertAction * _Nonnull action) {
    }];
    [roomList addAction:action];
  }
  UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:0 handler:^(UIAlertAction * _Nonnull action) {
  }];
  [roomList addAction:action1];
  [self presentViewController:roomList animated:YES completion:^{}];
}

/* 移除房间  */
- (void)removeRoom
{
  /* 每次删除第一个房间 */
  [self.home removeRoom:[self.home.rooms firstObject] completionHandler:^(NSError * _Nullable error) {
    
  }];
}

/* home中所有设备，搜索未添加的设备 */
- (void)searchAllAccessory
{
  
  /* home中的设备 */
  _accArray = [NSMutableArray arrayWithArray:self.home.accessories];
  
  if (!_accArray) {
    /* home中设备为空，搜索未添加的设备  */
    _accArray = [NSMutableArray array];
    [self.browser startSearchingForNewAccessories];
  }
  [_tableView reloadData];
}

#pragma mark -
#pragma mark HMAccessoryBrowser代理方法
- (void)accessoryBrowser:(HMAccessoryBrowser *)browser didFindNewAccessory:(HMAccessory *)accessory
{
  NSLog(@"发现一个新的硬件");
  
  [_accArray addObject:accessory];
  [_tableView reloadData];
}

- (void)accessoryBrowser:(HMAccessoryBrowser *)browser didRemoveNewAccessory:(HMAccessory *)accessory
{
  [_accArray removeObject:accessory];
  [_tableView reloadData];
  NSLog(@"一个硬件已移除");
}

#pragma mark -
#pragma mark home代理方法
- (void)homeDidUpdateName:(HMHome *)home
{
  NSLog(@"已经更换了home的名字");
}
- (void)home:(HMHome *)home didAddAccessory:(HMAccessory *)accessory
{
  NSLog(@"已经添加了，智能设备");
}
- (void)home:(HMHome *)home didRemoveAccessory:(HMAccessory *)accessor
{
  NSLog(@"已经移除了智能设备");
}

- (void)home:(HMHome *)home didAddUser:(HMUser *)user
{
  NSLog(@"已经添加用户");
}
- (void)home:(HMHome *)home didRemoveUser:(HMUser *)user
{
  NSLog(@"已经移除了用户");
}
- (void)home:(HMHome *)home didUpdateRoom:(HMRoom *)room forAccessory:(HMAccessory *)accessory
{
  NSLog(@"一个新房间，添加了一个智能设备");
}
- (void)home:(HMHome *)home didAddRoom:(HMRoom *)room
{
  NSLog(@"已经添加了房间 ");
}
- (void)home:(HMHome *)home didRemoveRoom:(HMRoom *)room
{
  NSLog(@"已经移除了房间");
}
- (void)home:(HMHome *)home didUpdateNameForRoom:(HMRoom *)room
{
  NSLog(@"已经为一个房间更新了名字");
}
- (void)home:(HMHome *)home didAddZone:(HMZone *)zone
{
  NSLog(@"已经添加了一个空间");
}
- (void)home:(HMHome *)home didRemoveZone:(HMZone *)zone
{
  NSLog(@"已经移除了一个空间");
}
- (void)home:(HMHome *)home didUpdateNameForZone:(HMZone *)zone
{
  NSLog(@"已经为一个空间更改了名字");
}
- (void)home:(HMHome *)home didAddRoom:(HMRoom *)room toZone:(HMZone *)zone
{
  NSLog(@"已经添加了一个房间到一个空间");
}
- (void)home:(HMHome *)home didRemoveRoom:(HMRoom *)room fromZone:(HMZone *)zone
{
  NSLog(@"已经从一个空间移除了一个房间");
}
- (void)home:(HMHome *)home didAddServiceGroup:(HMServiceGroup *)group
{
  NSLog(@"已经添加了一个服务组");
}
- (void)home:(HMHome *)home didRemoveServiceGroup:(HMServiceGroup *)group
{
  NSLog(@"已经移除了一个服务组");
}
- (void)home:(HMHome *)home didUpdateNameForServiceGroup:(HMServiceGroup *)group
{
  NSLog(@"已经为一个服务组更改了名字");
}
- (void)home:(HMHome *)home didAddService:(HMService *)service toServiceGroup:(HMServiceGroup *)group
{
  NSLog(@"已经为一个服务组添加了一个服务");
}
- (void)home:(HMHome *)home didRemoveService:(HMService *)service fromServiceGroup:(HMServiceGroup *)group
{
  NSLog(@"已经为一个服务组移除了一个服务");
}

- (void)home:(HMHome *)home didAddActionSet:(HMActionSet *)actionSet
{
  NSLog(@"已经添加了一个动作组");
}
- (void)home:(HMHome *)home didRemoveActionSet:(HMActionSet *)actionSet
{
  NSLog(@"已经移除了一个动作组");
}
- (void)home:(HMHome *)home didUpdateNameForActionSet:(HMActionSet *)actionSet
{
  NSLog(@"已经为一个设置组添加了名字");
}
- (void)home:(HMHome *)home didUpdateActionsForActionSet:(HMActionSet *)actionSet
{
  NSLog(@"已经为一个设置组更新了一个设置动作");
}
- (void)home:(HMHome *)home didAddTrigger:(HMTrigger *)trigger
{
  NSLog(@"已经添加了一个触发器");
}
- (void)home:(HMHome *)home didRemoveTrigger:(HMTrigger *)trigger
{
  NSLog(@"已经移除了一个触发器");
}

- (void)home:(HMHome *)home didUpdateNameForTrigger:(HMTrigger *)trigg
{
  NSLog(@"已经移除了一个触发器");
}
- (void)home:(HMHome *)home didUpdateTrigger:(HMTrigger *)trigger
{
  NSLog(@"已经更新了触发器");
}
- (void)home:(HMHome *)home didUnblockAccessory:(HMAccessory *)accessor
{
  NSLog(@"已经接通了智能设备");
}
- (void)home:(HMHome *)home didEncounterError:(NSError*)error forAccessory:(HMAccessory *)accessory
{
  NSLog(@"已经遇到错误");
}


#pragma mark -
#pragma mark UITableView代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.accArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeCell"];
  
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"HomeCell"];
  }
  
  HMAccessory *acc = self.accArray[indexPath.row];
  
  cell.textLabel.text = acc.name;
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  HMAccessory *accessory = self.accArray[indexPath.row];
  
  /* 设备必须添加进入房间活家后才有服务  */
  NSArray *serviceArray = accessory.services;
  
  
  for (HMService *service in serviceArray) {
    
    NSLog(@"服务的名字为 ：%@",service.name);
    
    NSArray *chas =  service.characteristics;
    
    for (HMCharacteristic *chara in chas) {
      
      NSLog(@"-----%@-----%@",chara.localizedDescription,chara.value);
      
      /* 特性改变 value */
      [chara writeValue:@(15) completionHandler:^(NSError * _Nullable error) {
        
      }];
    }
  }
  
  HMRoom *room = [self.home.rooms firstObject];
  
  /* 设备添加到房间  */
  [self.home assignAccessory:accessory toRoom:room completionHandler:^(NSError * _Nullable error) {
    
  }];
  
  /* 设备添加到家庭 */
  [self.home addAccessory:accessory completionHandler:^(NSError * _Nullable error) {
    if (error) {
      NSLog(@"添加失败！%@",error);
    }
    else {
      NSLog(@"添加成功");
    }
  }];
}




@end
