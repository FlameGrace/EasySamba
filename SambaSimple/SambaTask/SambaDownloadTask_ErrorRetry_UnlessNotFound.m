//
//  SambaDownloadTask_ErrorRetry_UnlessNotFound.m
//  flamegrace@hotmail.com
//
//  Created by Flame Grace on 2017/6/20.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import "SambaDownloadTask_ErrorRetry_UnlessNotFound.h"

@implementation SambaDownloadTask_ErrorRetry_UnlessNotFound

- (void)taskFinish:(STTask *)task error:(NSError *)error needRetry:(BOOL)needRetry
{
    //除非是没有找到该文件，否则需要重试下载
    if(error&&error.code != KxSMBErrorInvalidPath)
    {
        needRetry = YES;
    }
    [super taskFinish:task error:error needRetry:needRetry];
}

@end
