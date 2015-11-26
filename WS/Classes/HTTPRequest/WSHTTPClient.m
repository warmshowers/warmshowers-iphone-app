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



@interface WSHTTPClient()

@property (nonatomic) dispatch_queue_t backgroundQueue;

@end


@implementation WSHTTPClient

+(WSHTTPClient *)sharedHTTPClient {
    
    static WSHTTPClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        
        _sharedClient = [[WSHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.warmshowers.org/"]];
        
        //  _sharedClient = [[WSHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.wsupg.net/"]];
        // [_sharedClient.requestSerializer setAuthorizationHeaderFieldWithUsername:@"drupal" password:@"drupal"];
        
        [_sharedClient.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        [[_sharedClient reachabilityManager] startMonitoring];
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        
        [_sharedClient setResponseSerializer:[AFJSONResponseSerializer serializer]];
        [_sharedClient setBackgroundQueue:dispatch_queue_create("org.warmshowers.ios", NULL)];
    });
    
    [_sharedClient setDataTaskDidReceiveResponseBlock:^NSURLSessionResponseDisposition(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response) {
        NSHTTPURLResponse *r = (NSHTTPURLResponse *)response;
        NSInteger statusCode = r.statusCode;
        
        if (statusCode >= 400) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[WSAppDelegate sharedInstance] autologin];
            });
            
          //  return NSURLSessionResponseCancel;
        } else {
           // return NSURLSessionResponseAllow;
        }
        
        return NSURLSessionResponseAllow;
    }];
    
    return _sharedClient;
}

-(BOOL)reachable {
    return [[AFNetworkReachabilityManager sharedManager] isReachable];
}

-(void)cancelAllOperations {
    [[self.operationQueue operations] makeObjectsPerformSelector:@selector(cancel)];
}

-(void)deleteCookies {
    NSURL *baseURL = [self baseURL];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:baseURL];
    
    for (NSHTTPCookie *cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}



-(AnyPromise *)loginWithUsername:(NSString *)username password:(NSString *)password {
    
    [self deleteCookies];
    
    NSDictionary *parameters = @{@"username" : username, @"password" : password};
    
    return [self POST:@"/services/rest/user/login" parameters:parameters].thenOn(self.backgroundQueue, ^(id responseObject, AFHTTPRequestOperation *operation) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            NSString *token = [responseObject objectForKey:@"token"];
            [WSHTTPClient.sharedHTTPClient.requestSerializer setValue:token forHTTPHeaderField:@"X-CSRF-Token"];
            
            NSDictionary *user = [responseObject objectForKey:@"user"];
            
            NSInteger userid = [[user objectForKey:@"uid"] intValue];
            
            NSNumber *hostid = @(userid);
            NSString *name = [user objectForKey:@"name"];
            
            [[Host hostWithID:hostid] setName:name];
            [Host commit];
            
            [[WSAppDelegate sharedInstance] setUserID:userid];
            
        };
    });
}


-(AnyPromise *)refreshThreads {

    return [self POST:@"/services/rest/message/get" parameters:nil].thenOn(self.backgroundQueue, ^(id responseObject, AFHTTPRequestOperation *operation) {
        NSArray *all_ids = [[responseObject pluck:@"thread_id"] valueForKey:@"integerValue"];
        
        [MessageThread deleteWithPredicate:[NSPredicate predicateWithFormat:@"NOT (threadid IN %@)", all_ids]];
        
        // the signed in user
        NSInteger userid = [[WSAppDelegate sharedInstance] userID];
        
        for (NSDictionary *dict in responseObject) {
            
            NSArray *participants = [dict objectForKey:@"participants"];
            
            // make sure all participants exist
            for (NSDictionary *participant in participants) {
                NSNumber *hostid = @([[participant objectForKey:@"uid"] intValue]);
                NSString *name = [participant objectForKey:@"name"];
                [[Host hostWithID:hostid] setName:name];
            }
            
            NSString *userIDString = [NSString stringWithFormat: @"%ld", (long)userid];
            
            NSDictionary *participant2 = [[participants filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid != %@", userIDString]] firstObject];
            
            if (participant2) {
                
                NSNumber *threadid = @([[dict objectForKey:@"thread_id"] intValue]);
                NSString *subject = [dict objectForKey:@"subject"];
                
                NSNumber *is_new= @([[dict objectForKey:@"is_new"] intValue]);
                NSNumber *count = @([[dict objectForKey:@"count"] intValue]);
                NSNumber *last_updated = [dict objectForKey:@"last_updated"];
                
                MessageThread *thread = [MessageThread newOrExistingEntityWithPredicate:[NSPredicate predicateWithFormat:@"threadid=%d", [threadid intValue]]];
                [thread setThreadid:threadid];
                [thread setSubject:subject];
                [thread setIs_new:is_new];
                [thread setCount:count];
                thread.last_updated = [NSDate dateWithTimeIntervalSince1970:last_updated.doubleValue];
                
                NSNumber *hostid = @([[participant2 objectForKey:@"uid"] intValue]);
                Host *host = [Host hostWithID:hostid];
                [thread setUser:host];
            }
        }
        
        [MessageThread commit];
    });
}

-(AnyPromise *)markThreadAsRead:(MessageThread *)thread {
    NSDictionary *parameters = @{
                                 @"thread_id" : thread.threadid,
                                 @"status" : @0
                                 };
    
    return [[WSHTTPClient sharedHTTPClient] POST:@"/services/rest/message/markThreadRead" parameters:parameters];
}



@end