//
//  ViewController.m
//  手势解锁
//
//  Created by 付玮 on 15/7/25.
//  Copyright (c) 2015年 付玮. All rights reserved.
//

#import "ViewController.h"
#import "LocalView.h"

@interface ViewController ()<LocalViewDelegate>
@property (nonatomic, copy) NSString  *passWord;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    LocalView *password = [[LocalView alloc]init];
    password.delegate = self;
    
}

- (void)lockViewDidClickWithView:(LocalView *)localView andPassWord:(NSString *)passWord
{
    
}


@end
