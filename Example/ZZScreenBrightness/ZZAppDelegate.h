//
//  ZZAppDelegate.h
//  ZZScreenBrightness
//
//  Created by pengzz on 01/10/2019.
//  Copyright (c) 2019 pengzz. All rights reserved.
//

@import UIKit;

@interface ZZAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, assign)NSInteger timeCount;
@property (nonatomic, strong) NSTimer *timer;

@end
