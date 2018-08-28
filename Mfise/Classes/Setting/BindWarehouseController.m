//
//  BindWarehouseController.m
//  Mfise
//
//  Created by issuser on 2018/8/22.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import "BindWarehouseController.h"

@interface BindWarehouseController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {
    
    
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnstCollectionViewHeight;
@property (strong, nonatomic) NSMutableArray *dataArr;
@property (strong, nonatomic) NSIndexPath *curIndexPath;

@end

@implementation BindWarehouseController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_collectionView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    _dataArr = [NSMutableArray array];
    [self reqData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [_collectionView removeObserver:self forKeyPath:@"contentSize"];
}

- (IBAction)onBack:(id)sender {
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)onSubmit:(id)sender {
    
    if (_curIndexPath) {
        [UserMgr shared].warehouseDic = _dataArr[_curIndexPath.row];
        [SVProgressHUD showSuccessWithStatus:@"绑定成功"];
        __weak __typeof(self)weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if (self.navigationController.viewControllers.count > 1) {
                [self.navigationController popViewControllerAnimated:YES];
                return ;
            }
            
            [self dismissViewControllerAnimated:YES completion:^{
                //关闭回调方法
                if (weakSelf.dismissBlock) {
                    weakSelf.dismissBlock();
                }
            }];
           
        });
        
    } else {
        [SVProgressHUD showInfoWithStatus:@"请先选择仓库"];
    }
}


#pragma mark -
#pragma mark request method

//服务器获取仓库列表
- (void)reqData {
    
    NSString *url = [[URLTool shared] networkPath:@"user_storage_list"];
    __weak __typeof(self)weakSelf = self;
    [[RequestTool shared] get:url params:nil callback:^(ResModel *response) {
        if (response.code == 200) {
            NSArray *arr = [NSDictionary mj_objectArrayWithKeyValuesArray:response.data];
            if (arr && arr.count > 0) {
                [weakSelf initCurIndexPath:arr];
                [weakSelf.dataArr removeAllObjects];
                [weakSelf.dataArr addObjectsFromArray:arr];
                [weakSelf.collectionView reloadData];
            }
            
        } else {
            [SVProgressHUD showErrorWithStatus:response.message];
        }
        
    }];
}


/**
 初始化选中项

 @param arr arr description
 */
- (void)initCurIndexPath:(NSArray *)arr {
    //初始化第一个选中项目
    NSDictionary *curDic = [UserMgr shared].warehouseDic;
    for (int i=0; i<arr.count && curDic; i++) {
        NSDictionary *dic = arr[i];
        if([curDic[@"storageId"] integerValue] == [dic[@"storageId"] integerValue]) {
            _curIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            break;
        }
        
    }
}

#pragma mark -
#pragma mark UICollectionViewDataSource method
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArr.count;
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BindWarehouseCell" forIndexPath:indexPath];
    UILabel *titleLbl = [cell viewWithTag:1000];
    NSDictionary *rowDic = _dataArr[indexPath.row];
    titleLbl.text = rowDic[@"storageName"];
    titleLbl.backgroundColor = [UIColor groupTableViewBackgroundColor];
    titleLbl.textColor = RGBHex(0x666666);
    if (_curIndexPath && _curIndexPath.row == indexPath.row) {
        titleLbl.backgroundColor =  RGBHex(0xB97D2);
        titleLbl.textColor = [UIColor whiteColor];
    }
    
    return cell;
}

#pragma mark -
#pragma mark UICollectionViewDelegate method
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_curIndexPath == indexPath) {
        return;
    }
    
    _curIndexPath = indexPath;
    [collectionView reloadData];
}

#pragma mark -
#pragma mark UICollectionViewDelegateFlowLayout method
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *rowDic = _dataArr[indexPath.row];
    NSString *str = rowDic[@"storageName"];
    CGSize strSize = [str sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0]}];
    CGSize size = CGSizeMake(strSize.width + 32, 46);
    
    return size;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        CGFloat height = _collectionView.contentSize.height > 66.0? _collectionView.contentSize.height : 66.0;
        _cnstCollectionViewHeight.constant = height;
    }
}


@end
