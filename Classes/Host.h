//
//  Host.h
//  WS
//
//  Created by Christopher Meyer on 10/16/10.
//  Copyright 2010 Red House Consulting GmbH. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import "HostEntity.h"

@interface Host : HostEntity<MKAnnotation> {
	CLLocationCoordinate2D coordinate;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

+(Host *)hostWithID:(NSNumber *)hostID;
+(NSArray *)hostsClosestToLocation:(CLLocation *)location withLimit:(int)limit;

-(NSString *)title;
-(NSString *)subtitle;

-(void)updateDistanceFromLocation:(CLLocation *)_location;

-(NSString *)infoURL;
// -(NSString *)contactURL;
-(BOOL)needsUpdate;
-(BOOL)isStale;

-(NSUInteger)pinColour;

-(NSString *)trimmedPhoneNumber;
-(CLLocation *)location;
-(NSString *)address;

-(void)purgeFeedback;

@end