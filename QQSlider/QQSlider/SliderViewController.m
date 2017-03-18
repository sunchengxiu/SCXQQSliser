//
//  SliderViewController.m
//  QQSlider
//
//  Created by 孙承秀 on 17/1/6.
//  Copyright © 2017年 孙先森丶. All rights reserved.
//

#import "SliderViewController.h"
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_Height [UIScreen mainScreen].bounds.size.height
@interface SliderViewController (){

    // 视图
    UIView *_mainContentView;
    UIView *_leftContentView;
    UIView *_rightContentView;
    UIView *_maskView;
    
    // 手势
    UIPanGestureRecognizer *_panGesture;
    UITapGestureRecognizer *_tapGesture;
    
    // 限制
    BOOL _canDrag;
    BOOL _hasLeftShowed;
    BOOL _hasRightShowed;
    BOOL _canLeftShow;
    BOOL _canRightShow;
    
    // 手势点
    CGPoint _startPoint;
    CGPoint _endPoint;
    
    // 滑动方向
    SCX_DragDirection _dragDirection;

}

@end

@implementation SliderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
#pragma makr ----------初始化----------
-(instancetype)initWithMainViewController:(UIViewController *)mainVC leftViewController:(UIViewController *)leftVC rightViewController:(UIViewController *)rightVC{

    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        [self normalPrepareWork];
        self.mainVC = mainVC;
        self.rightVC = rightVC;
        self.leftVC = leftVC;
        
    }
    return self;
}
#pragma mark -----------基本配置准备
- (void)normalPrepareWork{

    _mainContentView = [[UIView alloc]init];
    _leftContentView = [[UIView alloc]init];
    _rightContentView = [[UIView alloc]init];
    _maskView = [[UIView alloc]init];
    CGRect viewBounds = self.view.bounds;
    _maskView.frame = viewBounds;
    _mainContentView.frame = viewBounds;
    _rightContentView.frame = viewBounds;
    _leftContentView.frame = viewBounds;
    _maskView.hidden = YES;
    [self.view addSubview:_leftContentView];
    [self.view addSubview:_rightContentView];
    [self.view addSubview:_mainContentView];
    [_mainContentView addSubview:_maskView];
    _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureThings:)];
    _tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureThings:)];
    _panGesture.delegate = self;
    _tapGesture.delegate = self;
    [_mainContentView addGestureRecognizer:_panGesture];
    [_maskView addGestureRecognizer:_tapGesture];
}
#pragma mark -----------配置主左右VC-----------
-(void)setMainVC:(UIViewController *)mainVC{
    if (!mainVC) {
        NSLog(@"主VC不能为空哦");
        return;
    }
    _mainVC = mainVC;
    [self addChildViewController:mainVC];
    [_mainContentView addSubview:mainVC.view];
}
-(void)setLeftVC:(UIViewController *)leftVC{
    if (!leftVC) {
        NSLog(@"左侧视图不能为空哦");
        return;
    }
    _canLeftShow = YES;
    _leftVC = leftVC;
    [self addChildViewController:leftVC];
    [_leftContentView addSubview:leftVC.view];
    // 左边视图向左移动一定距离，并且大小为一定比例
    _leftContentView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -leftWidth, 0    );
    _leftContentView.transform = CGAffineTransformScale(_leftContentView.transform,leftScale, leftScale);
}
-(void)setRightVC:(UIViewController *)rightVC{
    if (!rightVC) {
        NSLog(@"右边的视图不能为空哦");
        return;
    }
    _canRightShow = YES;
    _rightVC = rightVC;
    [self addChildViewController:rightVC];
    [_rightContentView addSubview:rightVC.view];
    //  右边的视图要向右移动一定距离，并且进行一定比例饿的缩放
    _rightContentView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, rightWidth, 0   );
    _rightContentView.transform = CGAffineTransformScale(_rightContentView.transform, rightScale, rightScale);
}
#pragma mark -----------手势点击事件-----------
#pragma mark -----------拖拽手势，重点就在这个方法--------------
-(void)panGestureThings:(UIPanGestureRecognizer *)pan{

    CGPoint startPoint = [pan locationInView:self.view];
    switch (pan.state) {
            // 手势开始的时候
        case UIGestureRecognizerStateBegan:
        {
            // 如果左右视图都没有显示出来的时候
            if (!_hasLeftShowed && !_hasRightShowed) {
                // 手指必须在指定范围内
                if (startPoint.x < leftWidth || startPoint.x > SCREEN_WIDTH - rightWidth) {
                    _canDrag = YES;
                }
                else{
                    _canDrag = NO;
                }
            }
            // 左边显示出来了
            else if (_hasLeftShowed){
                // 这样写的目的是，当 我们已经弹出来左面或者右边的视图的时候，想要划回去，那么就要滑动主界面的视图，滑动他划回去才有效果，比如说弹出来左边的视图，然后在左边的视图上滑动，是没有效果的，所有location要选择为maincontentview而不是self.view
                CGPoint currentPoint = [pan locationInView:_mainContentView ];
                if (currentPoint.x > 0 && currentPoint.y > 0 ) {
                    _canDrag = YES;
                }
                else {
                    _canDrag = NO;
                }
            }
            // 右边显示出来了
            else if (_hasRightShowed){
                CGPoint currentPoint = [pan locationInView:_mainContentView ];
                if (currentPoint.x > 0 && currentPoint.y > 0 ) {
                    _canDrag = YES;
                }
                else {
                    _canDrag = NO;
                }
            }
            _startPoint = startPoint;
            _endPoint = startPoint;
        }
            break;
            // 手势状态改变的时候
        case UIGestureRecognizerStateChanged:{
        
            if (!_canDrag) {
                break;
            }
            CGFloat main_x = _mainContentView.frame.origin.x;
            CGFloat moveLength = startPoint.x - _endPoint.x;
            _endPoint = startPoint;
            CGFloat scale = 1;
            // 左右视图都没有出来的时候
            if (!_hasRightShowed && !_hasLeftShowed) {
                if (_dragDirection == SCX_DragDirectionNone) {
                    if (moveLength > 0 ) {
                        // 向右滑动的
                        _dragDirection = SCX_DragDirectionRight;
                        _leftContentView.hidden = NO;
                        _rightContentView.hidden = YES;
                    }
                    else{
                        _dragDirection = SCX_DragDirectionLeft;
                        _rightContentView.hidden = NO;
                        _leftContentView.hidden = YES;
                    }
                }
                switch (_dragDirection) {
                        // 向右滑动 左边视图显示
                    case SCX_DragDirectionRight:
                    {
                        if (!_canLeftShow) {
                            break;
                        }
                        
                        // 判断拖动的范围，有一个临界值，到最大值的时候不再做处理
                        CGFloat left_X = _leftContentView.frame.origin.x;
                        // || left_X + moveLength > 0
                        //left_X > 0 ||
                        if ( moveLength > leftWidth ) {
                            NSLog(@"拖动超过临界值了，别托了");
                            break;
                        }
                        
                        // 防止向右滑动出现左侧视图的时候，手指画的是右边的区域，防止滑动右边区域的时候弹出左侧的视图
                        // || main_x +moveLength >0
                      
                        if (_leftContentView.frame.origin.x >= 0 || _startPoint.x > SCREEN_WIDTH - rightWidth) {
                                break;
                        }
                        // 做一些缩放，左边的要放大，主页要缩小
                        scale = 1- (moveLength/leftWidth) * (1 - leftScale);
                       
                        _mainContentView.transform = CGAffineTransformTranslate(_mainContentView.transform, moveLength, 0);
                        _mainContentView.transform = CGAffineTransformScale(_mainContentView.transform, scale, scale);
                        
                        CGFloat left_scale = 1 + (moveLength / leftWidth) * (1 - leftScale) ;
                      
                        _leftContentView.transform = CGAffineTransformTranslate((_leftContentView).transform, moveLength, 0);
                        _leftContentView.transform = CGAffineTransformScale(_leftContentView.transform, left_scale, left_scale);
                        
                    }
                        break;
                        //像左滑动  右边视图显示
                        case SCX_DragDirectionLeft:
                    {
                        if (!_canRightShow) {
                            break;
                        }
                        // 手指起始的位置，不能在向右滑动的触摸范围内，向左滑动，主页的x是小于0 的，所以说大于0 也是不行的
                        if (_startPoint.x < leftWidth || moveLength + main_x > 0) {
                            NSLog(@"往左滑动的太多了，越界了");
                            break;
                        }
                        CGFloat right_x= _rightContentView.frame.origin.x;
                        // 向左滑动 ，右侧界面出来了右侧界面X大于0 ，并且滑动范围大于右侧可以滑动的范围就暂停了.
                        if (right_x + moveLength < 0 || right_x < 0 || fabs(moveLength) > rightWidth) {
                            NSLog(@"滑动幅度太大了");
                            break;
                        }
                        scale = 1 + (moveLength / rightWidth) * (1 - rightScale);
                        
                        _mainContentView.transform = CGAffineTransformTranslate(_mainContentView.transform, moveLength, 0);
                        _mainContentView.transform = CGAffineTransformScale(_mainContentView.transform, scale, scale);
                        
                        CGFloat right_scale = 1 - (moveLength / rightWidth) * (1 - rightScale);
                        
                        _rightContentView.transform = CGAffineTransformTranslate(_rightContentView.transform, moveLength, 0);
                        _rightContentView.transform = CGAffineTransformScale(_rightContentView.transform, right_scale, right_scale  );
                        
                        
                    }
                        break;
                    default:
                        break;
                }
            }
            // 左边竖图出来了
            else if(_hasLeftShowed){
                if ( _dragDirection == SCX_DragDirectionNone) {
                    _dragDirection = SCX_DragDirectionRight;
                }
                CGFloat left_x = _leftContentView.frame.origin.x;
                if (main_x < 0 || moveLength > leftWidth || left_x > 0) {
                    break;
                }
                CGFloat right_scale = 1 - (moveLength / leftWidth) * (1 - leftScale);
                _mainContentView.transform = CGAffineTransformTranslate(_mainContentView.transform, moveLength, 0);
                _mainContentView.transform = CGAffineTransformScale(_mainContentView.transform, right_scale, right_scale);
                
                CGFloat left_scale = 1 + (moveLength / leftWidth ) * (1 - leftScale);
                NSLog(@"%f",moveLength);
                _leftContentView.transform = CGAffineTransformTranslate(_leftContentView.transform, moveLength, 0);
                _leftContentView.transform = CGAffineTransformScale(_leftContentView.transform, left_scale, left_scale);
                
            
            }
            // 右边视图出来了
            else if (_hasRightShowed){
                if (_dragDirection == SCX_DragDirectionNone) {
                    _dragDirection = SCX_DragDirectionLeft;
                    
                }
                CGFloat right_x = _rightContentView.frame.origin.x;
                if ( moveLength > rightWidth || main_x > 0 ) {
                    break;
                }
                CGFloat main_scale = 1 + (moveLength / rightWidth)* (1 - rightScale);
                _mainContentView.transform = CGAffineTransformTranslate(_mainContentView.transform, moveLength, 0);
                _mainContentView.transform = CGAffineTransformScale(_mainContentView.transform, main_scale, main_scale);
                CGFloat right_scale = 1 - (moveLength / rightWidth)* (1 - rightScale);
                _rightContentView.transform = CGAffineTransformTranslate(_rightContentView.transform, moveLength, 0);
                _rightContentView.transform = CGAffineTransformScale(_rightContentView.transform, right_scale, right_scale);
                
            }
            
        }
            break;
            // 手势结束的时候
            case UIGestureRecognizerStateEnded:
        {
            if (!_canDrag) {
                break;
            }
            CGFloat  move_Length = fabs(startPoint.x - _startPoint.x) ;
            switch (_dragDirection) {
                case SCX_DragDirectionRight:
                {
                    if (!_canLeftShow) {
                        break;
                    }
                    CGFloat left_x = _leftContentView.frame.origin.x;
                    
                    if (_hasLeftShowed && left_x == 0 && startPoint.x - _startPoint.x >= 0) {
                        break;
                    }
                    if (move_Length > leftMinWidth) {
                        if (_hasLeftShowed) {
                            [self hideLeftView];
                        }
                        else{
                            [self showLeftView];
                        }
                    }
                    else{
                    if (_hasLeftShowed) {
                            [self showLeftView];
                        }
                        else{
                            [self hideLeftView];
                        }
                    }
                    
                }
                    break;
                    case SCX_DragDirectionLeft:
                {
                    CGFloat right_x = _rightContentView.frame.origin.x;
                    if (_canRightShow && right_x ==0 && startPoint.x - _startPoint.x <=0) {
                        break;
                    }
                    if (move_Length > rightMinWidth) {
                        if (_hasRightShowed) {
                            [self hideRightView];
                        }
                        else{
                            [self showRightView];
                        }
                        
                    }
                    else{
                        if (_hasRightShowed) {
                            [self showRightView];
                        }
                        else{
                            [self hideRightView];
                        }
                    }
                }
                    break;
                    
                default:
                    break;
            }
            _dragDirection = SCX_DragDirectionNone;
            _endPoint = CGPointZero;
            _startPoint = CGPointZero;
            _canDrag = NO;
        }
            break;
        default:
            break;
    }
}
- (void)showLeftView{
    _leftContentView.hidden = NO;
    _rightContentView.hidden = YES;
    [UIView animateWithDuration:[self getAnimationDurtionWithIsShow:YES] animations:^{
        _mainContentView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, leftWidth, 0);
        _mainContentView.transform = CGAffineTransformScale(_mainContentView.transform, leftScale, leftScale);
        _leftContentView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 0     );
        _leftContentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        
    } completion:^(BOOL finished) {
        _hasLeftShowed = YES;
        _leftContentView.hidden = NO;
        _maskView.hidden = NO;
    }];
}
- (void)showRightView{
    _rightContentView.hidden = NO;
    _leftContentView.hidden = YES;
    [UIView animateWithDuration:[self getAnimationDurtionWithIsShow:YES] animations:^{
        _mainContentView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -rightWidth, 0);
        _mainContentView.transform = CGAffineTransformScale(_mainContentView.transform, rightScale, rightScale);
        _rightContentView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 0);
        _rightContentView.transform = CGAffineTransformScale(_rightContentView.transform, 1, 1);
    } completion:^(BOOL finished) {
        _hasRightShowed = YES;
        _rightContentView.hidden = NO;
        _maskView.hidden = NO;
    }];

}
- (void)hideLeftView{
    [UIView animateWithDuration:[self getAnimationDurtionWithIsShow:NO] animations:^{
        _mainContentView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 0);
        _mainContentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        _leftContentView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -leftWidth, 0);
        _leftContentView.transform = CGAffineTransformScale(_leftContentView.transform,leftScale, leftScale);
    } completion:^(BOOL finished) {
        _hasLeftShowed = NO;
        _leftContentView.hidden = YES;
        _maskView.hidden = YES;
    }];
}
- (void)hideRightView{
    [UIView animateWithDuration:[self getAnimationDurtionWithIsShow:NO] animations:^{
        _mainContentView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 0);
        _mainContentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        _rightContentView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, rightWidth, 0);
        _rightContentView.transform = CGAffineTransformScale(_leftContentView.transform,rightScale, rightScale);
    } completion:^(BOOL finished) {
        _hasRightShowed = NO;
        _rightContentView.hidden = YES;
        _maskView.hidden = YES;
    }];

}
-(void)tapGestureThings:(UITapGestureRecognizer *)tap{
    [self hideRightView];
    [self hideLeftView];
}
#pragma mark -----------手势代理方法------------
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{

    // 防止进入多级界面的时候，也能弹出左右菜单，所以加已限制
    if ([_mainVC isKindOfClass:[UINavigationController class]]) {
        if (_mainVC.childViewControllers.count > 1) {
            return NO;
        }
    }
    else{
    
        for (UIViewController *VC in _mainVC.childViewControllers) {
            if ([VC isKindOfClass:[UINavigationController class]]) {
                if (VC.childViewControllers.count > 1) {
                    return NO;
                }
            }
        }
    
    }
    // 手势点击的位置在左边或右边允许滑动的范围内才可以
    if ([gestureRecognizer locationInView:_mainContentView].x < leftWidth || [gestureRecognizer locationInView:_mainContentView].x > SCREEN_WIDTH - rightWidth) {
        return YES;
    }
    return NO;
}
- (NSTimeInterval)getAnimationDurtionWithIsShow:(BOOL)isShow{
    NSTimeInterval timeInterval;
    CGFloat main_x = _mainContentView.frame.origin.x;
    CGFloat left_x = _leftContentView.frame.origin.x;
    CGFloat right_x = _rightContentView.frame.origin.x;
    if (main_x == 0 || left_x == 0 || right_x == 0) {
        return normalDuration;
    }
    CGFloat left_Scale = _leftContentView.frame.size.width / SCREEN_WIDTH;
    CGFloat right_scale = _rightContentView.frame.size.width / SCREEN_WIDTH;
    // left
    if (main_x > 0 ) {
        if (isShow) {
            
            timeInterval =((left_Scale - leftScale) / (1 - leftScale)) * normalDuration;
        }
        else{
            timeInterval = ((left_Scale - leftScale) / (1 - leftScale)) * normalDuration;
        }
    }
    // right
    else{
        if (isShow) {
            timeInterval =( (right_scale - rightScale) / (1 - rightScale)) * normalDuration;
        }
        else{
            timeInterval = ((right_scale - rightScale) / (1 - rightScale)) * normalDuration;
        }
    }
    return timeInterval;

}
@end
