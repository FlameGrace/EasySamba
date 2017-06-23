//
//  SMBTask.m
//  flamegrace@hotmail.com
//
//  Created by Flame Grace on 2017/6/19.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import "SambaTask.h"

@implementation SambaTask


- (KxSMBBlock)defualtKxSMBBlock
{
    KxSMBBlock block = ^(id  _Nullable result) {
        if(self.completeHandle)
        {
            self.completeHandle(result);
        }
        NSError *error = nil;
        if(result&&[result isKindOfClass:[NSError class]])
        {
            error = (NSError *)result;
        }
        [self taskFinish:self error:error needRetry:NO];
    };
    return block;
}

@end
