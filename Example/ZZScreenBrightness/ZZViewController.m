//
//  ZZViewController.m
//  ZZScreenBrightness
//
//  Created by pengzz on 01/10/2019.
//  Copyright (c) 2019 pengzz. All rights reserved.
//

#import "ZZViewController.h"
#import "QRCodeVC.h"

@interface ZZViewController ()

@end

@implementation ZZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self addBtn];
}

-(void)addBtn{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btn];
    btn.frame =CGRectMake(0, 0, 120, 40);
    btn.center = self.view.center;
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 20;
    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:@"二维码" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)btnClick{
    QRCodeVC *vc = [[QRCodeVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
