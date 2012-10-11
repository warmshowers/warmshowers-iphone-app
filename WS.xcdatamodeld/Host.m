// 
//  Host.m
//  WS
//
//  Created by Christopher Meyer on 10/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Host.h"
#import "WSAppDelegate.h"

@implementation Host
@synthesize coordinate;

@dynamic notcurrentlyavailable;
@dynamic homephone;
@dynamic province;
@dynamic postal_code;
@dynamic laundry;
@dynamic fullname;
@dynamic hostid;
@dynamic country;
@dynamic kitchenuse;
@dynamic street;
@dynamic lawnspace;
@dynamic bed;
@dynamic campground;
@dynamic latitude;
@dynamic city;
@dynamic bikeshop;
@dynamic name;
@dynamic maxcyclists;
@dynamic storage;
@dynamic food;
@dynamic shower;
@dynamic longitude;
@dynamic last_updated;
@dynamic last_updated_details;
@dynamic comments;
@dynamic sag;
@dynamic motel;

+(Host *)hostWithID:(NSNumber *)hostID {
	
	NSArray *results = [Host fetchWithPredicate:[NSString stringWithFormat:@"hostid=%i", [hostID intValue]]];
	if ([results count] > 0) {
		return (Host *)[results objectAtIndex:0];		
	}

	Host *newHost = (Host *)[Host newEntity];
	newHost.hostid = hostID;
	
	return newHost;
}


-(NSString *)title {
	return self.name;
}

-(NSString *)subtitle {
	WSAppDelegate *delegate = [WSAppDelegate sharedInstance];
	
	CLLocation *userLocation = delegate.userLocation;
	
	if (userLocation != nil) {
		CLLocation *hostLocation = [[CLLocation alloc] initWithLatitude:[self.latitude floatValue] longitude:[self.longitude floatValue]];
		CLLocationDistance distance = [hostLocation distanceFromLocation:userLocation];
		[hostLocation release];

		return [NSString stringWithFormat:@"%.1f km", distance/1000];
		
	} else if ([self.street length] > 0) {
		return [NSString stringWithFormat:@"%@, %@", self.street, self.city];
	} else {
		return self.city;		
	}
}


-(BOOL)shouldUpdate {
	// two days
	return (self.last_updated_details == nil) || (abs([self.last_updated_details timeIntervalSinceNow]) > 172800 );
}


-(NSUInteger)pinColour {
	return MKPinAnnotationColorRed;
}

-(BOOL)animatesDrop {
	return NO;
}


-(CLLocationCoordinate2D)coordinate {
	CLLocationCoordinate2D c;

	c.latitude = [self.latitude floatValue];
	c.longitude = [self.longitude floatValue];
	
	return c;
}

@end