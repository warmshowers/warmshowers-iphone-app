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

#import "MessageThread.h"
#import "Host.h"
#import "Message.h"
#import "WSHTTPClient.h"

@implementation MessageThread

+(NSString *)modelName {
    return @"WS";
}

+(void)newMessageToHost:(Host *)host
                subject:(NSString *)subject
                   message:(NSString *)message
                success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    
    NSDictionary *params = @{
                             @"recipients" : host.name,
                             @"subject" : subject,
                             @"body" : message
                             };
    
    [[WSHTTPClient sharedHTTPClient] POST:@"/services/rest/message/send" parameters:params success:success failure:failure];
}

-(void)replyWithMessage:(NSString *)message
                success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    
    NSDictionary *params = @{
                             @"body" : message,
                             @"thread_id" : self.threadid
                             };
    
    [[WSHTTPClient sharedHTTPClient] POST:@"/services/rest/message/reply"
                               parameters:params
                                  success:success
                                  failure:failure];
}

@end
