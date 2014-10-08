//
//  LYHRootViewController.m
//  TcpClient
//
//  Created by Charles Leo on 14-10-8.
//  Copyright (c) 2014年 Charles Leo. All rights reserved.
//

#import "LYHRootViewController.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
@interface LYHRootViewController ()

@end

@implementation LYHRootViewController
CFSocketRef _socket;
BOOL isOnLine;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"TCP客户端";
        // Custom initialization
    }
    return self;
}
- (IBAction)connection:(id)sender {
    if (isOnLine) {
        NSString * stringToSend = @"来自iOS客户端的连接";
        const char * data = [stringToSend UTF8String];
        send(CFSocketGetNative(_socket), data, strlen(data) + 1, 1);
    }
    else
    {
        NSLog(@"暂未连接服务器");
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketNoCallBack, nil, NULL);
    if (_socket != nil) {
        //定义sockaddr_in类型变量,该变量将作为CFSocket的地址
        struct sockaddr_in addr4;
        memset(&addr4, 0, sizeof(addr4));
        addr4.sin_len = sizeof(addr4);
        addr4.sin_family = AF_INET;
        //设置该服务器监听本机任意可用的IP地址
        addr4.sin_addr.s_addr = htonl(INADDR_ANY);
        //设置服务监听地址
        addr4.sin_addr.s_addr = inet_addr("192.168.5.22");
        //设置服务器监听端口
        addr4.sin_port = htons(30000);
        //将IPv4的地址转换为CFDataRef
        CFDataRef address = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&addr4, sizeof(addr4));
        
        CFSocketError result = CFSocketConnectToAddress(_socket, address, 5);
        if (result == kCFSocketSuccess) {
            isOnLine = YES;
            //启动新线程来读取服务器响应的数据
            //[NSThread detachNewThreadSelector:@selector(readStream) toTarget:self withObject:nil];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                char buffer[2048];
                int hasRead;
                while ((hasRead = (int)recv(CFSocketGetNative(_socket), buffer, sizeof(buffer), 0)))
                {
                    NSLog(@"Receive is %@",[[NSString alloc]initWithBytes:buffer length:hasRead encoding:NSUTF8StringEncoding]);
                }
            });
        }
    }
}
- (void)readStream
{
    char buffer[2048];
    int hasRead;
    while ((hasRead = (int)recv(CFSocketGetNative(_socket), buffer, sizeof(buffer), 0)))
    {
        NSLog(@"Receive is %@",[[NSString alloc]initWithBytes:buffer length:hasRead encoding:NSUTF8StringEncoding]);
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
