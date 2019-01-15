//
//  JCBrightness.m
//
//  Created by HJaycee on 16/8/13.
//  Copyright © 2016年 HJaycee. All rights reserved.
//

#import "JCBrightness.h"

static CGFloat _currentBrightness;
static NSOperationQueue *_queue;

@implementation JCBrightness

+ (void)initialize{
    //系统通知：手机亮度改变时发送的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_saveDefaultBrightness) name:UIScreenBrightnessDidChangeNotification object:nil];
    
    [self saveDefaultBrightness];
}

+ (void)noti_saveDefaultBrightness{
    NSLog(@"noti_saveDefaultBrightness......");//手动调系统的才会触发
    [JCBrightness saveDefaultBrightness];
}

+ (void)saveDefaultBrightness{
    _currentBrightness = [UIScreen mainScreen].brightness;
    NSLog(@"saveDefaultBrightness==%@",@(_currentBrightness));
}

+ (void)graduallySetBrightness0:(CGFloat)value{

    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
    }
    [_queue cancelAllOperations];
    NSLog(@"将要变为的亮度%f",value);
    CGFloat brightness = [UIScreen mainScreen].brightness;
    CGFloat step = 0.005 * ((value > brightness) ? 1 : -1);
    int times = fabs((value - brightness) / 0.005);
    //根据亮度差计算出时间和每个单位时间调节的亮度值
    for (CGFloat i = 1; i < times + 1; i++) {
        
        [_queue addOperationWithBlock:^{
            [NSThread sleepForTimeInterval:1 / 180.0];
            [UIScreen mainScreen].brightness = brightness + i * step;
        }];
    }
}
+ (void)graduallySetBrightness:(CGFloat)value{

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
            
            if(0){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1/180.0 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
                    
                    [UIScreen mainScreen].brightness = brightness + i * step;
                    NSLog(@"%@",[NSNumber numberWithInt:i]);
                    NSLog(@"任务所在 %@",[NSThread currentThread]);
                    
                    //发送信号量
                    dispatch_semaphore_signal(sem);
                });
            }
            
            if(1){
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

+ (void)graduallyResumeBrightness{
    [self graduallySetBrightness:_currentBrightness];
}

+ (void)fastResumeBrightness{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
    }
    [_queue cancelAllOperations];
    [_queue addOperationWithBlock:^{
        [UIScreen mainScreen].brightness = _currentBrightness;
    }];
}

//TO DO
+ (void)test {
    //4.利用dispatch_semaphore_t将数据追加到数组
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:100];
    // 创建为1的信号量
    dispatch_semaphore_t sem = dispatch_semaphore_create(1);
    for (int i = 0; i < 10000; i++) {
        dispatch_async(queue, ^{
            // 等待信号量
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
            [arrayM addObject:[NSNumber numberWithInt:i]];
            NSLog(@"%@",[NSNumber numberWithInt:i]);
            // 发送信号量
            dispatch_semaphore_signal(sem);
        });
    }
    
//    作者：VV木公子
//    链接：https://www.jianshu.com/p/24ffa819379c
//    來源：简书
//    简书著作权归作者所有，任何形式的转载都请联系作者获得授权并注明出处。
}

@end
