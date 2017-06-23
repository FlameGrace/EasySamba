//
//  LMHttpHandle.m
//  Task
//
//  Created by Flame Grace on 2017/6/22.
//  Copyright © 2017年 flamegrace. All rights reserved.
//

#import "SambaDownloadHandle.h"
#import "SyncTaskQueue.h"
#import "SambaFetchTask.h"
#import "SimpleSambaDownloadTask.h"

@interface SambaDownloadHandle()
{
    int downloadHandle;
}

@property (strong, nonatomic) SyncTaskQueue *taskQueue;


@end


@implementation SambaDownloadHandle

- (instancetype)init
{
    if(self = [super init])
    {
        [[self class] create];
        self.taskQueue = [[SyncTaskQueue alloc]init];
    }
    return self;
}

- (void)dealloc
{
    self.taskQueue = nil;
}




- (void)sambaDownloadHandle:(SambaDownloadHandle *)handle downloadNewFile:(NSString *)filePath
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(sambaDownloadHandle:downloadNewFile:)])
    {
        [self.delegate sambaDownloadHandle:handle downloadNewFile:filePath];
    }
}

//向任务队列添加查询任务，重复添加只会添加一次
- (void)addQueryTask:(NSString *)path
{
    SambaFetchTask *query = [SambaFetchTask task];
    query.sambaPath = path;
    //设置固定identifier，保证任务队列同一时间只有一个query任务未执行
    query.identifier = [NSString stringWithFormat:@"%@-query-%@",NSStringFromClass([self class]),path];
    query.identifierType = TaskIdentifierInQueueUnexecutedUnique;
    query.completeHandle = ^(id  _Nullable result) {
        
        if ([result isKindOfClass:[NSArray class]])
        {
            NSArray *items = (NSArray *)result;
            for (KxSMBItem *item in items) {
                
                if([item isKindOfClass:[KxSMBItemFile class]])
                {
                    SimpleSambaDownloadTask *task = [self taskWithPath:item.path];
                    [self.taskQueue addTask:task];
                }
            }
        }
    };
    [self.taskQueue addTask:query];
}

- (void)addTask:(NSString *)path
{
    SimpleSambaDownloadTask *task = [self taskWithPath:path];
    [self.taskQueue addTask:task];
}

- (SimpleSambaDownloadTask *)taskWithPath:(NSString *)path
{
    NSString *relativePath = [[[self class]saveDir]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[path lastPathComponent]]];
    SimpleSambaDownloadTask *task = [SimpleSambaDownloadTask task];
    task.savePath = relativePath;
    task.sambaPath = path;
    task.identifier = [path lastPathComponent];
    task.identifierType = TaskIdentifierInQueueUnique;
    task.progress = ^(SambaTask *task, CGFloat percent) {
        NSLog(@"开始下载:%@,进度:%.2f",[path lastPathComponent],percent);
    };
    __weak typeof(self) weakSelf = self;
    task.completeHandle = ^(id  _Nullable result)
    {
        if(result == nil)
        {
            [weakSelf sambaDownloadHandle:self downloadNewFile:path];
        }
    };
    return task;
}

+ (NSString *)saveDir
{
    return [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"smbFiles"];
}

+ (void)clear
{
    [[NSFileManager defaultManager]removeItemAtPath:[self saveDir] error:nil];
    [self create];
}

+ (void)create
{
    //  在Documents目录下创建一个名为LaunchImage的文件夹
    NSString *path = [self saveDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    BOOL isDirExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if(!(isDirExist && isDir))
        
    {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"创建文件夹失败！");
        }
        NSLog(@"创建文件夹成功，文件路径%@",path);
    }
}

@end
