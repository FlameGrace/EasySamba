//
//  LMMovieHTTPConnection.m
//  KxSMBSample
//
//  Created by Flame Grace on 16/11/30.
//  Copyright © 2016年 Konstantin Bukreev. All rights reserved.
//

#import "EasySambaHTTPConnection.h"
#import "EasySambaFileHTTPResponse.h"
#import "KxSMBProvider.h"
#import "EasySambaHTTPServer.h"

@implementation EasySambaHTTPConnection

static EasySambaFileHTTPResponse *cacheEasySambaFileHTTPResponse = nil;

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    if(cacheEasySambaFileHTTPResponse)
    {
        return cacheEasySambaFileHTTPResponse;
    }
    NSString *videoPath = [EasySambaHTTPServer sambaFilePathForHttpUrl:path];
    if(videoPath)
    {
        EasySambaFileHTTPResponse *response = [[EasySambaFileHTTPResponse alloc]initWithSMBFilePath:videoPath forConnection:self];
        cacheEasySambaFileHTTPResponse = response;
        return response;
    }
    return [super httpResponseForMethod:method URI:path];
}

- (void)die
{
    cacheEasySambaFileHTTPResponse = nil;
    [super die];
}

@end
