//
//  Host.h
//  WS
//
//  Created by Christopher Meyer on 10/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import "MKAnnotationExtended.h"
#import "NSManagedObjectExtended.h"

@interface Host :  NSManagedObjectExtended<MKAnnotationExtended> {
	CLLocationCoordinate2D coordinate;
}

@property (nonatomic, retain) NSNumber * notcurrentlyavailable;
@property (nonatomic, retain) NSString * homephone;
@property (nonatomic, retain) NSString * province;
@property (nonatomic, retain) NSString * postal_code;
@property (nonatomic, retain) NSNumber * laundry;
@property (nonatomic, retain) NSString * fullname;
@property (nonatomic, retain) NSNumber * hostid;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSNumber * kitchenuse;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSNumber * lawnspace;
@property (nonatomic, retain) NSNumber * bed;
@property (nonatomic, retain) NSString * campground;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * bikeshop;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * maxcyclists;
@property (nonatomic, retain) NSNumber * storage;
@property (nonatomic, retain) NSNumber * food;
@property (nonatomic, retain) NSNumber * shower;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSDate * last_updated;
@property (nonatomic, retain) NSDate * last_updated_details;
@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSNumber * sag;
@property (nonatomic, retain) NSString * motel;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
-(NSString *)title;
-(NSString *)subtitle;
-(BOOL)shouldUpdate;

+(Host *)hostWithID:(NSNumber *)hostID;

@end