//
//  SMBViewController.m
//  flamegrace@hotmail.com
//
//  Created by Flame Grace on 17/1/4.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import "SMBViewController.h"
#import "KxSMBProvider.h"
#import "FileViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "EasySambaHTTPServer.h"
#import "SambaDownloadHandle.h"

@interface SMBViewController () <UITableViewDelegate, UITableViewDataSource,SambaDownloadHandleDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSString *genPath;
@property (strong, nonatomic) NSString *lastPath;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) SambaDownloadHandle *handle;

@end

@implementation SMBViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.handle = [[SambaDownloadHandle alloc]init];
    self.handle.delegate = self;
    [self tableView];
    [self reloadPath];
    self.genPath = [self.path mutableCopy];
    [self copy:nil];
    if(![[EasySambaHTTPServer shareServer]startServer:nil])
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Http本地服务器启动失败" message:nil delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sambaDownloadHandle:(SambaDownloadHandle *)handle downloadNewFile:(NSString *)filePath
{
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)playVideo:(NSString *)videoPath
{
    NSURL *URL = [NSURL URLWithString:videoPath];
    MPMoviePlayerViewController  * moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:URL];
    [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
    moviePlayerController.moviePlayer.movieSourceType=MPMovieSourceTypeStreaming;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        if(self.lastPath.length > 1 &&self.lastPath)
        {
            return 1;
        }
        return 0;
    }
    
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellIdentifier];
    }
    
    if(indexPath.section == 0)
    {
        cell.textLabel.text = @"......";
        cell.detailTextLabel.text = @"返回上一级";
        cell.textLabel.textColor = [UIColor blueColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        
        KxSMBItem *item = self.items[indexPath.row];
        NSString *fileName = [item.path.lastPathComponent stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        cell.textLabel.text = fileName;
        cell.textLabel.textColor = [UIColor blackColor];
        if ([item isKindOfClass:[KxSMBItemTree class]])
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text =  @"";
            
        } else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lld", item.stat.size];
        }

    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 0)
    {
        if(self.lastPath.length > 1 &&self.lastPath)
        {
            self.path = [self.lastPath mutableCopy];
            self.lastPath = [self.lastPath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"/%@",self.lastPath.lastPathComponent] withString:@""];
            
            if([self.path isEqualToString:self.genPath]||[[NSString stringWithFormat:@"%@/",self.path] isEqualToString:self.genPath])
            {
                self.lastPath = nil;
            }
            [self reloadPath];
        }
        return;
    }
    
    KxSMBItem *item = self.items[indexPath.row];
    if ([item isKindOfClass:[KxSMBItemTree class]])
    {
        self.lastPath = [self.path mutableCopy];
        self.path = item.path;
        [self reloadPath];
        [self.handle addQueryTask:item.path];
    }
    else if ([item isKindOfClass:[KxSMBItemFile class]])
    {
        [self.handle addTask:item.path];
        FileViewController *vc = [[FileViewController alloc]init];
        vc.smbPath = item.path;
        [self.navigationController pushViewController:vc animated:YES];
    }
}



- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        KxSMBItem *item = self.items[indexPath.row];
        [[KxSMBProvider sharedSmbProvider] removeAtPath:item.path block:^(id  _Nullable result) {
            NSLog(@"completed:%@", result);
            if (![result isKindOfClass:[NSError class]]) {
                [self reloadPath];
            }
        }];
    }
}

- (void) updateStatus: (id) status
{
    UIFont *font = [UIFont boldSystemFontOfSize:16];
    
    if ([status isKindOfClass:[NSString class]])
    {
        
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        CGSize sz = activityIndicator.frame.size;
        const float H = font.lineHeight + sz.height + 10;
        const float W = self.tableView.frame.size.width;
        
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, W, H)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, W, font.lineHeight)];
        label.text = status;
        label.font = font;
        label.textColor = [UIColor grayColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.opaque = NO;
        label.backgroundColor = [UIColor clearColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [v addSubview:label];
        
        if(![self.refreshControl isRefreshing])
            [self.refreshControl beginRefreshing];
        
        self.tableView.tableHeaderView = v;
        
    }
    else if ([status isKindOfClass:[NSError class]])
    {
        
        const float W = self.tableView.frame.size.width;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, W, font.lineHeight)];
        label.text = ((NSError *)status).localizedDescription;
        label.font = font;
        label.textColor = [UIColor redColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.opaque = NO;
        label.backgroundColor = [UIColor clearColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        self.tableView.tableHeaderView = label;
        
        [self.refreshControl endRefreshing];
        
    }
    else
    {
        
        self.tableView.tableHeaderView = nil;
        
        [self.refreshControl endRefreshing];
    }
}


- (void)btnClickToPrevPage
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)reloadPath
{
    if (self.path.length)
    {
        self.title = self.path.lastPathComponent;
    }
    else
    {
        self.path = @"smb://";
        self.title = @"共享文件";
    }
    
    self.items = nil;
    [self.tableView reloadData];
    [self updateStatus:@"正在刷新..."];
    
     [[KxSMBProvider sharedSmbProvider] fetchAtPath:self.path block:^(id  _Nullable result)
    {
         if ([result isKindOfClass:[NSError class]])
         {
             
             [self updateStatus:result];
             
         }
         else
         {
             
             [self updateStatus:nil];
             
             if ([result isKindOfClass:[NSArray class]])
             {
                 self.items = [result copy];
                 
             }
             else if ([result isKindOfClass:[KxSMBItem class]])
             {
                 [self.items addObject:result];
             }
             
             [self.tableView reloadData];
         }
     }];
}


- (NSMutableArray *)items
{
    if(!_items)
    {
        _items = [[NSMutableArray alloc]init];
    }
    
    return _items;
}

- (UITableView *)tableView
{
    if(!_tableView)
    {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, MainScreen.size.width, MainScreen.size.height) style:UITableViewStylePlain];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_tableView];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(reloadPath) forControlEvents:UIControlEventValueChanged];
        [_tableView addSubview:self.refreshControl];
    }
    
    return _tableView;
}


- (IBAction)changes:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"改变地址" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *field = [alertView textFieldAtIndex:0];
    field.text = self.path;
    [alertView show];
}
- (IBAction)copy:(id)sender {
    self.path = @"smb://192.168.2.1/";
    self.genPath = [self.path mutableCopy];
    self.lastPath = nil;
    [self reloadPath];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        self.path = [alertView textFieldAtIndex:0].text;
        self.genPath = [self.path mutableCopy];
        self.lastPath = nil;
        [self reloadPath];
    }
}


@end
