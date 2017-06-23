//
//  STTask.h
//  flamegrace@hotmail.com
//
//  Created by Flame Grace on 2017/6/12.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//  定义任务类基类

#import <Foundation/Foundation.h>



/**
 定义任务标志符在任务队列中的规则

 - TaskIdentiferInQueueNoLimit: 无限制
 - TaskIdentiferInQueueUnique: 此任务标志符在任务列表中必须唯一，一般在加入任务队列时检查，已经存在则不将此任务加入到任务列表
 - TaskIdentiferInQueueUnexecutedUnique: 此任务标志符在未执行的任务列表中必须唯一，一般在加入任务队列时检查，已经存在则不将此任务加入到任务列表
 */
typedef NS_ENUM(NSInteger, TaskIdentifierInQueueType) {
    TaskIdentifierInQueueNoLimit = 0,
    TaskIdentifierInQueueUnique,
    TaskIdentifierInQueueUnexecutedUnique,
};

@class STTask;

//此代理主要用于提示任务完成情况，若用于SyncTaskQueue，则代表任务队列可以执行下一个任务
@protocol TaskFinishNotifyDelegate <NSObject>
/**
 任务完成回调

 @param task 回调的任务
 @param error 任务执行是否出现过错误
 @param needRetry 是否需要再次执行此任务
 */
- (void)taskFinish:(STTask *)task error:(NSError *)error needRetry:(BOOL)needRetry;

@end



@interface STTask : NSObject <TaskFinishNotifyDelegate>

@property (weak, nonatomic) id <TaskFinishNotifyDelegate> finishHandle;

@property (assign, nonatomic) TaskIdentifierInQueueType identifierType;

@property (strong, nonatomic) NSString *identifier; //任务标志符

@property (assign, nonatomic) NSInteger retryTime; //任务已执行次数

+ (instancetype)task;

//开始某个任务
- (void)start;
//取消任务，取消后不能恢复
- (void)cancel;

@end
