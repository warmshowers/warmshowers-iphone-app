//
//  TrackMyTourRequest.h
//  TrackMyTour
//
//  Created by Christopher Meyer on 1/7/10.
//  Copyright 2010 Red House Consulting GmbH. All rights reserved.
//

#define kMaxResults 50

#import <MapKit/MapKit.h>
@class Host;

@interface WSRequests : NSObject<NSXMLParserDelegate>

+(void)loginWithUsername:(NSString *)username
                password:(NSString *)password
                success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                 failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;


+(void)requestWithMapView:(MKMapView *)mapView;
+(void)hostDetailsWithHost:(Host *)host;
+(void)hostFeedbackWithHost:(Host *)host;

+(void)searchHostsWithKeyword:(NSString *)keyword;
+(void)refreshThreadsSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

@end

