//
//  ZZAppDelegate.m
//  ZZScreenBrightness
//
//  Created by pengzz on 01/10/2019.
//  Copyright (c) 2019 pengzz. All rights reserved.
//

#import "ZZAppDelegate.h"

@implementation ZZAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)applicationDidEnterBackground0:(UIApplication *)application
{
    NSLog(@"DidEnterBackground");
    
    self.timeCount = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeRun) userInfo:nil repeats:true];
    
    UIApplication* app = [UIApplication sharedApplication];
    
    UIBackgroundTaskIdentifier  bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
    }];
}

- (void)timeRun{
    self.timeCount ++;
    NSLog(@"timeCount = %d",self.timeCount);
    if (self.timeCount >= 30) {
        NSLog(@"时间到");
        if (self.timer) {
            self.timeCount = 0;
            [self.timer invalidate];
            self.timer = nil;
        }
    }
}
//---------------------
//作者：淡暗云之遥
//来源：CSDN
//原文：https://blog.csdn.net/squallmouse/article/details/51445477
//版权声明：本文为博主原创文章，转载请附上博文链接！

@end
