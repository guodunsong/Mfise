//
//  JobRecordController.m
//  Mfise
//
//  Created by issuser on 2018/8/28.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import "JobRecordController.h"
#import "JobRecordChildController.h"

@interface JobRecordController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *tabView;
@property (weak, nonatomic) IBOutlet UIButton *curTabBtn;
@property (weak, nonatomic) IBOutlet UILabel *underlineLbl;
@property (weak, nonatomic) IBOutlet UIView *containerView;


@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSMutableArray *childControllers;
@property (assign, nonatomic) NSInteger currentPage;

@end

@implementation JobRecordController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tabView.backgroundColor = RGBHex(0x1B97D2);
    _childControllers = [NSMutableArray array];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect frame = self.underlineLbl.frame;
    frame.size.width = CGRectGetWidth(self.curTabBtn.frame);
    frame.size.height = 2;
    frame.origin.x = self.curTabBtn.frame.origin.x;
    frame.origin.y = CGRectGetHeight([_underlineLbl superview].frame) - 2;
    _underlineLbl.frame = frame;
}

- (void)initView {
    [_childControllers removeAllObjects];
    [_containerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    

    
    [_containerView addSubview:self.pageViewController.view];
    [self.pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.left.equalTo(self.containerView);
    }];
    
    for (int i=0; i<3; i++) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Setting" bundle:nil];
        JobRecordChildController *vc = [sb instantiateViewControllerWithIdentifier:@"JobRecordChildController"];
        vc.type = i;
        [_childControllers addObject:vc];
    }
    
    [self.pageViewController setViewControllers:@[_childControllers[self.currentPage]]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES completion:nil];
}


/**
 pageViewController
 
 @return return value description
 */
- (UIPageViewController *)pageViewController {
    if (_pageViewController == nil) {
        NSDictionary *option = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:10] forKey:UIPageViewControllerOptionInterPageSpacingKey];
        _pageViewController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:option];
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
        [self addChildViewController:_pageViewController];
        
    }
    return _pageViewController;
}


#pragma mark -
#pragma mark UIPageViewControllerDataSource method
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [self.childControllers indexOfObject:viewController];
    if (index == 0) {
        return nil;
    }
    return self.childControllers[index - 1];
    
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [self.childControllers indexOfObject:viewController];
    if ((index+1) == self.childControllers.count) {
        return nil;
    }
    return self.childControllers[index + 1];
}

- (void) pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    _currentPage = [self.childControllers indexOfObject:pageViewController.viewControllers[0]];
    //解决快速滑动越界问题
    if (_currentPage + 1 >= self.childControllers.count) {
        _currentPage = self.childControllers.count - 1;
    }
    UIButton *sender = [self.view viewWithTag:1000+_currentPage];
    [self onTabBtn:sender];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)onTabBtn:(UIButton *)sender {
    if (sender == _curTabBtn) {
        return;
    }
    
    _curTabBtn.selected = NO;
    _curTabBtn = sender;
    _curTabBtn.selected = YES;
    
    NSInteger index = sender.tag - 1000;
    [UIView animateWithDuration:0.2 animations:^{
        CGPoint center = self.underlineLbl.center;
        center.x = sender.center.x;
        self.underlineLbl.center = center;
    } completion:^(BOOL finished) {
        if (finished) {
            UIPageViewControllerNavigationDirection direction = UIPageViewControllerNavigationDirectionForward;
            if (index < self.currentPage) {
                direction = UIPageViewControllerNavigationDirectionReverse;
            }
            
            __weak typeof(self) weakself = self;
            [self.pageViewController setViewControllers:@[self.childControllers[index]] direction:direction animated:YES completion:^(BOOL finished) {
                weakself.currentPage = index;
            }];
            
        }
    }];
    
    
}

@end
