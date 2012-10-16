//
//  HostEntity.h
//  WS
//
//  Created by Christopher Meyer on 2012-09-30.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RHManagedObject.h"

@class FeedbackEntity;

@interface HostEntity : RHManagedObject

@property (nonatomic, strong) NSNumber * latitude;
@property (nonatomic, strong) NSString * street;
@property (nonatomic, strong) NSString * country;
@property (nonatomic, strong) NSNumber * notcurrentlyavailable;
@property (nonatomic, strong) NSNumber * storage;
@property (nonatomic, strong) NSString * campground;
@property (nonatomic, strong) NSString * comments;
@property (nonatomic, strong) NSString * bikeshop;
@property (nonatomic, strong) NSNumber * maxcyclists;
@property (nonatomic, strong) NSString * fullname;
@property (nonatomic, strong) NSDate * member_since;
@property (nonatomic, strong) NSNumber * shower;
@property (nonatomic, strong) NSString * postal_code;
@property (nonatomic, strong) NSDate * last_updated;
@property (nonatomic, strong) NSNumber * favourite;
@property (nonatomic, strong) NSNumber * distance;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSNumber * longitude;
@property (nonatomic, strong) NSString * city;
@property (nonatomic, strong) NSNumber * laundry;
@property (nonatomic, strong) NSDate * last_updated_details;
@property (nonatomic, strong) NSString * province;
@property (nonatomic, strong) NSNumber * food;
@property (nonatomic, strong) NSDate * last_login;
@property (nonatomic, strong) NSNumber * hostid;
@property (nonatomic, strong) NSNumber * lawnspace;
@property (nonatomic, strong) NSString * motel;
@property (nonatomic, strong) NSNumber * kitchenuse;
@property (nonatomic, strong) NSNumber * bed;
@property (nonatomic, strong) NSString * preferred_notice;
@property (nonatomic, strong) NSString * homephone;
@property (nonatomic, strong) NSNumber * sag;
@property (nonatomic, strong) NSSet *feedback;
@end

@interface HostEntity (CoreDataGeneratedAccessors)

- (void)addFeedbackObject:(FeedbackEntity *)value;
- (void)removeFeedbackObject:(FeedbackEntity *)value;
- (void)addFeedback:(NSSet *)values;
- (void)removeFeedback:(NSSet *)values;

@end
