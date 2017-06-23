//
//  SMBTask.h
//  flamegrace@hotmail.com
//
//  Created by Flame Grace on 2017/6/19.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import "STTask.h"
#import <UIKit/UIKit.h>
#import "KxSMBProvider.h"

@class SambaTask;

typedef void(^SambaTaskProgress)(SambaTask *task, CGFloat percent);

@interface SambaTask : STTask

@property (strong, nonatomic) NSString *sambaPath;

@property (copy, nonatomic) KxSMBBlock completeHandle;


/**
 ^(id  _Nullable result) 
 {
    if(self.completeHandle)
    {
        self.completeHandle(result);
    }
    if(result&&[result isKindOfClass:[NSError class]])
    {
        [self taskFinish:self error:result needRetry:NO];
        return;
    }
    [self taskFinish:self error:nil needRetry:NO];
 }
 */
- (KxSMBBlock)defualtKxSMBBlock;

@end
