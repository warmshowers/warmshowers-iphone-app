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

#import "WSRequests.h"
#import "WSAppDelegate.h"
#import "Host.h"
#import "MKMapView+Utils.h"
#import "Feedback.h"
#import "MessageThread.h"
#import "WSHTTPClient.h"

// to prevent race conditions we do things on a single background thread

@implementation WSRequests

+(void)requestWithMapView:(MKMapView *)mapView {
    
    if ([[WSAppDelegate sharedInstance] isLoggedIn] == NO) {
        return;
    }
    
    bounds b = [mapView fetchBounds];
    
    [[WSHTTPClient sharedHTTPClient] cancelAllOperations];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithDouble:b.minLatitude], @"minlat",
                            [NSNumber numberWithDouble:b.maxLatitude], @"maxlat",
                            [NSNumber numberWithDouble:b.minLongitude], @"minlon",
                            [NSNumber numberWithDouble:b.maxLongitude], @"maxlon",
                            [NSNumber numberWithDouble:b.centerLatitude], @"centerlat",
                            [NSNumber numberWithDouble:b.centerLongitude], @"centerlon",
                            [NSNumber numberWithInteger:kMaxResults], @"limit",
                            nil];
    
    [[WSHTTPClient sharedHTTPClient] POST:@"/services/rest/hosts/by_location"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      
                                      
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
                                  }
                                  failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                                      
                                      NSLog(@"%@", @"Fail");
                                  }];
}


+(void)hostDetailsWithHost:(Host *)host
                   success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                   failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    
    NSString *path = [NSString stringWithFormat:@"/services/rest/user/%i", [host.hostid intValue]];
    
    [[WSHTTPClient sharedHTTPClient] GET:path
                              parameters:nil
                                 success:^(NSURLSessionDataTask *task, id responseObject) {
                                     
                                     Host *host = [Host fetchOrCreate:responseObject];
                                     host.last_updated_details = [NSDate date];
                                     [Host commit];
                                     
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         if (success) {
                                             success(task, responseObject);
                                         }
                                     });
                                 }
                                 failure:^(NSURLSessionDataTask *task, NSError *error) {
                                     NSHTTPURLResponse *response = (NSHTTPURLResponse *)[task response];
                                     
                                     NSInteger statusCode = [response statusCode];
                                     
                                     // 404 not found (page doesn't exist anymore)
                                     if (statusCode == 404) {
                                         [host delete];
                                         [Host commit];
                                     }
                                     
                                     if (failure) {
                                         failure(task, error);
                                     }
                                     
                                 }];
}


+(void)hostFeedbackWithHost:(Host *)host {
    
    NSString *path = [NSString stringWithFormat:@"/user/%i/json_recommendations", [host.hostid intValue]];
    
    [[WSHTTPClient sharedHTTPClient] GET:path
                              parameters:nil
                                 success:^(NSURLSessionDataTask *task, id responseObject) {
                                     
                                     Host *bhost = [host objectInCurrentThreadContextWithError:nil];
                                     
                                     NSArray *recommendations = [responseObject objectForKey:@"recommendations"];
                                     
                                     NSArray *all_nids = [recommendations pluck:@"recommendation.nid"];
                                     
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
                                     
                                 }
                                 failure:^(NSURLSessionDataTask *task, NSError *error) {
                                     NSLog(@"%@", error);
                                 }];
}


+(void)searchHostsWithKeyword:(NSString *)keyword {
    
    [[WSHTTPClient sharedHTTPClient] cancelAllOperations];
    
    NSDictionary *parms = @{
                            @"keyword" : keyword,
                            @"limit" : @100,
                            @"page" : @0
                            };
    
    [[WSHTTPClient sharedHTTPClient] POST:@"/services/rest/hosts/by_keyword"
                               parameters:parms
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      
                                      NSArray *hosts = [[responseObject objectForKey:@"accounts"] allObjects];
                                      
                                      for (NSDictionary *dict in hosts) {
                                          [Host fetchOrCreate:dict];
                                      }
                                      
                                      [Host commit];
                                      
                                  }
                                  failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  }];
}

@end