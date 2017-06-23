//
//  STTask.m
//  flamegrace@hotmail.com
//
//  Created by Flame Grace on 2017/6/12.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import "STTask.h"

@interface STTask()


@end

@implementation STTask


+ (instancetype)task
{
    STTask *task = [[self alloc]init];
    return task;
}

- (void)dealloc
{
    [self cancel];
}

- (void)start
{
    [self taskFinish:self error:nil needRetry:NO];
}

- (void)cancel
{
    
}

- (void)taskFinish:(STTask *)task error:(NSError *)error needRetry:(BOOL)needRetry
{
    self.retryTime ++ ;
    if([self.finishHandle respondsToSelector:@selector(taskFinish:error:needRetry:)])
    {
        [self.finishHandle taskFinish:task error:error needRetry:needRetry];
    }
}

@end
