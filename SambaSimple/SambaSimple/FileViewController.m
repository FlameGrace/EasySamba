//
//  FileViewController.m
//  kxsmb project
//  https://github.com/kolyvan/kxsmb/
//
//  Created by Kolyvan on 29.03.13.
//

/*
 Copyright (c) 2013 Konstantin Bukreev All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 - Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


#import "FileViewController.h"
#import "KxSMBProvider.h"
#import <QuickLook/QuickLook.h>
#import "EasySambaHTTPServer.h"
#import "SimpleSambaDownloadTask.h"
#import <MediaPlayer/MediaPlayer.h>

@interface FileViewController () <QLPreviewControllerDelegate, QLPreviewControllerDataSource,TaskFinishNotifyDelegate>

@property (strong, nonatomic) SimpleSambaDownloadTask *task;
@property (strong, nonatomic) UIView *container;
@property (strong, nonatomic) UILabel         *nameLabel;
@property (strong, nonatomic) UILabel         *sizeLabel;
@property (strong, nonatomic) UILabel         *modifiedLabel;
@property (strong, nonatomic) UILabel         *createdLabel;
@property (strong, nonatomic) UIButton        *downloadButton;
@property (strong, nonatomic) UIButton        *previewButton;
@property (strong, nonatomic) UIProgressView  *downloadProgress;
@property (strong, nonatomic) UILabel         *downloadLabel;
@property (strong, nonatomic) NSString        *filePath;
@property (strong, nonatomic) NSDate          *timestamp;

@end

@implementation FileViewController

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    const CGSize size = self.view.bounds.size;
    const CGFloat W = size.width;
    
    
    _container = [[UIView alloc] initWithFrame:(CGRect){0,0,size}];
    _container.autoresizingMask = UIViewAutoresizingNone;
    _container.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_container];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, W - 20, 25)];
    _nameLabel.font = [UIFont boldSystemFontOfSize:16];
    _nameLabel.textColor = [UIColor darkTextColor];
    _nameLabel.opaque = NO;
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    _sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, W - 20, 25)];
    _sizeLabel.font = [UIFont systemFontOfSize:14];
    _sizeLabel.textColor = [UIColor darkTextColor];
    _sizeLabel.opaque = NO;
    _sizeLabel.backgroundColor = [UIColor clearColor];
    _sizeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    _modifiedLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, W - 20, 25)];
    _modifiedLabel.font = [UIFont systemFontOfSize:14];;
    _modifiedLabel.textColor = [UIColor darkTextColor];
    _modifiedLabel.opaque = NO;
    _modifiedLabel.backgroundColor = [UIColor clearColor];
    _modifiedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    _createdLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 85, W - 20, 25)];
    _createdLabel.font = [UIFont systemFontOfSize:14];;
    _createdLabel.textColor = [UIColor darkTextColor];
    _createdLabel.opaque = NO;
    _createdLabel.backgroundColor = [UIColor clearColor];
    _createdLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    _downloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _downloadButton.frame = CGRectMake(10, 120, 100, 30);
    _downloadButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [_downloadButton setTitle:@"Download" forState:UIControlStateNormal];
    [_downloadButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_downloadButton addTarget:self action:@selector(downloadAction) forControlEvents:UIControlEventTouchUpInside];
    
    _previewButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _previewButton.frame = CGRectMake(220, 120, 100, 30);
    _previewButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [_previewButton setTitle:@"Preview" forState:UIControlStateNormal];
    [_previewButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_previewButton addTarget:self action:@selector(directPlay) forControlEvents:UIControlEventTouchUpInside];
    
    _downloadLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 150, W - 20, 40)];
    _downloadLabel.font = [UIFont systemFontOfSize:14];;
    _downloadLabel.textColor = [UIColor darkTextColor];
    _downloadLabel.opaque = NO;
    _downloadLabel.backgroundColor = [UIColor clearColor];
    _downloadLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _downloadLabel.numberOfLines = 2;
    
    _downloadProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _downloadProgress.frame = CGRectMake(10, 190, W - 20, 30);
    _downloadProgress.hidden = YES;
    
    [_container addSubview:_nameLabel];
    [_container addSubview:_sizeLabel];
    [_container addSubview:_modifiedLabel];
    [_container addSubview:_createdLabel];
    [_container addSubview:_downloadButton];
    [_container addSubview:_downloadLabel];
    [_container addSubview:_downloadProgress];
    
    if([self.smbPath containsString:@"mp4"])
    {
        [_container addSubview:_previewButton];
    }
    
    if(!self.task)
    {
        self.task = [SimpleSambaDownloadTask task];
        self.task.sambaPath = self.smbPath;
        self.task.finishHandle = self;
        self.task.savePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",[self.smbPath lastPathComponent]]];
        self.filePath = self.task.savePath;
        __weak typeof(self) weakSelf = self;
        self.task.progress = ^(SambaTask *task, CGFloat percent) {
            SimpleSambaDownloadTask *ta = (SimpleSambaDownloadTask*)task;
            weakSelf.downloadLabel.text = [ta downloadByteDescription];
        };
        self.task.completeHandle = ^(id  _Nullable result) {
            if([result isKindOfClass:[NSError class]])
            {
                weakSelf.downloadLabel.text = @"重试";
            }
        };
    }
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    const CGSize size = self.view.bounds.size;
    const CGFloat top = [self.topLayoutGuide length];
    _container.frame = (CGRect){0, top, size.width, size.height - top};
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _nameLabel.text = self.smbPath;
    _sizeLabel.text = [NSString stringWithFormat:@"size: %ld", self.task.fileSize];
    _modifiedLabel.text = [NSString stringWithFormat:@"modified: %@", self.task.lastModified];
    _createdLabel.text = [NSString stringWithFormat:@"created: %@", self.task.creationTime];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)playVideo:(NSString *)videoPath
{
    NSURL *URL = [NSURL URLWithString:videoPath];
    MPMoviePlayerViewController  * moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:URL];
    [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
    moviePlayerController.moviePlayer.movieSourceType=MPMovieSourceTypeStreaming;
}

- (void)directPlay
{
    NSError *error = nil;
    if([[EasySambaHTTPServer shareServer]startServer:&error])
    {
        NSString *url = [[EasySambaHTTPServer shareServer]httpUrlForSambaFile:self.smbPath];
        [self playVideo:url];
        return;
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"在线预览服务不可用" message:nil delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView show];
    }
}

- (void)taskFinish:(STTask *)task error:(NSError *)error needRetry:(BOOL)needRetry
{
    if(error == nil)
    {
        [_downloadButton setTitle:@"Done" forState:UIControlStateNormal];
        _downloadButton.enabled = NO;
        
        if ([QLPreviewController canPreviewItem:[NSURL fileURLWithPath:_filePath]]) {
            
            QLPreviewController *vc = [QLPreviewController new];
            vc.delegate = self;
            vc.dataSource = self;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void) downloadAction
{
    if(self.task.downloadBytes == 0)
    {
        [_downloadButton setTitle:@"Downloading" forState:UIControlStateNormal];
        _downloadLabel.text = @"starting ..";
        _downloadProgress.progress = 0;
        _downloadProgress.hidden = NO;
        _timestamp = [NSDate date];
    }
    [self.task start];
}


#pragma mark - QLPreviewController

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return [NSURL fileURLWithPath:_filePath];
}

@end
