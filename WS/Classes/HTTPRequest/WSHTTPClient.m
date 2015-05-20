//
//  WSHTTPClient.m
//  WS
//
//  Created by Christopher Meyer on 9/18/12.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.
//

#import "WSHTTPClient.h"
#import "WSAppDelegate.h"

@implementation WSHTTPClient

+(WSHTTPClient *)sharedHTTPClient {
    
    static WSHTTPClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[WSHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.warmshowers.org/"]];
        [[_sharedClient reachabilityManager] startMonitoring];
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    });
    
    [_sharedClient setDataTaskDidReceiveResponseBlock:^NSURLSessionResponseDisposition(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response) {
        
        NSHTTPURLResponse *r = (NSHTTPURLResponse *)response;
        NSInteger statusCode = r.statusCode;
        
        if (statusCode >= 400) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[WSAppDelegate sharedInstance] autologin];
            });
            
            return NSURLSessionResponseCancel;
        } else {
            return NSURLSessionResponseAllow;
        }
        
        
    }];
    
    
    return _sharedClient;
}


-(BOOL)reachable {
    return [[AFNetworkReachabilityManager sharedManager] isReachable];
}

-(void)cancelAllOperations {
    [[self.operationQueue operations] makeObjectsPerformSelector:@selector(cancel)];
}

-(BOOL)hasWSSessionCookie {
    NSURL *baseURL = [self baseURL];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:baseURL];
    
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.name isEqualToString:@"SESSca3ec806b9aee9140beb6c03142b4638"]) {
            return YES;
        }
    }
    
    return NO;
}

-(void)deleteCookies {
    NSURL *baseURL = [self baseURL];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:baseURL];
    
    for (NSHTTPCookie *cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

@end