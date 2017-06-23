//
//  SambaDownloadTask.m
//  flamegrace@hotmail.com
//
//  Created by Flame Grace on 2017/6/19.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import "SambaDownloadTask.h"

@interface SambaDownloadTask()

@property (strong, nonatomic) NSFileHandle *fileHandle;

@property (readwrite, assign, nonatomic) long downloadBytes;

@property (strong, nonatomic) KxSMBItemFile *smbFile;

@end


@implementation SambaDownloadTask

- (NSString *)downloadByteDescription
{
    CGFloat value;
    NSString *unit;
    
    if (self.downloadBytes < 1024) {
        
        value = self.downloadBytes;
        unit = @"B";
        
    } else if (self.downloadBytes < 1048576) {
        
        value = self.downloadBytes / 1024.f;
        unit = @"KB";
        
    } else {
        
        value = self.downloadBytes / 1048576.f;
        unit = @"MB";
    }
    NSString *description = [NSString stringWithFormat:@"downloaded %.1f%@ (%.1f%%)",value, unit,self.percent * 100.f];
    return description;
}

- (long)fileSize
{
    return self.smbFile.stat.size;
}

- (NSDate *)creationTime
{
    return self.smbFile.stat.creationTime;
}

- (NSDate *)lastModified
{
     return self.smbFile.stat.lastModified;
}

- (NSFileHandle *)fileHandle
{
    if(!_fileHandle)
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        if(![fm fileExistsAtPath:self.savePath])
        {
            [fm createFileAtPath:self.savePath contents:nil attributes:nil];
        }
        _fileHandle = [NSFileHandle fileHandleForWritingToURL:[NSURL fileURLWithPath:self.savePath]
                                                        error:nil];
        [_fileHandle seekToEndOfFile];
    }
    
    return _fileHandle;
}


- (void)setSambaPath:(NSString *)sambaPath
{
    [super setSambaPath:sambaPath];
    id result = [[KxSMBProvider sharedSmbProvider]fetchAtPath:self.sambaPath];
    if(result && [result isKindOfClass:[KxSMBItemFile class]])
    {
        self.smbFile = result;
    }
}


- (void)start
{
    if(!self.fileHandle || !self.smbFile)
    {
        NSError *error = [NSError errorWithDomain:@"com.flamegrace@hotmail.com.kxsmb" code:1 userInfo:nil];
        self.defualtKxSMBBlock(error);
        return;
    }
    self.downloadBytes = self.fileHandle.offsetInFile;
    
    id result = [self.smbFile seekToFileOffset:self.downloadBytes whence:SEEK_SET];
    
    if([result isKindOfClass:[NSNumber class]])
    {
        [self download];
        return ;
    }
    self.defualtKxSMBBlock(result);
}


- (void)download
{
    __weak typeof(self) weakSelf = self; ;
    [self.smbFile readDataOfLength:1024*1024
                             block:^(id result)
     {
         
         __strong typeof(weakSelf) self = weakSelf;
         [self updateDownloadStatus:result];
     }];
}

- (void)cancel
{
    [self closeFiles];
}


- (void)updateDownloadStatus:(id)result
{
    if ([result isKindOfClass:[NSError class]])
    {
        [self closeFiles];
        self.defualtKxSMBBlock(result);
        return;
    }
    else if ([result isKindOfClass:[NSData class]])
    {
        
        NSData *data = result;
        self.downloadBytes += data.length;
        self.percent = (float)self.downloadBytes / (float)self.smbFile.stat.size;
        
        if (self.fileHandle)
        {
            [self.fileHandle writeData:data];
            if(self.progress)
            {
                self.progress(self, self.percent);
            }
            if(self.downloadBytes >= self.smbFile.stat.size || self.percent >= 1)
            {
                [self closeFiles];
                self.defualtKxSMBBlock(nil);
            }
            else
            {
                [self download];
            }
        }
    }
}

- (void)closeFiles
{
    if (self.fileHandle)
    {
        
        [self.fileHandle closeFile];
        self.fileHandle = nil;
    }
    if(self.smbFile)
    {
        [self.smbFile close];
    }
}



@end
