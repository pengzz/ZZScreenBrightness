//
//  ZZScreenBrightness.h
//  ZZScreenBrightness_Example
//
//  Created by PengZhiZhong on 2019/1/10.
//  Copyright © 2019 pengzz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 iOS类似二维码页逐步调整屏幕亮度：
 
 ##参考链接：
 https://www.jianshu.com/p/8ef0d43d994e
 https://www.jianshu.com/p/956299d94dfc
 https://www.jianshu.com/p/24ffa819379c
 https://www.cnblogs.com/XYQ-208910/p/7146534.html
 
 ##使用方法：
 //页面出现时的方法
 - (void)viewDidAppear:(BOOL)animated {
 //设置亮度 0.8的亮度差不多了
 if ([UIScreen mainScreen].brightness < 0.8) {
 [ZZScreenBrightness graduallySetBrightness:0.8];
 }
 }
 //页面消失时的方法
 - (void)viewDidDisappear:(BOOL)animated {
 //恢复亮度
 [ZZScreenBrightness graduallyResumeBrightness];
 }
 
 */
@interface ZZScreenBrightness : NSObject

/**
 保存当前的亮度
 */
+ (void)saveDefaultBrightness;
/*!
 @method
 @abstract 逐步设置亮度（0.8的亮度差不多了）
 */
+ (void)graduallySetBrightness:(CGFloat)value;

/*!
 @method
 @abstract 逐步恢复亮度
 */
+ (void)graduallyResumeBrightness;



#pragma mark 细节调整

/**
 单步调节亮度增减差值。（默认0.005*2，值越大亮度动画越快）
 */
+ (void)setStepInterval:(CGFloat)stepInterval;

/**
 单步调节时间间隔。（默认1/180.0，值越小亮度动画越快）
 */
+ (void)setTimeInterval:(CGFloat)timeInterval;

/**
 是否跟随前台(获取到的)亮度值：
 
 ##即：是否在高亮状态退后台回到前台的一瞬间重新获取设置普亮值，以便从高亮状态跳转普亮状态时使用此普亮值。
 
 ##说明：若高亮状态退后台时没有正常动画到普亮，此时再回前台后页面跳转普亮时，则亮度值为从前台记录过来的亮度值；如果退后台能正常动画到普亮值，则反而是较好的设置，因为后台时可能重新调节了亮度值等！
 */
+ (void)setIsFollowForegroundBrightness:(BOOL)flag;

@end

NS_ASSUME_NONNULL_END

//// 保存屏幕常亮
//UIApplication.shared.isIdleTimerDisabled = true
