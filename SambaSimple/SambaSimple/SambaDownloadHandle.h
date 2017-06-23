//
//  LMHttpHandle.h
//  Task
//
//  Created by Flame Grace on 2017/6/22.
//  Copyright © 2017年 flamegrace. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SambaDownloadHandle;

@protocol SambaDownloadHandleDelegate <NSObject>

- (void)sambaDownloadHandle:(SambaDownloadHandle *)handle downloadNewFile:(NSString *)filePath;

@end

@interface SambaDownloadHandle : NSObject <SambaDownloadHandleDelegate>

@property (weak, nonatomic) id <SambaDownloadHandleDelegate> delegate;

- (void)addQueryTask:(NSString *)path;

- (void)addTask:(NSString *)path;

+ (void)clear;

@end
