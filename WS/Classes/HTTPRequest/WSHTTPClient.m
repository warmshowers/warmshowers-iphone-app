//
//  Copyright (C) 2015 Warm Showers Foundation
//  http://warmshowers.org/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "WSHTTPClient.h"
#import "WSAppDelegate.h"

@implementation WSHTTPClient

+(WSHTTPClient *)sharedHTTPClient {
    
    static WSHTTPClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
         //  _sharedClient = [[WSHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.warmshowers.org/"]];
        
        
      _sharedClient = [[WSHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.wsupg.net/"]];
     [_sharedClient.requestSerializer setAuthorizationHeaderFieldWithUsername:@"drupal" password:@"drupal"];
        
        
        [_sharedClient.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        [[_sharedClient reachabilityManager] startMonitoring];
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        
        
   
        
        
        // this is to allow a request that returns text/plain
       //  [_sharedClient setResponseSerializer:[AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[[AFJSONResponseSerializer serializer], [AFHTTPResponseSerializer serializer] ]]];
       
         [_sharedClient setResponseSerializer:[AFJSONResponseSerializer serializer]];
        
        
        [_sharedClient setCompletionQueue:dispatch_queue_create("org.warmshowers.app", NULL)];
        
        
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

/*
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
 */

-(void)deleteCookies {
    NSURL *baseURL = [self baseURL];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:baseURL];
    
    for (NSHTTPCookie *cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

@end