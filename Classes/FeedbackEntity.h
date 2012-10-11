//
//  FeedbackEntity.h
//  WS
//
//  Created by Christopher Meyer on 2012-09-30.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RHManagedObject.h"

@class HostEntity;

@interface FeedbackEntity : RHManagedObject

@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * hostOrGuest;
@property (nonatomic, retain) NSNumber * nid;
@property (nonatomic, retain) NSString * fullname;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) HostEntity *host;

@end
