//
//  ConstFile.h
//  QQSlider
//
//  Created by 孙承秀 on 17/1/6.
//  Copyright © 2017年 孙先森丶. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ConstFile : NSObject
#ifdef __cplusplus
#define SCXKIT_EXTERN		extern "C" __attribute__((visibility ("default")))
#else
#define SCXKIT_EXTERN	        extern __attribute__((visibility ("default")))
#endif
/*************  左边视图缩放比例 ***************/
SCXKIT_EXTERN CGFloat const leftScale;

/*************  左边视图滑动范围 ***************/
SCXKIT_EXTERN CGFloat const leftWidth;

/*************  右边视图缩放比例 ***************/
SCXKIT_EXTERN CGFloat const rightScale;

/*************  右边视图滑动范围 ***************/
SCXKIT_EXTERN CGFloat const rightWidth;

/*************  左边滑动的最小距离 ***************/
SCXKIT_EXTERN CGFloat const leftMinWidth;

/*************  右边滑动的最小距离 ***************/
SCXKIT_EXTERN CGFloat const rightMinWidth;

/*************  默认动画时间 ***************/
SCXKIT_EXTERN CGFloat const normalDuration;
@end
