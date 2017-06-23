//
//  SimpleTask.m
//  Task
//
//  Created by Flame Grace on 2017/6/22.
//  Copyright © 2017年 flamegrace. All rights reserved.
//

#import "STExecuteTask.h"

@implementation STExecuteTask

- (void)start
{
    NSError *error = nil;
    if(self.execute)
    {
        error = self.execute();
    }
    [self taskFinish:self error:error needRetry:NO];
}

@end
