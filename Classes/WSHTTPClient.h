//
//  WSHTTPClient.h
//  WS
//
//  Created by Christopher Meyer on 9/18/12.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.
//

#import "AFHTTPClient.h"

@interface WSHTTPClient : AFHTTPClient

+(WSHTTPClient *)sharedHTTPClient;
-(BOOL)reachable;

@end
