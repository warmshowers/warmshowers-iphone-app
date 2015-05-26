//
//  Thread.h
//  WS
//
//  Created by Christopher Meyer on 10/05/15.
//  Copyright (c) 2015 Red House Consulting GmbH. All rights reserved.
//

#import "_Thread.h"
#import "Host.h"

@interface Thread : _Thread


+(void)newMessageToHost:(Host *)host
                subject:(NSString *)subject
                   message:(NSString *)message
                success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

-(void)replyWithMessage:(NSString *)message
             success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
             failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

-(void)refreshMessages;

@end