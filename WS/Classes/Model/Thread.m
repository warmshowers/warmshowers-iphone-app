//
//  Thread.m
//  WS
//
//  Created by Christopher Meyer on 10/05/15.
//  Copyright (c) 2015 Red House Consulting GmbH. All rights reserved.
//

#import "Thread.h"

#import "Host.h"
#import "Message.h"
#import "WSHTTPClient.h"

@implementation Thread

+(NSString *)modelName {
    return @"WS";
}

-(void)refresh {
    NSString *path = @"/services/rest/message/getThread";
    NSDictionary *parameters =  @{
                                  @"thread_id": [self.threadid stringValue],
                                  };
    
    
    __weak Thread *bself = self;
    
    [[WSHTTPClient sharedHTTPClient] POST:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
       
        
        NSArray *msgs = [responseObject objectForKey:@"messages"];
        
        NSArray *all_msgids = [msgs pluck:@"mid"];
        
        [Message deleteWithPredicate:[NSPredicate predicateWithFormat:@"thread = %@ AND NOT (mid IN %@)", bself, all_msgids]];
        
        
        for (NSDictionary *dict in msgs) {
            
            NSNumber *mid = @([[dict objectForKey:@"mid"] intValue]);
            NSString *body = [dict objectForKey:@"body"];
            
            NSDictionary *author = [dict objectForKey:@"author"];
            NSNumber *uid = @([[author objectForKey:@"uid"] intValue]);
            NSString *name = [author objectForKey:@"name"];
             NSTimeInterval timestamp_int = [[dict objectForKey:@"timestamp"] doubleValue];
            
            Message *message = [Message newOrExistingEntityWithPredicate:[NSPredicate predicateWithFormat:@"mid=%d", [mid intValue]]];
            [message setMid:mid];
            [message setBody:body];
            [message setThread:bself];
            
           
            message.timestamp = [NSDate dateWithTimeIntervalSince1970:timestamp_int];
            
            
            Host *host = [Host hostWithID:uid];
            [host setName:name];
            [host setHostid:uid];
            
            [message setAuthor:host];
        }
        
        [Message commit];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {

    }];

}

-(void)replyWithBody:(NSString *)body
             success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
             failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    
    NSDictionary *params = @{
                             @"body" : body,
                             @"thread_id" : self.threadid
                              };
    
    [[WSHTTPClient sharedHTTPClient] POST:@"/services/rest/message/reply"
                               parameters:params
                                  success:success
                                  failure:failure];    
}

@end
