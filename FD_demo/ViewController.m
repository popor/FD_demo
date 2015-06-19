//
//  ViewController.m
//  FD_demo
//
//  Created by popor on 15/6/12.
//

#import "ViewController.h"
#import "FileDownload_FD.h"
#import "SecondVC.h"

#define FileURL	@"http://dlsw.baidu.com/sw-search-sp/soft/2a/25677/QQ_V4.0.2.1427684136.dmg"

@interface ViewController ()

@property(nonatomic, strong)UIButton * downloadBT1;
@property(nonatomic, strong)UIButton * downloadBT2;

@property(nonatomic, strong)UILabel * downloadLable1;
@property(nonatomic, strong)UILabel * downloadLable2;

@property(nonatomic, strong)UIButton * nextPageBT;
@property(nonatomic, strong)UIButton * cleanDownloaderBT;

@property(nonatomic, strong)UILabel * infoLable;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self downloadEvent];
    
    {
        self.nextPageBT=[UIButton buttonWithType:UIButtonTypeCustom];
        self.nextPageBT.frame=CGRectMake(20, 200, 220, 40);
        self.nextPageBT.center=CGPointMake(self.view.frame.size.width/2, self.nextPageBT.center.y);
        self.nextPageBT.layer.cornerRadius=3;
        self.nextPageBT.clipsToBounds=YES;
        self.nextPageBT.backgroundColor=[UIColor brownColor];
        [self.nextPageBT setTitle:@"SecondPage" forState:UIControlStateNormal];
        [self.nextPageBT addTarget:self action:@selector(showSecondPageAction) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:self.nextPageBT];
        
    }
    {
        self.cleanDownloaderBT=[UIButton buttonWithType:UIButtonTypeCustom];
        self.cleanDownloaderBT.frame=CGRectMake(20, 260, 220, 40);
        self.cleanDownloaderBT.center=CGPointMake(self.view.frame.size.width/2, self.cleanDownloaderBT.center.y);
        self.cleanDownloaderBT.layer.cornerRadius=3;
        self.cleanDownloaderBT.clipsToBounds=YES;
        self.cleanDownloaderBT.backgroundColor=[UIColor brownColor];
        [self.cleanDownloaderBT setTitle:@"CleanData" forState:UIControlStateNormal];
        [self.cleanDownloaderBT addTarget:self action:@selector(cleanDataEvent) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:self.cleanDownloaderBT];
        
    }
    {
        self.infoLable=[[UILabel alloc] init];
        self.infoLable.frame=CGRectMake(0, self.view.frame.size.height-60, self.view.frame.size.width, 40);
        self.infoLable.backgroundColor=[UIColor clearColor];
        self.infoLable.textAlignment=NSTextAlignmentCenter;
        self.infoLable.layer.cornerRadius=3;
        self.infoLable.clipsToBounds=YES;
        self.infoLable.textColor=[UIColor darkGrayColor];
        self.infoLable.text=@"";
        [self.view addSubview:self.infoLable];
    }
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)downloadEvent
{
    self.title=@"Root Page";
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
    NSString * qq=FileURL;
    NSLog(@"save to : %@",[self getWebUrlToLocalPath:qq]);
    __weak UILabel * myL;
    if (oneBT==self.downloadBT1) {
        myL=self.downloadLable1;
    }else{
        myL=self.downloadLable2;
    }
    
    [oneBT downloadFileURL:[NSURL URLWithString:qq] progress:^(CGFloat completeScale) {
        NSLog(@" Owner %i complete: %f", (int)oneBT.tag, completeScale);
        
        myL.text=[NSString stringWithFormat:@"Complete: %.02f %%",completeScale];
    } complete:^(BOOL isNetError, BOOL finished) {
        NSLog(@" Owner %i Net status:%i, Complete status: %i", (int)oneBT.tag, isNetError, finished);
        myL.text=@"Status OK";
    }];
}


- (void)showSecondPageAction
{
    SecondVC * oneVC=[[SecondVC alloc] init];
    [self.navigationController pushViewController:oneVC animated:YES];
}

- (void)cleanDataEvent
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(closeInfoLableText) object:nil];
    NSString * filePath=[self getWebUrlToLocalPath:FileURL];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        self.infoLable.text=@"I didn't download the test file";
    }else{
        NSError *error;
        if ([[NSFileManager defaultManager] removeItemAtPath:filePath error:&error] != YES){
            NSLog(@"Unable to delete file: %@", [error localizedDescription]);
            self.infoLable.text=@"clean download file error";
        }else {
            self.infoLable.text=@"clean download file success";
        }
    }
    [self performSelector:@selector(closeInfoLableText) withObject:nil afterDelay:1.5];
}

- (void)closeInfoLableText
{
    self.infoLable.text=@"";
}

@end
