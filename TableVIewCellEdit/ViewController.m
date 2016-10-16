//
//  ViewController.m
//  WatchApp_Learn
//
//  Created by 綦 on 16/9/29.
//  Copyright © 2016年 PowesunHolding. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

/**
 *  展示的数据
 */
@property (strong, nonatomic) NSMutableArray *dataArr;
/**
 *  选择的数据
 */
@property (strong, nonatomic) NSMutableArray *selectedDataArr;
/**
 *  UITableView控件
 */
@property (weak, nonatomic) UITableView *tableView;

@end

@implementation ViewController

#pragma mark - 属性方法
- (NSMutableArray *)dataArr
{
    if (_dataArr == nil) {
        _dataArr = [NSMutableArray arrayWithCapacity:1];
    }
    
    return _dataArr;
}
- (NSMutableArray *)selectedDataArr
{
    if (_selectedDataArr == nil) {
        _selectedDataArr = [NSMutableArray arrayWithCapacity:1];
    }
    
    return _selectedDataArr;
}

#pragma mark - 控制器周期
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置 UI
    [self settingUi];
}

#pragma mark - 自定义方法
/**
 *  设置 UI
 */
- (void)settingUi
{
    self.title = @"今日计划";
    
    //设置 UITableView
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    // 设置 导航栏右边的UIBarButtonItem
    UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
    CGFloat H = 21.5;
    [button setFrame:CGRectMake(0, 0, H, H)];
    [button addTarget:self action:@selector(rightBarAction:) forControlEvents:UIControlEventTouchUpInside];
    button.exclusiveTouch = YES;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    // 设置 导航栏左边的UIBarButtonItem
    button = [UIButton buttonWithType:UIButtonTypeSystem];
    H = 21.5;
    [button setFrame:CGRectMake(0, 0, H*1.5, H)];
    [button setTitle:@"编辑" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(leftBarAction:) forControlEvents:UIControlEventTouchUpInside];
    button.exclusiveTouch = YES;
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = leftItem;
}

#pragma mark - 触摸点击方法
/**
 *  导航栏右边的UIBarButtonItem的点击事件
 */
- (void)rightBarAction:(UIButton *)sender
{
    //创建UIAlertController控制器
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"添加计划" message:@"您的计划做什么呢？" preferredStyle:UIAlertControllerStyleAlert];
    
    //添加两个按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertCtr addAction:cancelAction];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //插入数据，刷新界面
        UITextField *textField = [alertCtr.textFields lastObject];
        [self.dataArr addObject:textField.text];
        NSInteger row = self.dataArr.count - 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        //UITableView 滚动到添加的行
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }];
    //开始确定操作设置成无效
    okAction.enabled = NO;
    [alertCtr addAction:okAction];
    
    //添加UITextField
    [alertCtr addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入计划今日事宜！";
        //为UITextField注册通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChange:) name:UITextFieldTextDidChangeNotification object:nil];
    }];
    
    //弹出UIAlertController控制器
    [self presentViewController:alertCtr animated:YES completion:nil];
}
/**
 *  导航栏左边的UIBarButtonItem的点击事件
 */
- (void)leftBarAction:(UIButton *)sender
{
    //如果tableView处于编辑状态
    if (self.tableView.editing) {
        //取消tableView编辑状态
        self.tableView.editing = NO;
        [sender setTitle:@"编辑" forState:UIControlStateNormal];
        
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObject:[self.navigationItem.leftBarButtonItems firstObject]];
    }
    else
    {
        //设置tableView编辑状态
        self.tableView.editing = YES;
        // 设置 导航栏左边第一个的UIBarButtonItem标题
        [sender setTitle:@"取消" forState:UIControlStateNormal];
        
        // 设置 导航栏左边第二个的UIBarButtonItem
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:@"删除" forState:UIControlStateNormal];
        CGFloat H = 21.5;
        [button setFrame:CGRectMake(0, 0, H*1.5, H)];
        [button addTarget:self action:@selector(barAction:) forControlEvents:UIControlEventTouchUpInside];
        button.exclusiveTouch = YES;
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
        
        // 设置 导航栏左边的UIBarButtonItem
        NSMutableArray *mArr = [NSMutableArray arrayWithObject:[self.navigationItem.leftBarButtonItems firstObject]];
        [mArr addObject:item];
        self.navigationItem.leftBarButtonItems = mArr;
    }
}
/**
 *  导航栏左边第二个的UIBarButtonItem的点击方法
 */
- (void)barAction:(UIButton *)sender
{
    //如果tableView处于编辑状态
    if (self.tableView.editing) {
        //如果存在选择的数据
        if (self.selectedDataArr.count > 0) {
            //插入数据，刷新界面
            NSMutableArray *deleteArr = [NSMutableArray arrayWithCapacity:1];
            NSIndexPath *deleteIndexPath = nil;
            for (NSString *str in self.selectedDataArr) {
                deleteIndexPath = [NSIndexPath indexPathForRow:[self.dataArr indexOfObject:str] inSection:0];
                [deleteArr addObject:deleteIndexPath];
            }
            [self.dataArr removeObjectsInArray:self.selectedDataArr];
            [self.selectedDataArr removeAllObjects];
            [self.tableView deleteRowsAtIndexPaths:deleteArr withRowAnimation:UITableViewRowAnimationNone];
        }
        else
        {
            //弹出提示的UIAlertController控制器
            UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"提示" message:@"请选择需要删除的计划" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alertCtr addAction:cancelAction];
            [self presentViewController:alertCtr animated:YES completion:nil];
        }
    }
}
/**
 *  UITextField 内容变化UITextFieldTextDidChangeNotification的通知方法
 */
- (void)textFieldChange:(NSNotification *)sender
{
    /*
         parentViewController:uiviewcontroller 中的parentviewcontroller 属性是用于取得当前控制器的父容器。建立这个父子关系的是通过[self addChildViewController:vc];这种方式来建立的。那么在vc这个子控制器中就可以通过 sefl.parentViewController 来访问它的父控制器了。
         presentedViewController:被本视图控制器present出来的的视图控制器
         modalViewController:已被presentedViewController这个属性取代
         presentingViewController:present出来一个视图控制器的视图控制器
     */
    UIAlertController *alertCtr = (UIAlertController *)self.presentedViewController;
    UITextField *textField = [alertCtr.textFields lastObject];
    UIAlertAction *okAction = [alertCtr.actions lastObject];
    okAction.enabled = textField.text.length > 0;
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = self.dataArr[indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.editing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else
    {
        [self.selectedDataArr addObject:self.dataArr[indexPath.row]];
    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing) {
        [self.selectedDataArr removeObject:self.dataArr[indexPath.row]];
    }
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSString *exchangeStr = self.dataArr[sourceIndexPath.row];
    [self.dataArr removeObjectAtIndex:sourceIndexPath.row];
    [self.dataArr insertObject:exchangeStr atIndex:destinationIndexPath.row];
}
/**
 *  设置UITableView 进入编辑状态的样式
 */
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     UITableView 编辑状态的样式有如下三种：
        UITableViewCellEditingStyleNone：cell往右缩进，但是左边不出现任何控件
        UITableViewCellEditingStyleDelete：cell往右缩进，但是左边出现红色减号控件
        UITableViewCellEditingStyleInsert：cell往右缩进，但是左边出现蓝色加号控件
        UITableViewCellEditingStyleDelete|UITableViewCellEditingStyleInsert：cell往右缩进，但是左边出现选择控件
     */
    if (tableView.editing) {
        return UITableViewCellEditingStyleDelete|UITableViewCellEditingStyleInsert;
    }
    else
    {
        return UITableViewCellEditingStyleDelete;
    }
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //添加一个删除按钮
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        //处理数据
        [self.dataArr removeObjectAtIndex:indexPath.row];
        //更新UI
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    //添加一个上移按钮
    UITableViewRowAction *upAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"上移" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if (indexPath.row > 0) {
            //处理数据
            [self.dataArr exchangeObjectAtIndex:indexPath.row withObjectAtIndex:indexPath.row - 1];
            //更新UI
            [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
    
    //添加一个下移按钮
    UITableViewRowAction *downAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"下移" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if (indexPath.row < self.dataArr.count - 1) {
            [self.dataArr exchangeObjectAtIndex:indexPath.row withObjectAtIndex:indexPath.row + 1];
            //更新UI
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
    
    //设置背景颜色
    downAction.backgroundColor = [UIColor colorWithRed:(arc4random()%256)/255.0 green:(arc4random()%256)/255.0 blue:(arc4random()%256)/255.0 alpha:1];
    
    //放回数组返回
    return @[deleteAction, upAction, downAction];
}

@end
