//
//  WSHTTPClient.h
//  WS
//
//  Created by Christopher Meyer on 9/18/12.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface WSHTTPClient : AFHTTPSessionManager

+(WSHTTPClient *)sharedHTTPClient;
-(BOOL)reachable;
-(void)cancelAllOperations;
-(BOOL)hasWSSessionCookie;
-(void)deleteCookies;

@end