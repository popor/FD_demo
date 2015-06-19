//
//  FileDownload_FDManager.m
//  FD_demo
//
//  Created by popor on 15/6/18.
//
#import "FileDownload_FDManager.h"


@implementation FileDownload_FDManager

+ (FileDownload_FDManager *)getDefaultFileDownload_FDManager
{
    static FileDownload_FDManager * _FileDownload_FDManager;
    @synchronized(self){
        if (_FileDownload_FDManager==nil) {
            _FileDownload_FDManager = [[self alloc] init];
        }
    }
    return _FileDownload_FDManager;
}

- (BOOL)isNeedDownloadURL:(NSURL *)downloadURL withDownloader:(NSObject *)downloader
{
    if (!self.downloadUrlDic) {
        self.downloadUrlDic=[[NSMutableDictionary alloc] init];
    }
    if (!self.downloaderDic) {
        self.downloaderDic=[[NSMutableDictionary alloc] init];
    }
    NSObject * beforeDownloader=[self.downloaderDic objectForKey:downloadURL.absoluteString];
    if (beforeDownloader) {
        return NO;
    }else{
        [self.downloadUrlDic setObject:downloadURL forKey:downloadURL.absoluteString];
        [self.downloaderDic  setObject:downloader  forKey:downloadURL.absoluteString];
        return YES;
    }
}


- (void)removeURL:(NSURL *)downloadURL withDownloader:(NSObject *)downloader
{
    if (!self.downloadUrlDic) {
        self.downloadUrlDic=[[NSMutableDictionary alloc] init];
    }
    if (!self.downloaderDic) {
        self.downloaderDic=[[NSMutableDictionary alloc] init];
    }
    [self.downloadUrlDic removeObjectForKey:downloadURL.absoluteString];
    [self.downloaderDic  removeObjectForKey:downloadURL.absoluteString];
}

@end
