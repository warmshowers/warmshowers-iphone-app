//
//  FeedbackEntity.h
//  WS
//
//  Created by Christopher Meyer on 2012-09-30.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HostEntity;

@interface FeedbackEntity : RHManagedObject

@property (nonatomic, strong) NSString * body;
@property (nonatomic, strong) NSString * hostOrGuest;
@property (nonatomic, strong) NSNumber * nid;
@property (nonatomic, strong) NSString * fullname;
@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) HostEntity *host;

@end
