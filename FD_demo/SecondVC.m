//
//  SecondVC.m
//  FD_demo
//
//  Created by popor on 15/6/19.
//  Copyright (c) 2015年 wanzi. All rights reserved.
//

#import "SecondVC.h"
#import "FileDownload_FD.h"

@interface SecondVC ()

@property(nonatomic, strong)UIButton * downloadBT1;
@property(nonatomic, strong)UIButton * downloadBT2;

@property(nonatomic, strong)UILabel * downloadLable1;
@property(nonatomic, strong)UILabel * downloadLable2;

@end

@implementation SecondVC

- (id)init{
    if (self=[super init]) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    self.title=@"SecondVC";
    
    [self downloadEvent];
}

- (void)downloadEvent
{
    self.downloadBT1=[self getBT:@"FD 1"];
    self.downloadBT2=[self getBT:@"FD 2"];
    self.downloadBT1.tag=1;
    self.downloadBT2.tag=2;
    
    self.downloadBT1.frame=CGRectMake(20,  80, 70, 40);
    self.downloadBT2.frame=CGRectMake(20, 130, 70, 40);
    
    self.downloadLable1=[self addButtonLabel:self.downloadBT1];
    self.downloadLable2=[self addButtonLabel:self.downloadBT2];
}

- (UIButton *)getBT:(NSString *) title
{
    UIButton * oneBT=[UIButton buttonWithType:UIButtonTypeCustom];
    oneBT.frame=CGRectMake(0, 0, 70, 40);
    oneBT.layer.cornerRadius=3;
    oneBT.clipsToBounds=YES;
    oneBT.backgroundColor=[UIColor brownColor];
    [oneBT setTitle:title forState:UIControlStateNormal];
    [oneBT addTarget:self action:@selector(downloadAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:oneBT];
    return oneBT;
}

- (UILabel *)addButtonLabel:(UIButton *)oneBT
{
    UILabel * oneL=[[UILabel alloc] init];
    oneL.frame=CGRectMake(CGRectGetMaxX(oneBT.frame)+ 10, oneBT.frame.origin.y, 200, 40);
    oneL.backgroundColor=[UIColor brownColor];
    oneL.layer.cornerRadius=3;
    oneL.clipsToBounds=YES;
    oneL.textColor=[UIColor blackColor];
    oneL.text=@"download";
    [self.view addSubview:oneL];
    
    return oneL;
}

- (void)downloadAction:(UIButton *)oneBT
{
    NSString * qq=@"http://dlsw.baidu.com/sw-search-sp/soft/2a/25677/QQ_V4.0.2.1427684136.dmg";
    NSLog(@"save to : %@",[self getWebUrlToLocalPath:qq]);
    __weak UILabel * myL;
    if (oneBT==self.downloadBT1) {
        myL=self.downloadLable1;
    }else{
        myL=self.downloadLable2;
    }
    
    [oneBT downloadFileURL:[NSURL URLWithString:qq] progress:^(CGFloat completeScale) {
        NSLog(@"∆∆∆∆∆∆∆∆∆∆∆∆ %i complete: %f", (int)oneBT.tag, completeScale);
        
        myL.text=[NSString stringWithFormat:@"Complete: %.02f %%",completeScale];
    } complete:^(BOOL isNetError, BOOL finished) {
        NSLog(@"∆∆∆∆∆∆∆∆∆∆∆∆ %i Net status:%i, Complete status: %i", (int)oneBT.tag, isNetError, finished);
        myL.text=@"Status OK";
    }];
    
    
}

@end
