//
//  SDDownload.h
//  WanziTG
//
//  Created by popor on 15/6/11.
//  Copyright (c) 2015年 wanzi. All rights reserved.
//
// 模仿SDWebImageView方案
// change 'Compile Sources As' to 'Objective-C++'
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^FD_ProgressBlock)(CGFloat completeScale);
typedef void(^FD_CompletedBlock)(BOOL isNetError, BOOL finished);

@interface NSObject(FileDownload)

@property(nonatomic, strong)NSURL * webURL;

@property(nonatomic, strong)NSFileHandle		*fileHandle;
@property(nonatomic, strong)NSString			*destinationPath;
@property(nonatomic, strong)NSString			*temporaryPath;
@property(nonatomic, strong)NSURLConnection     *connection;
@property(nonatomic, strong)NSNumber 			*offset;
@property(nonatomic, strong)NSNumber  			*fileSize;

@property(nonatomic, strong)NSMutableDictionary	*blockDic;

// 只提供下载一种方式.
- (void)downloadFileURL:(NSURL *)url progress:(FD_ProgressBlock)progressBlock complete:(FD_CompletedBlock)completedBlock;
- (NSString *)getWebUrlToLocalPath:(NSString *)url;

@end
