//
//  ViewController.m
//  AI_FaceRecognition
//
//  Created by 晓坤 on 2018/8/22.
//  Copyright © 2018年 xiao_kun. All rights reserved.
//

#import "ViewController.h"
#import "SwitchTableViewCell.h"
#import "StaticViewController.h"
#import "DynamicViewController.h"


@interface ViewController ()
@property (nonatomic, strong) UISwitch *sw;
@end

@implementation ViewController


- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"AIfacePhoto"]) {
        _sw.on = YES;
    }else{
        _sw.on = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"人脸登录";
    
    /* 说明：
     
        * 第一步： 开启刷脸功能： 拍照或从相册选择一张照片进行人脸识别（不包含人脸是识别不出来的） 识别成功后将图片存在本地
        * 第二步： 人脸识别： 动态识别 “活体人脸”  识别成功后拿该图片与本地缓存图片去匹配

     */

    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"switchCell"];
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:0 inSection:0];
    SwitchTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexpath];
    self.sw = (UISwitch *)cell.faceSwitch;
    self.sw.on = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        
        SwitchTableViewCell *switchCell = [tableView dequeueReusableCellWithIdentifier:@"switchCell" forIndexPath:indexPath];
        switchCell.selectionStyle = UITableViewCellSelectionStyleNone;
        switchCell.switchClickedBlock = ^(UISwitch *sw) {
            [self switchClicked:sw];
        };
        return switchCell;
        
    }else{
        
        static NSString *identifier = @"defluitCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.textLabel.text = @"人脸识别";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 55.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
 
    if (indexPath.row == 1 && [[NSUserDefaults standardUserDefaults] objectForKey:@"AIfacePhoto"]) {
        
        DynamicViewController *vc = [[DynamicViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"先开启刷脸识别" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

- (void)switchClicked:(UISwitch *)sender{
    
    if (sender.isOn == YES) {
        //人脸识别
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"需要真机运行，才能打开相机哦" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                self.sw.on = NO;
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }else{
            StaticViewController *vc = [[StaticViewController alloc]init];
            vc.faceRecognitionBlock = ^(BOOL isSuccess) {
                self.sw.on = isSuccess;
            };
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"你确定要关闭人脸识别设置？" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
            self.sw.on = YES;
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self deleteFaceImage];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)deleteFaceImage{
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AIfacePhoto"];
}


@end
