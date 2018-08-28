//
//  SettingController.m
//  Mfise
//
//  Created by issuser on 2018/8/21.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import "SettingController.h"
#import "LCActionSheet.h"

@interface SettingController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout> {
    NSMutableArray *_dataArr;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation SettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden:NO];
    _dataArr = [NSMutableArray array];
    [_dataArr addObject:@{@"title":@"用户信息",@"img":@"ic_user"}];
    [_dataArr addObject:@{@"title":@"修改密码",@"img":@"ic_edit"}];
    [_dataArr addObject:@{@"title":@"帮助与支持",@"img":@"ic_help"}];
    [_dataArr addObject:@{@"title":@"作业记录",@"img":@"ic_record"}];
    [_dataArr addObject:@{@"title":@"绑定仓库",@"img":@"ic_bind"}];
    [_dataArr addObject:@{@"title":@"切换账户",@"img":@"ic_change"}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark SettingController method
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArr.count;
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SettingCell" forIndexPath:indexPath];
    NSDictionary *rowDic = _dataArr[indexPath.row];
    UIImageView *imgView = [cell viewWithTag:1000];
    UILabel *titleLbl = [cell viewWithTag:1001];
    imgView.image = [UIImage imageNamed:rowDic[@"img"]];
    titleLbl.text = rowDic[@"title"];
    
    return cell;
}

#pragma mark -
#pragma mark UICollectionViewDelegate method

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *rowDic = _dataArr[indexPath.row];
    if ([rowDic[@"title"] isEqualToString:@"用户信息"]) {
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserInfoController"];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([rowDic[@"title"] isEqualToString:@"帮助与支持"]) {
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"HelpController"];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([rowDic[@"title"] isEqualToString:@"绑定仓库"]) {
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"BindWarehouseController"];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([rowDic[@"title"] isEqualToString:@"切换账户"]) {
        LCActionSheet *sheet = [LCActionSheet sheetWithTitle:@"确定要退出当前用户吗" cancelButtonTitle:@"取消" clicked:^(LCActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
                UIViewController *vc = [sb instantiateInitialViewController];
                kAppDelegate.window.rootViewController = vc;
            }
        } otherButtonTitles:@"确定", nil];
        [sheet show];
    } else if ([rowDic[@"title"] isEqualToString:@"作业记录"]) {
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"JobRecordController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (kScreenWidth - 32 * 3 ) / 2;
    return CGSizeMake(width, width);
}




@end
