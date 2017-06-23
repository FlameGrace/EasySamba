//
//  AppDelegate.h
//  SambaSimple
//
//  Created by Flame Grace on 2017/6/21.
//  Copyright © 2017年 flamegrace. All rights reserved.
//

#import <UIKit/UIKit.h>

#define  DefaultKXSMBAuth [KxSMBAuth smbAuthWorkgroup:@"WORKGROUP" username:@"" password:@""]
#define  MainScreen ([UIScreen mainScreen].bounds)


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

