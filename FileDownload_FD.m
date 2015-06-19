//
//  SDDownload.m
//
//  Created by popor on 15/6/11.
//

#import "FileDownload_FD.h"
#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>
#import "FileDownload_FDManager.h"

#define kTHDownLoadTask_TempSuffix  @".TempDownload"
#define ProgressID					@"ProgressID"
#define CompleteID					@"CompleteID"

// copy of SDWebImage
#define dispatch_main_sync_safe_FD(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

//
#define dispatch_main_async_safe_FD(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}


@implementation NSObject(FileDownload)

- (void)downloadFileURL:(NSURL *)url progress:(FD_ProgressBlock)progressBlock complete:(FD_CompletedBlock)completedBlock
{
    if (!url) {
        return;
    }else{
        FileDownload_FDManager * oneFDManager=[FileDownload_FDManager getDefaultFileDownload_FDManager];
        if (![oneFDManager isNeedDownloadURL:url withDownloader:self]) {
            if (self == [oneFDManager.downloaderDic objectForKey:url.absoluteString]) {
                // Do Nothing.
            }else{
                // Let beforeDownloader monitor the newDownloader.
                NSObject * beforeDownloader=[oneFDManager.downloaderDic objectForKey:url.absoluteString];
                [beforeDownloader monitorDownloader:self Progress:progressBlock complete:completedBlock];
            }
            return;
        }
    }
    self.webURL=url;
    if (!self.blockDic) {
        self.blockDic=[[NSMutableDictionary alloc] init];
        [self.blockDic setObject:progressBlock 	forKey:ProgressID];
        [self.blockDic setObject:completedBlock forKey:CompleteID];
    }
    if (!self.otherProgressBlockArray) {
        self.otherProgressBlockArray=[[NSMutableArray alloc] init];
    }
    if (!self.otherCompletedBlockArray) {
        self.otherCompletedBlockArray=[[NSMutableArray alloc] init];
    }
    if (!self.otherDownloaderArray) {
        self.otherDownloaderArray=[[NSMutableArray alloc] init];
    }
    dispatch_main_async_safe_FD(^{
        [self startDownloadFile];
    });
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [self startDownloadFile];
    //    });
}

- (void)monitorDownloader:(NSObject *)downloader Progress:(FD_ProgressBlock)progressBlock complete:(FD_CompletedBlock)completedBlock
{
    if (![self.otherDownloaderArray containsObject:downloader]) {
        [self.otherDownloaderArray addObject:downloader];
        if (![self.otherProgressBlockArray containsObject:progressBlock]) {
            [self.otherProgressBlockArray addObject:progressBlock];
        }
        if (![self.otherCompletedBlockArray containsObject:completedBlock]) {
            [self.otherCompletedBlockArray addObject:completedBlock];
        }
    }
}

- (void)startDownloadFile
{
    self.destinationPath=[self getWebUrlToLocalPath:self.webURL.absoluteString];
    self.temporaryPath	=[self.destinationPath stringByAppendingFormat:kTHDownLoadTask_TempSuffix];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.destinationPath]) {
        [self completeProgress:1.0];
        [self completeNetError:NO isDownloaded:YES];
        return;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.temporaryPath]) {
        // create cache file
        BOOL createSucces = [[NSFileManager defaultManager] createFileAtPath:self.temporaryPath contents:nil attributes:nil];
        if (!createSucces){
            NSLog(@"create cache file failed!!!!!");
            return;
        }
    }
    [self initConnection];
    [self startInThread:NO];
}

- (void)initConnection
{
    [self closeConnection];
    [self closeFileWrite];
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.temporaryPath];
    self.offset = [NSNumber numberWithUnsignedLongLong:[self.fileHandle seekToEndOfFile]];
    NSString *range = [NSString stringWithFormat:@"bytes=%llu-",[self.offset unsignedLongLongValue]];
    //NSLog(@"range:%@",range);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.webURL];
    
    [request addValue:range forHTTPHeaderField:@"Range"];
    [request setTimeoutInterval:60];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)reStart
{
    [self startInThread:YES];
}

- (void)startInThread:(BOOL)isShouldDownload
{
    BOOL done = !isShouldDownload;
    if (self.connection==nil) {
        done=YES;
    }
    
    while (!done) {
        if (self.connection!=nil) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];// 这个频率真好.
        }else{
            NSLog(@"connection is nil...");
        }
        if (self.connection==nil) {
            done=YES;
        }
        sleep(0.1f);
    }
}

- (void)stopDownload
{
    [self closeConnection];
    [self startInThread:NO];
}

- (void)closeConnection
{
    [self.connection cancel];
    self.connection = nil;
}
- (void)closeFileWrite
{
    [self.fileHandle closeFile];
    self.fileHandle = nil;
}

- (void)deleteFile
{
    [[NSFileManager defaultManager] removeItemAtPath:self.destinationPath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:self.temporaryPath   error:nil];
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response expectedContentLength] != NSURLResponseUnknownLength){
        self.fileSize = [NSNumber numberWithUnsignedLongLong:(unsigned long long)[response expectedContentLength]+[self.offset unsignedLongLongValue]];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)aData
{
    if (!self.fileHandle) {
        //NSLog(@"fileHandle is error......");
        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.temporaryPath];
        [self.fileHandle writeData:aData];
        self.offset = [NSNumber numberWithUnsignedLongLong:[self.fileHandle offsetInFile]];
    }else{
        //NSLog(@"fileHandle is ok......");
        [self.fileHandle writeData:aData];
        self.offset = [NSNumber numberWithUnsignedLongLong:[self.fileHandle offsetInFile]];
    }
    CGFloat progress = [self.offset unsignedLongLongValue]*1.0/[self.fileSize unsignedLongLongValue];
    [self completeProgress:progress];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self closeConnection];
    [self.fileHandle closeFile];
    [self completeNetError:YES isDownloaded:NO];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.temporaryPath==nil || self.destinationPath==nil) {
        return;
    }
    [[NSFileManager defaultManager] moveItemAtPath:self.temporaryPath toPath:self.destinationPath error:nil];
    
    [self stopDownload];
    [self closeFileWrite];
    [self completeNetError:NO isDownloaded:YES];
}

- (void)completeProgress:(CGFloat)progress
{
    FD_ProgressBlock _myPB=[self.blockDic objectForKey:ProgressID];
    dispatch_main_sync_safe_FD(^{
        _myPB(progress);
        for (FD_ProgressBlock _otherPB in self.otherProgressBlockArray) {
            _otherPB(progress);
        }
    });
}

- (void)completeNetError:(BOOL)isNetError isDownloaded:(BOOL)isDownloaded
{
    FD_CompletedBlock myCB=[self.blockDic objectForKey:CompleteID];
    dispatch_main_sync_safe_FD(^{
        myCB(isNetError, isDownloaded);
        for (FD_CompletedBlock _otherCB in self.otherCompletedBlockArray) {
            _otherCB(isNetError, isDownloaded);
        }
    });
    [self removeManagerMonitor];
    //    return;
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        myCB(isNetError, isDownloaded);
    //    });
}

- (void)removeManagerMonitor
{
    FileDownload_FDManager * oneFDManager=[FileDownload_FDManager getDefaultFileDownload_FDManager];
    [oneFDManager removeURL:self.webURL withDownloader:self];
    
    [self.otherDownloaderArray 		removeAllObjects];
    [self.otherCompletedBlockArray 	removeAllObjects];
    [self.otherProgressBlockArray 	removeAllObjects];
}


//------------------------------------------------------------------------------
#pragma mark - SetGet
- (void)setWebURL:(NSURL *)webURL
{
    objc_setAssociatedObject(self, @"webURL_FD", webURL, OBJC_ASSOCIATION_RETAIN);
}

- (NSURL *)webURL
{
    return objc_getAssociatedObject(self, @"webURL_FD");
}

- (void)setFileHandle:(NSFileHandle *)fileHandle
{
    objc_setAssociatedObject(self, @"fileHandle_FD", fileHandle, OBJC_ASSOCIATION_RETAIN);
}

- (NSFileHandle *)fileHandle
{
    return objc_getAssociatedObject(self, @"fileHandle_FD");
}

- (void)setDestinationPath:(NSString *)destinationPath
{
    objc_setAssociatedObject(self, @"destinationPath_FD", destinationPath, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)destinationPath
{
    return objc_getAssociatedObject(self, @"destinationPath_FD");
}

- (void)setTemporaryPath:(NSString *)temporaryPath
{
    objc_setAssociatedObject(self, @"temporaryPath_FD", temporaryPath, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)temporaryPath
{
    return objc_getAssociatedObject(self, @"temporaryPath_FD");
}

- (void)setConnection:(NSURLConnection *)connection
{
    objc_setAssociatedObject(self, @"connection_FD", connection, OBJC_ASSOCIATION_RETAIN);
}

- (NSURLConnection *)connection
{
    return objc_getAssociatedObject(self, @"connection_FD");
}

- (void)setOffset:(NSNumber *)offset
{
    objc_setAssociatedObject(self, @"offset_FD", offset, OBJC_ASSOCIATION_RETAIN);
}

- (NSNumber *)offset
{
    return objc_getAssociatedObject(self, @"offset_FD");
}

- (void)setFileSize:(NSNumber *)fileSize
{
    objc_setAssociatedObject(self, @"fileSize_FD", fileSize, OBJC_ASSOCIATION_RETAIN);
}

- (NSNumber *)fileSize
{
    return objc_getAssociatedObject(self, @"fileSize_FD");
}

- (void)setBlockDic:(NSMutableDictionary *)blockDic
{
    objc_setAssociatedObject(self, @"blockDic_FD", blockDic, OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableDictionary *)blockDic
{
    return objc_getAssociatedObject(self, @"blockDic_FD");
}

- (void)setOtherDownloaderArray:(NSMutableArray *)otherDownloaderArray
{
    objc_setAssociatedObject(self, @"otherDownloaderArray", otherDownloaderArray, OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableArray *)otherDownloaderArray
{
    return objc_getAssociatedObject(self, @"otherDownloaderArray");
}

- (void)setOtherProgressBlockArray:(NSMutableArray *)otherProgressBlockArray
{
    objc_setAssociatedObject(self, @"otherProgressBlockArray", otherProgressBlockArray, OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableArray *)otherProgressBlockArray
{
    return objc_getAssociatedObject(self, @"otherProgressBlockArray");
}

- (void)setOtherCompletedBlockArray:(NSMutableArray *)otherCompletedBlockArray
{
    objc_setAssociatedObject(self, @"otherCompletedBlockArray", otherCompletedBlockArray, OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableArray *)otherCompletedBlockArray
{
    return objc_getAssociatedObject(self, @"otherCompletedBlockArray");
}

/**
 * copy of SDWebImage.
 * use middle path /com.hackemist.SDWebImageCache.default/
 */
- (NSString *)getWebUrlToLocalPath:(NSString *)url
{
    NSString * SDWebImagePath=@"/com.hackemist.SDWebImageCache.default/";
    [self createCachesFolder:SDWebImagePath];
    
    NSMutableString * cachesPath;
    NSArray  * pathsToDocuments = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    cachesPath = [[NSMutableString alloc] initWithString:[pathsToDocuments objectAtIndex:0]];
    [cachesPath setString:[cachesPath stringByReplacingOccurrencesOfString:@"/Documents" withString:@"/Library/Caches"]];
    
    const char *str = [url UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    [cachesPath appendString:SDWebImagePath];
    [cachesPath appendString:filename];
    return (NSString *)cachesPath;
}


- (void)createCachesFolder:(NSString *)folderName
{
    /* 路径 */
    NSArray  * pathsToDocuments = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSMutableString * cachPath = [[NSMutableString alloc] initWithString:[pathsToDocuments objectAtIndex:0]];
    [cachPath setString:[cachPath stringByReplacingOccurrencesOfString:@"/Documents" withString:@"/Library/Caches"]];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", cachPath, folderName]
                              withIntermediateDirectories:YES attributes:nil error:nil];
    
    // end.
}

@end
