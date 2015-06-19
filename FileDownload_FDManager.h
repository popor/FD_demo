//
//  FileDownload_FDManager.h
//  FD_demo
//
//  Created by popor on 15/6/18.
//

#import <Foundation/Foundation.h>


@interface FileDownload_FDManager : NSObject
@property(nonatomic, strong)NSMutableDictionary * downloadUrlDic;
@property(nonatomic, strong)NSMutableDictionary * downloaderDic;

+ (FileDownload_FDManager *)getDefaultFileDownload_FDManager;

- (BOOL)isNeedDownloadURL:(NSURL *)downloadURL withDownloader:(NSObject *)downloader;
- (void)removeURL:(NSURL *)downloadURL withDownloader:(NSObject *)downloader;

@end
