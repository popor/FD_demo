//
//  ViewController.m
//  FD_demo
//
//  Created by popor on 15/6/12.
//  Copyright (c) 2015年 wanzi. All rights reserved.
//

#import "ViewController.h"
#import "FileDownload_FD.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self downloadEvent];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)downloadEvent
{
    UILabel * oneL=[[UILabel alloc] init];
    oneL.frame=CGRectMake(20, 80, 100, 40);
    oneL.textColor=[UIColor blackColor];
    oneL.text=@"download";
    [self.view addSubview:oneL];
    {
        self.view.backgroundColor=[UIColor brownColor];
        NSString * qq=@"http://dlsw.baidu.com/sw-search-sp/soft/2a/25677/QQ_V4.0.2.1427684136.dmg";
        NSLog(@"save to : %@",[self getWebUrlToLocalPath:qq]);
        __weak UILabel * myL=oneL;
        [self downloadFileURL:[NSURL URLWithString:qq] progress:^(CGFloat completeScale) {
            NSLog(@"complete: %f", completeScale);
            
            myL.text=[NSString stringWithFormat:@"Complete scale: %.02f %%",completeScale];
        } complete:^(BOOL isNetError, BOOL finished) {
            NSLog(@"Net status:%i, Complete status: %i", isNetError, finished);
            myL.text=@"Status OK";
        }];
    
    }
}
@end
