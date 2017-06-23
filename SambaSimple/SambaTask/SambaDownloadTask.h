//
//  SambaDownloadTask.h
//  flamegrace@hotmail.com
//
//  Created by Flame Grace on 2017/6/19.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
// samba的下载任务，支持断点续传

#import "SambaTask.h"

@interface SambaDownloadTask : SambaTask

@property (readonly, nonatomic) long downloadBytes;

@property(readonly, nonatomic) NSDate *lastModified;

@property(readonly, nonatomic) NSDate *creationTime;

@property (strong, nonatomic) NSString *savePath;

@property (assign, nonatomic) CGFloat percent;

@property (copy, nonatomic) SambaTaskProgress progress;

@property (readonly, nonatomic) long fileSize;

- (NSString *)downloadByteDescription;

@end
