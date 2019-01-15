//
//  ZZScreenBrightness.m
//  ZZScreenBrightness_Example
//
//  Created by PengZhiZhong on 2019/1/10.
//  Copyright © 2019 pengzz. All rights reserved.
//

#import "ZZScreenBrightness.h"

static CGFloat _brightness           = 0.8;           //高亮状态时亮度值（高亮值）
static CGFloat _stepInterval         = (0.005*2*1.0); //单步调节亮度增减差值(全2.66值)
static CGFloat _timeInterval         = (1/180.0);     //单步调节时间间隔
static BOOL    _isFollowForegroundBrightness = YES;   //是否跟随前台(获取到的)亮度值
//static BOOL    _brightnessDidChange  = YES;         //是否处理系统手机亮度改变时发送的通知

static CGFloat _currentBrightness; //记录当前亮度值（普亮值）
static NSOperationQueue *_queue;   //操作队列
static BOOL    _isHigh;        //是否高亮状态
//static BOOL    _isFollow = YES;      //是否跟随

//尝试一下
//timer
static CGFloat _value;
static CGFloat _isIncrease;//+1增；-1减
//timer_old
static CGFloat t_brightness;
static CGFloat _step;
static int _times;
static int _time;
static NSTimer *_timer = nil;

@implementation ZZScreenBrightness

/**
 单步调节亮度增减差值。（默认0.005*2，值越大亮度动画越快）
 */
+ (void)setStepInterval:(CGFloat)stepInterval {_stepInterval = stepInterval;}

/**
 单步调节时间间隔。（默认1/180.0，值越小亮度动画越快）
 */
+ (void)setTimeInterval:(CGFloat)timeInterval {_timeInterval = timeInterval;}

/**
 是否跟随前台(获取到的)亮度值：
 
 ##即：是否在高亮状态退后台回到前台的一瞬间重新获取设置普亮值，以便从高亮状态跳转普亮状态时使用此普亮值。
 
 ##说明：若高亮状态退后台时没有正常动画到普亮，此时再回前台后页面跳转普亮时，则亮度值为从前台记录过来的亮度值；如果退后台能正常动画到普亮值，则反而是较好的设置，因为后台时可能重新调节了亮度值等！
 */
+ (void)setIsFollowForegroundBrightness:(BOOL)flag {_isFollowForegroundBrightness = flag;}

///**
// 是否处理系统手机亮度改变时发送的通知。（默认YES，默认处理）
// */
//+ (void)setBrightnessDidChange:(BOOL)flag {_brightnessDidChange = flag;}


+ (void)initialize{
    //记录一次亮度值
    [self saveDefaultBrightness];
    
    //系统通知：应用激活状态
    [self addNSNotification];
    
    //系统通知：手机亮度改变时发送的通知（动画变化完时会到达这个通知。不用这个，否则会一直高亮）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_saveDefaultBrightness) name:UIScreenBrightnessDidChangeNotification object:nil];
}

#pragma mark - 系统通知：应用激活状态
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
            
            //这里记录的值不准确，值有些随机了
            //[self saveDefaultBrightness];
        }
    }
    
    if (_isHigh) {//上一次为高亮状态时
        [ZZScreenBrightness graduallySetBrightness0:_brightness];//还原到激活前的
    }
}
//失去激活状态，快速恢复之前的亮度
+ (void)willResignActive {
    if (_isHigh) {
        //页面进来太快呼出控制页板，而resignActive时,屏幕的亮度暗而用下面这句时，由于两值相近，而不变暗，只变高亮
        //[self graduallySetBrightness0:_currentBrightness];//退回到正常
        
        [self graduallySetBrightness22:_currentBrightness];//退回到正常（里面取高亮值动画回来！）
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
//    if (_brightnessDidChange) {
//        NSLog(@"noti_saveDefaultBrightness......要记录");
//        [self saveDefaultBrightness];
//    } else {
//        NSLog(@"noti_saveDefaultBrightness......不记录");
//    }
}

#pragma mark - ##

+ (void)saveDefaultBrightness {
    _currentBrightness = [UIScreen mainScreen].brightness;
    NSLog(@"saveDefaultBrightness：_currentBrightness==%@",@(_currentBrightness));
}

+ (void)graduallySetBrightness0:(CGFloat)value {
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
    NSDate *d = [NSDate new];
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

+ (void)graduallySetBrightness22:(CGFloat)value {
    [self graduallySetBrightness0:value]; return;
    
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
    }
//    [_queue cancelAllOperations];
    
    NSLog(@"将要变为的亮度%f",value);
    
    //>注意用了'高亮值'>>>
    CGFloat brightness = _brightness;//[UIScreen mainScreen].brightness;
    CGFloat stepInterval = _stepInterval;
    CGFloat step = stepInterval * ((value > brightness) ? 1 : -1);
    int times = fabs((value - brightness) / stepInterval);
    CGFloat timeInterval = _timeInterval;
    //根据亮度差计算出时间和每个单位时间调节的亮度值
    for (CGFloat i = 1; i < times + 1; i++) {
        [_queue addOperationWithBlock:^{
            [NSThread sleepForTimeInterval:timeInterval];
            [UIScreen mainScreen].brightness = brightness + i * step;
        }];
    }
}

+ (void)graduallySetBrightness0_timer_old:(CGFloat)value {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    CGFloat brightness = [UIScreen mainScreen].brightness;
    CGFloat stepInterval = _stepInterval;
    CGFloat step = stepInterval * ((value > brightness) ? 1 : -1);
    int times = fabs((value - brightness) / stepInterval);
    CGFloat timeInterval = _timeInterval;
    //根据亮度差计算出时间和每个单位时间调节的亮度值
    {
        t_brightness = brightness;
        _step = step;
        _times = times;
        _time = 0;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(timeRun_old) userInfo:nil repeats:true];
}
+ (void)timeRun_old{
    if (_time <= _times+0) {
        [UIScreen mainScreen].brightness = t_brightness + _time * _step;
        _time ++;
    }
    else {
        NSLog(@"时间到22222");
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
    }
    NSLog(@"_times==%@; _time==%@",@(_times),@(_time));
}

+ (void)graduallySetBrightness0_timer:(CGFloat)value {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    CGFloat brightness = [UIScreen mainScreen].brightness;
    //CGFloat timeInterval = _timeInterval;
    
    //根据亮度差计算出时间和每个单位时间调节的亮度值
    _value = value;
    _isIncrease = (value > brightness) ? 1 : -1;
    //
    _timer = [NSTimer scheduledTimerWithTimeInterval:_stepInterval target:self selector:@selector(timeRun) userInfo:nil repeats:true];
}
+ (void)timeRun{
    BOOL flag;
    if (_isIncrease > 0) {
        flag = [UIScreen mainScreen].brightness < _value;
    } else {
        flag = [UIScreen mainScreen].brightness > _value;
    }
    //
    if (flag) {
        [UIScreen mainScreen].brightness += _isIncrease * _stepInterval;
    } else {
        NSLog(@"时间到22222");
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
    }
}


+ (void)graduallySetBrightness0X:(CGFloat)value {
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
    //根据亮度差计算出时间和每个单位时间调节的亮度值
//    for (CGFloat i = 1; i < times + 1; i++) {
//        [_queue addOperationWithBlock:^{
//            [NSThread sleepForTimeInterval:timeInterval];
//            [UIScreen mainScreen].brightness = brightness + i * step;
//        }];
//    }
    
    //serialQueue
    dispatch_queue_t queue = dispatch_queue_create("com.SerialQueue", NULL);
    
    //dispatch_queue_t queue = dispatch_queue_create(<#const char * _Nullable label#>, <#dispatch_queue_attr_t  _Nullable attr#>);//dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    //dispatch_get_main_queue()
    for (CGFloat i = 1; i < times + 1; i++) {
    dispatch_async(queue, ^{
        
            //dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
            
            [NSThread sleepForTimeInterval:1 / 180.0];
            [UIScreen mainScreen].brightness = brightness + i * step;
            NSLog(@"%@",[NSNumber numberWithInt:i]);
            NSLog(@"任务所在 %@",[NSThread currentThread]);
            
            // 发送信号量
            //dispatch_semaphore_signal(sem);
    });
        }

}

+ (void)graduallySetBrightness:(CGFloat)value {
    //先记录一正常值
    [self saveDefaultBrightness];
    
    //记录下高亮亮度值
    _brightness = value;
    
//    //待还原的亮度值
//    _lastBrightness = value;
    
    _isHigh = YES;
    
    [self graduallySetBrightness0:value];
}

+ (void)graduallyResumeBrightness {
    _isHigh = NO;
    [self graduallySetBrightness0:_currentBrightness];
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
//    //待还原的亮度值
//    _lastBrightness = _currentBrightness;
    
   //X _isHigh = NO;
}




////TO DO
//+ (void)test {
//    //4.利用dispatch_semaphore_t将数据追加到数组
//
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:100];
//    // 创建为1的信号量
//    dispatch_semaphore_t sem = dispatch_semaphore_create(1);
//    for (int i = 0; i < 10000; i++) {
//        dispatch_async(queue, ^{
//            // 等待信号量
//            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
//            [arrayM addObject:[NSNumber numberWithInt:i]];
//            NSLog(@"%@",[NSNumber numberWithInt:i]);
//            // 发送信号量
//            dispatch_semaphore_signal(sem);
//        });
//    }
//
//    //    作者：VV木公子
//    //    链接：https://www.jianshu.com/p/24ffa819379c
//    //    來源：简书
//    //    简书著作权归作者所有，任何形式的转载都请联系作者获得授权并注明出处。
//}

+ (void)graduallySetBrightness0XX:(CGFloat)value{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //dispatch_cancel
    
    //    [_queue cancelAllOperations];
    NSLog(@"将要变为的亮度%f",value);
    
    CGFloat brightness = [UIScreen mainScreen].brightness;
    CGFloat step = 0.005 * ((value > brightness) ? 1 : -1);
    int times = fabs((value - brightness) / 0.005);
    
    // 创建为1的信号量
    
    if (1-1) {
        //dispatch_semaphore_t sem = dispatch_semaphore_create(1);
        dispatch_async(queue, ^{
            for (CGFloat i = 1; i < times + 1; i++) {
                //dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
                
                [NSThread sleepForTimeInterval:1 / 180.0];
                [UIScreen mainScreen].brightness = brightness + i * step;
                NSLog(@"%@",[NSNumber numberWithInt:i]);
                NSLog(@"任务所在 %@",[NSThread currentThread]);
                
                // 发送信号量
                //dispatch_semaphore_signal(sem);
            }
        });
    }
    
    //22
    //用串行queue
    
    //用GCD的信号量来实现异步线程同步操作
    if (2) {
        
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        //根据亮度差计算出时间和每个单位时间调节的亮度值
        for (CGFloat i = 1; i < times + 1; i++) {
            
            NSLog(@"zz000:1:%@",[NSThread currentThread]);
            
            if(1){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1/180.0 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
                    
                    [UIScreen mainScreen].brightness = brightness + i * step;
                    NSLog(@"%@",[NSNumber numberWithInt:i]);
                    NSLog(@"任务所在 %@",[NSThread currentThread]);
                    
                    //发送信号量
                    dispatch_semaphore_signal(sem);
                });
            }
            
            if(0){
                //注意队列
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [NSThread sleepForTimeInterval:1 / 180.0];
                    [UIScreen mainScreen].brightness = brightness + i * step;
                    NSLog(@"%@",[NSNumber numberWithInt:i]);
                    NSLog(@"任务所在 %@",[NSThread currentThread]);
                    
                    //发送信号量
                    dispatch_semaphore_signal(sem);
                });
            }
            
            NSLog(@"zz000:2:%@",[NSThread currentThread]);
            //等待信号量
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
            NSLog(@"zz000:3:%@",[NSThread currentThread]);
        }
    }
    
}


@end
