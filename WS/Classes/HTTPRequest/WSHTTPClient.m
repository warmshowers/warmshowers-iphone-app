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
#import "MKMapView+Utils.h"
#import "Feedback.h"
#import "Message.h"

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
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:self.baseURL];
    
    for (NSHTTPCookie *cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}


-(AnyPromise *)requestWithMapView:(MKMapView *)mapView {
    
    static NSInteger const maxResults = 50;
    
    bounds b = [mapView fetchBounds];
    
    [self cancelAllOperations];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithDouble:b.minLatitude], @"minlat",
                                [NSNumber numberWithDouble:b.maxLatitude], @"maxlat",
                                [NSNumber numberWithDouble:b.minLongitude], @"minlon",
                                [NSNumber numberWithDouble:b.maxLongitude], @"maxlon",
                                [NSNumber numberWithDouble:b.centerLatitude], @"centerlat",
                                [NSNumber numberWithDouble:b.centerLongitude], @"centerlon",
                                [NSNumber numberWithInteger:maxResults], @"limit",
                                nil];
    
    return [self POST:@"/services/rest/hosts/by_location" parameters:parameters].thenOn(self.backgroundQueue, ^(id responseObject, AFHTTPRequestOperation *operation) {
        
        NSArray *hosts = [responseObject objectForKey:@"accounts"];
        
        for (NSDictionary *dict in hosts) {
            NSString *hostidstring = [dict objectForKey:@"uid"];
            NSNumber *hostid = [NSNumber numberWithInteger:[hostidstring integerValue]];
            
            // This is a lightweight synchronization, which differs from [Host fetchOrCreate] due to the limited
            // number of fields.  We don't called [Host fetchOrCreate:] since that will wipe out many fields values.
            Host *host = [Host hostWithID:hostid];
            
            // TODO: This is a bug in the API call
            host.fullname = [dict objectForKey:@"fullname"];
            host.name = [dict objectForKey:@"name"];
            host.street = [dict objectForKey:@"street"];
            host.city = [dict objectForKey:@"city"];
            host.province = [dict objectForKey:@"province"];
            host.postal_code = [dict objectForKey:@"postal_code"];
            host.country = [dict objectForKey:@"country"];
            host.last_updated_map = [NSDate date];
            
            // host.last_updated = [NSDate date];
            host.notcurrentlyavailable = [NSNumber numberWithInt:0];
            
            NSString *latitude = [dict objectForKey:@"latitude"];
            NSString *longitude = [dict objectForKey:@"longitude"];
            
            host.latitude = [NSNumber numberWithDouble:[latitude doubleValue]];
            host.longitude = [NSNumber numberWithDouble:[longitude doubleValue]];
        }
        
        [Host commit];

    });
        
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
            
            [[WSUserDefaults sharedInstance] setUserID:userid];
            
        };
    });
}


-(AnyPromise *)refreshThreads {
    
    return [self POST:@"/services/rest/message/get" parameters:nil].thenOn(self.backgroundQueue, ^(id responseObject, AFHTTPRequestOperation *operation) {
        NSArray *all_ids = [[responseObject pluck:@"thread_id"] valueForKey:@"integerValue"];
        
        [MessageThread deleteWithPredicate:[NSPredicate predicateWithFormat:@"NOT (threadid IN %@)", all_ids]];
        
        // the signed in user
        NSInteger userid = [[WSUserDefaults sharedInstance] userID];
        
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

-(AnyPromise *)hostDetailsWithHost:(Host *)host {
    NSString *path = [NSString stringWithFormat:@"/services/rest/user/%i", [host.hostid intValue]];
    
    return [self GET:path parameters:nil].thenOn(self.backgroundQueue, ^(id responseObject, AFHTTPRequestOperation *operation) {
        Host *host = [Host fetchOrCreate:responseObject];
        host.last_updated_details = [NSDate date];
        [Host commit];
    });
}

-(AnyPromise *)markThreadAsRead:(MessageThread *)thread {
    NSDictionary *parameters = @{
                                 @"thread_id" : thread.threadid,
                                 @"status" : @0
                                 };
    
    return [[WSHTTPClient sharedHTTPClient] POST:@"/services/rest/message/markThreadRead" parameters:parameters];
}

-(AnyPromise *)hostFeedbackWithHost:(Host *)host {
    NSString *path = [NSString stringWithFormat:@"/user/%li/json_recommendations", (long)host.hostid.integerValue];
    
    return [self GET:path parameters:nil].thenOn(self.backgroundQueue, ^(id responseObject, AFHTTPRequestOperation *operation) {
        
        Host *bhost = [host objectInCurrentThreadContextWithError:nil];
        
        NSArray *recommendations = [responseObject objectForKey:@"recommendations"];
        
        NSArray *all_nids = [[recommendations pluck:@"recommendation.nid"] valueForKey:@"integerValue"];
        
        [Feedback deleteWithPredicate:[NSPredicate predicateWithFormat:@"host = %@ AND NOT (nid IN %@)", host, all_nids]];
        
        for (NSDictionary *feedback in recommendations) {
            
            NSDictionary *dict = [feedback objectForKey:@"recommendation"];
            
            NSString *snid = [dict objectForKey:@"nid"];
            NSString *recommender = [[dict objectForKey:@"fullname" defaultValue:[dict objectForKey:@"name" defaultValue:@"Unknown"]] trim];
            NSString *body = [[dict objectForKey:@"body"] trim];
            NSString *hostOrGuest = [dict objectForKey:@"field_guest_or_host_value"];
            NSNumber *recommendationDate = [dict objectForKey:@"field_hosting_date_value"];
            NSString *ratingValue = [dict objectForKey:@"field_rating_value"];
            
            NSNumber *nid = [NSNumber numberWithInteger:[snid integerValue]];
            NSDate *rDate = [NSDate dateWithTimeIntervalSince1970:[recommendationDate doubleValue]];
            
            Feedback *feedback = [Feedback feedbackWithID:nid];
            [feedback setBody:body];
            [feedback setFullname:recommender];
            [feedback setHostOrGuest:hostOrGuest];
            [feedback setDate:rDate];
            [feedback setRatingValue:ratingValue];
            
            [bhost addFeedbackObject:feedback];
        }
        
        [Feedback commit];
        
    });
    
}

-(AnyPromise *)searchHostsWithKeyword:(NSString *)keyword {
    
    // redundant
    // [self cancelAllOperations];
    
    NSDictionary *parameters = @{
                                 @"keyword" : keyword,
                                 @"limit" : @100,
                                 @"page" : @0
                                 };
    
    return [self POST:@"/services/rest/hosts/by_keyword" parameters:parameters].thenOn(self.backgroundQueue, ^(id responseObject, AFHTTPRequestOperation *operation) {
        
        NSArray *hosts = [[responseObject objectForKey:@"accounts"] allObjects];
        
        for (NSDictionary *dict in hosts) {
            [Host fetchOrCreate:dict];
        }
        
        [Host commit];
    });
    
}

// Is this the right place for this?
-(AnyPromise *)refreshMessagesForThread:(MessageThread *)thread {
    
    NSString *path = @"/services/rest/message/getThread";
    
    NSDictionary *parameters = @{@"thread_id": thread.threadid.stringValue};
    
    return [self POST:path parameters:parameters].thenOn(self.backgroundQueue, ^(id responseObject, AFHTTPRequestOperation *operation) {
        
        MessageThread *myThread = [thread objectInCurrentThreadContextWithError:nil];
        
        NSArray *msgs = [responseObject objectForKey:@"messages"];
        NSArray *all_msgids = [[msgs pluck:@"mid"] valueForKey:@"integerValue"];
        
        // delete any local messages that don't exist anymore
        [Message deleteWithPredicate:[NSPredicate predicateWithFormat:@"thread = %@ AND NOT (mid IN %@)", myThread, all_msgids]];
        
        // We don't want to update objects unnecessarily.  This causes a number of problems with the core data update.
        // It's probably safe to assume that messages don't change.
        NSArray *currentMessages = [[myThread.messages.allObjects pluck:@"mid"] arrayByPerformingSelector:@selector(stringValue)];
        NSArray *newMsgs = [msgs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (mid in %@)", currentMessages]];
        
        for (NSDictionary *dict in newMsgs) {
            
            NSNumber *mid = @([[dict objectForKey:@"mid"] intValue]);
            NSString *body = [dict objectForKey:@"body"];
            
            NSString *author_string;
            
            if ([[dict objectForKey:@"author"] isKindOfClass:[NSDictionary class]]) {
                author_string = [dict valueForKeyPath:@"author.uid"];
            } else {
                author_string = [dict objectForKey:@"author"];
            }
            
            NSNumber *author_id = @([author_string intValue]);
            
            NSTimeInterval timestamp_int = [[dict objectForKey:@"timestamp"] doubleValue];
            
            Message *message = [Message newOrExistingEntityWithPredicate:[NSPredicate predicateWithFormat:@"mid=%d", [mid intValue]]];
            [message setMid:mid];
            [message setBody:body];
            [message setThread:myThread];
            [message setTimestamp:[NSDate dateWithTimeIntervalSince1970:timestamp_int]];
            
            Host *host = [Host hostWithID:author_id];
            // [host setName:name];
            // [host setHostid:author];
            
            [message setAuthor:host];
        }
        
        [Message commit];
    });
    
}

@end
