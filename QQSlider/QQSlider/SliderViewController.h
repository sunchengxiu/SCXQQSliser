//
//  SliderViewController.h
//  QQSlider
//
//  Created by 孙承秀 on 17/1/6.
//  Copyright © 2017年 孙先森丶. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConstFile.h"
typedef NS_ENUM(NSInteger , SCX_DragDirection){

    SCX_DragDirectionNone = 0 ,
    SCX_DragDirectionLeft ,
    SCX_DragDirectionRight

};
@interface SliderViewController : UIViewController<UIGestureRecognizerDelegate>

/******  只读主VC *****/
@property(nonatomic,strong,readonly)UIViewController *mainVC;

/******  只读主VC *****/
@property(nonatomic,strong,readonly)UIViewController *leftVC;

/******  只读主VC *****/
@property(nonatomic,strong,readonly)UIViewController *rightVC;


/**
 初始化入口

 @param mainVC 主VC
 @param leftVC 左边的VC
 @param rightVC 右边的VC
 @return 侧滑控制VC
 */
- (instancetype)initWithMainViewController:(UIViewController *)mainVC leftViewController:(UIViewController *)leftVC rightViewController:(UIViewController *)rightVC;
@end
