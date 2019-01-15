//
//  ZZScreenBrightness.m
//  ZZScreenBrightness_Example
//
//  Created by PengZhiZhong on 2019/1/10.
//  Copyright © 2019 pengzz. All rights reserved.
//

#import "ZZScreenBrightness.h"

#ifndef __OPTIMIZE__
#define NSLog(...) NSLog(__VA_ARGS__)
#define debugMethod() NSLog(@"%s", __func__)
#else
#define NSLog(...)
#define debugMethod()
#endif

//设值调整
static CGFloat _stepInterval         = (0.005*2*1.0); //单步调节亮度增减差值(覆盖全2.66值)
static CGFloat _timeInterval         = (1/180.0);     //单步调节时间间隔
static BOOL    _isFollowForegroundBrightness = YES;   //是否跟随前台(获取到的)亮度值
//一些属性
static CGFloat _brightness           = 0.8;           //高亮状态时亮度值（高亮值）
static CGFloat _currentBrightness; //记录当前亮度值（普亮值）
static NSOperationQueue *_queue;   //操作队列
static BOOL    _isHigh;            //是否高亮状态

@implementation ZZScreenBrightness

#pragma mark - 设值调整
/**
 单步调节亮度增减差值。（默认0.005*2，值越大亮度动画越快）
 */
+ (void)setStepInterval:(CGFloat)stepInterval {_stepInterval = stepInterval;}

/**
 单步调节时间间隔。（默认1/180.0，值越小亮度动画越快）
 */
+ (void)setTimeInterval:(CGFloat)timeInterval {_timeInterval = timeInterval;}

/**
 是否跟随前台(获取到的)亮度值：（默认YES）
 
 ##即：是否在高亮状态退后台回到前台的一瞬间重新获取设置普亮值，以便从高亮状态跳转普亮状态时使用此普亮值。
 
 ##说明：若高亮状态退后台时没有正常动画到普亮，此时再回前台后页面跳转普亮时，则亮度值为从前台记录过来的亮度值；如果退后台能正常动画到普亮值，则反而是较好的设置，因为后台时可能重新调节了亮度值等！
 */
+ (void)setIsFollowForegroundBrightness:(BOOL)flag {_isFollowForegroundBrightness = flag;}


#pragma mark - 初始
+ (void)initialize{
    //记录一次亮度值
    [self saveDefaultBrightness];
    
    //系统通知：应用激活状态
    [self addNSNotification];
    
    //系统通知：手机亮度改变时发送的通知（动画变化完有时会到达这个通知。不用这个，否则会一直高亮）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_saveDefaultBrightness) name:UIScreenBrightnessDidChangeNotification object:nil];
}

#pragma mark - 系统通知
+ (void)addNSNotification {
    //程序变成激活状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    //程序将失去激活状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

//成为激活状态，调高亮度
+ (void)willEnterForeground {
    if (_isHigh) {//上一次为高亮状态时
        if (_isFollowForegroundBrightness) {
            //NSLog(@"WillEnterForeground:上一次退到后台前记录的亮度值：%@",@(_currentBrightness));
            //NSLog(@"WillEnterForeground:当前屏幕取到的值：%@",@([UIScreen mainScreen].brightness));
            //注意：这一步记录有时会有问题,会导致每次退会台后再打开亮度以退到后台时的亮度了！
            [self saveDefaultBrightness];
        }
    }
}

+ (void)didBecomeActive {
    if (_isHigh) {//上一次为高亮状态时
        if (_isFollowForegroundBrightness) {
            //NSLog(@"didBecomeActive:上一次退到后台前记录的亮度值：%@",@(_currentBrightness));
            //NSLog(@"didBecomeActive:当前屏幕取到的值：%@",@([UIScreen mainScreen].brightness));
            //这里记录的值不准确，值有些随机了!
            //[self saveDefaultBrightness];
        }
    }
    
    if (_isHigh) {//上一次为高亮状态时
        [self _graduallySetBrightness:_brightness];//还原到激活前的
    }
}

//失去激活状态，快速恢复之前的亮度
+ (void)willResignActive {
    if (_isHigh) {
        //页面进来太快呼出控制页板，而resignActive时,屏幕的亮度暗而用下面这句时，由于(屏幕亮度值与普亮值)两值相近，而不变暗，只变高亮
        //[self _graduallySetBrightness:_currentBrightness];//退回到正常
        [self _graduallySetBrightness:_currentBrightness];//退回到正常
    }

    //XX[ZZScreenBrightness graduallyResumeBrightness];//这里用这种动画只会执行之半就冻住了，回前台才继续执行完后再执行后面(暗->亮)动画
    //快速
    //[ZZScreenBrightness fastResumeBrightness];
}

#pragma mark - 系统通知：手机亮度改变时发送的通知
+ (void)noti_saveDefaultBrightness {
    //手动调系统的会触发,动画变化完后有时也会到此通知来的！！！
    NSLog(@"noti_saveDefaultBrightness......");
    NSLog(@"noti_saveDefaultBrightness：[UIScreen mainScreen].brightness==%@",@([UIScreen mainScreen].brightness));
}

#pragma mark - ##

+ (void)saveDefaultBrightness {
    _currentBrightness = [UIScreen mainScreen].brightness;
    NSLog(@"saveDefaultBrightness：_currentBrightness==%@",@(_currentBrightness));
}

+ (void)_graduallySetBrightness:(CGFloat)value {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
    }
    [_queue cancelAllOperations];

    NSLog(@"将要变为的亮度%f",value);
    
    CGFloat brightness = [UIScreen mainScreen].brightness;
    CGFloat stepInterval = _stepInterval;
    CGFloat step = stepInterval * ((value > brightness) ? 1 : -1);
    int times = fabs((value - brightness) / stepInterval);
    CGFloat timeInterval = _timeInterval;
    
#ifndef __OPTIMIZE__
    NSDate *d = [NSDate new];
#endif
    NSLog(@"date==%@",d);

    //根据亮度差计算出时间和每个单位时间调节的亮度值
    for (CGFloat i = 1; i < times + 1; i++) {
        [_queue addOperationWithBlock:^{
            [NSThread sleepForTimeInterval:timeInterval];
            [UIScreen mainScreen].brightness = brightness + i * step;
            NSLog(@"第几次i==%@",@(i));
            NSLog(@"-时间差值---%@", @([[NSDate new] timeIntervalSinceDate:d]));
        }];
    }
}

+ (void)graduallySetBrightness:(CGFloat)value {
    //先记录一下'普亮值'
    [self saveDefaultBrightness];
    
    //记录'高亮值'
    _brightness = value;

    //设置高亮状态
    _isHigh = YES;
    
    //可能点了跳转高亮页面时又快速呼出控制面板，即先执行willResignActive了再到这里则为InActive状态，此时不应有动画高亮的！
    if ([UIApplication sharedApplication].applicationState==UIApplicationStateActive) {
        [self _graduallySetBrightness:value];
    }
}

+ (void)graduallyResumeBrightness {
    _isHigh = NO;
    [self _graduallySetBrightness:_currentBrightness];
}

+ (void)fastResumeBrightness {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
    }
    [_queue cancelAllOperations];
    [_queue addOperationWithBlock:^{
        [UIScreen mainScreen].brightness = _currentBrightness;
    }];
}

@end
