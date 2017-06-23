//
//  DownloadTaskQueue.h
//  flamegrace@hotmail.com
//
//  Created by Flame Grace on 2017/6/12.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//  同步串行任务队列，一次只执行一个任务

#import <Foundation/Foundation.h>
#import "STTask.h"

@interface SyncTaskQueue : NSObject
/*当前正在执行的任务*/
@property (readonly, nonatomic) STTask *currentTask;
/*缓存已添加的所有的任务列表，可用于筛选是否重复添加任务*/
@property (readonly, nonatomic) NSMutableArray *cacheTasks;
/*保存未执行的任务列表*/
@property (readonly, nonatomic) NSMutableArray *unexecutedTasks;
/*设置任务执行间隔，默认为0s*/
@property (assign, nonatomic) NSTimeInterval executeDuration;
//设置任务重试间隔，默认为5s*/
@property (assign, nonatomic) NSTimeInterval retryDuration;
/*是否在执行任务中*/
@property (readonly, nonatomic) BOOL isExecuting; //是否在执行任务
/*是否已暂停所有任务*/
@property (readonly, nonatomic) BOOL isPause;
/**
 初始化，并设置执行任务的线程
 */
- (instancetype)initWithQueue:(dispatch_queue_t)queue;

- (void)addTask:(STTask *)task;

- (void)removeTask:(STTask *)task;

- (STTask *)taskByIdentifier:(NSString *)identifier;
//暂停所有任务
- (void)pasue;
//重新开始
- (void)resume;

@end
