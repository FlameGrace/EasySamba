//
//  SambaFetchTask.m
//  flamegrace@hotmail.com
//
//  Created by Flame Grace on 2017/6/19.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import "SambaFetchTask.h"

@implementation SambaFetchTask

- (void)start
{
    [[KxSMBProvider sharedSmbProvider]fetchAtPath:self.sambaPath block:self.defualtKxSMBBlock];
}




@end
