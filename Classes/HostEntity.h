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

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSNumber * notcurrentlyavailable;
@property (nonatomic, retain) NSNumber * storage;
@property (nonatomic, retain) NSString * campground;
@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSString * bikeshop;
@property (nonatomic, retain) NSNumber * maxcyclists;
@property (nonatomic, retain) NSString * fullname;
@property (nonatomic, retain) NSDate * member_since;
@property (nonatomic, retain) NSNumber * shower;
@property (nonatomic, retain) NSString * postal_code;
@property (nonatomic, retain) NSDate * last_updated;
@property (nonatomic, retain) NSNumber * favourite;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSNumber * laundry;
@property (nonatomic, retain) NSDate * last_updated_details;
@property (nonatomic, retain) NSString * province;
@property (nonatomic, retain) NSNumber * food;
@property (nonatomic, retain) NSDate * last_login;
@property (nonatomic, retain) NSNumber * hostid;
@property (nonatomic, retain) NSNumber * lawnspace;
@property (nonatomic, retain) NSString * motel;
@property (nonatomic, retain) NSNumber * kitchenuse;
@property (nonatomic, retain) NSNumber * bed;
@property (nonatomic, retain) NSString * preferred_notice;
@property (nonatomic, retain) NSString * homephone;
@property (nonatomic, retain) NSNumber * sag;
@property (nonatomic, retain) NSSet *feedback;
@end

@interface HostEntity (CoreDataGeneratedAccessors)

- (void)addFeedbackObject:(FeedbackEntity *)value;
- (void)removeFeedbackObject:(FeedbackEntity *)value;
- (void)addFeedback:(NSSet *)values;
- (void)removeFeedback:(NSSet *)values;

@end
