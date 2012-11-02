//
//  Host.m
//  WS
//
//  Created by Christopher Meyer on 10/16/10.
//  Copyright 2010 Red House Consulting GmbH. All rights reserved.
//

#import "Host.h"
#import "WSAppDelegate.h"
#import "CLLocation+Bearing.h"
#import "Feedback.h"

@implementation Host
@synthesize coordinate;

// TODO: To be moved into RHManagedObject
+(void)initialize {
	
	if (self == [Host class]) {
        const static NSInteger schemaVersion = 5;
        
        NSString *key = [NSString stringWithFormat:@"RHSchemaVersion-%@", [self modelName]];
        NSInteger version = [[NSUserDefaults standardUserDefaults] integerForKey:key];
        
        if (version != schemaVersion) {
            [self deleteStore];
            [[NSUserDefaults standardUserDefaults] setInteger:schemaVersion forKey:key];
        }
    }
}

+(NSString *)entityName {
	return @"HostEntity";
}

+(NSString *)modelName {
	return @"WS";
}

+(Host *)hostWithID:(NSNumber *)hostID {

	
	Host *host = [Host getWithPredicate:[NSPredicate predicateWithFormat:@"hostid=%i", [hostID intValue]]];
	
	if (host) {
		return host;
	}
    
	host = [Host newEntity];
	host.hostid = hostID;
	
	return host;
}


+(NSArray *)hostsClosestToLocation:(CLLocation *)location withLimit:(int)limit {
	CLLocationCoordinate2D c = location.coordinate;
	NSPredicate *predicate;
	int factor = 1;
	
	CLLocationDegrees minLatitude, maxLatitude, minLongitude, maxLongitude;
	
	for (int i=1; i < 180; i++) {
		minLatitude = c.latitude - ( i * factor);
		maxLatitude = c.latitude + ( i * factor);
		minLongitude = c.longitude - (i * factor);
		maxLongitude = c.longitude + (i *factor);
		
		predicate = [NSPredicate predicateWithFormat:@"%f < latitude AND latitude < %f AND %f < longitude AND longitude < %f AND notcurrentlyavailable != 1", minLatitude, maxLatitude, minLongitude, maxLongitude];
        
		// NSArray *test = [Host fetchWithPredicate:predicate];
		
		if ( [Host countWithPredicate:predicate] > limit ) {
			return [Host fetchWithPredicate:predicate];
		}
	}
	
	return [Host fetchWithPredicate:predicate];
}


-(NSString *)title {
	return self.fullname ? self.fullname : self.name;
}

-(void)updateDistanceFromLocation:(CLLocation *)_location {
	CLLocationCoordinate2D coord = [self coordinate];
	CLLocation *host_location = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
    
	double distance = [_location distanceFromLocation:host_location];
	
	self.distance = [NSNumber numberWithDouble:distance];
	
}

-(NSString *)subtitle {
	WSAppDelegate *delegate = [WSAppDelegate sharedInstance];
	
	CLLocation *userLocation = [delegate userLocation];
	
	if (userLocation != nil) {
		CLLocation *host_location = [self location];
		
		NSString *bearing = NSLocalizedStringFromBearing( [userLocation bearingToLocation:host_location] );
		double distance = [host_location distanceFromLocation:userLocation];
		
		NSInteger units = [[NSUserDefaults standardUserDefaults] integerForKey:@"units"];
		
		if (units == 0) {
			return [NSString stringWithFormat:@"%.1f km %@", distance/1000, bearing];
		} else {
			return [NSString stringWithFormat:@"%.1f miles %@", distance/1609.344, bearing];
		}
        
        
	} else if ([self.street length] > 0) {
		return [NSString stringWithFormat:@"%@, %@", self.street, self.city];
	} else {
		return self.city;
	}
}

-(NSString *)address {
	NSMutableArray *array = [NSMutableArray array];
	
	NSString *street = (self.street) && ([self.street length] > 0) ? self.street : nil;
	
	if (self.postal_code) {
		[array addObject:self.postal_code];
	}
	
	if (self.city) {
		[array addObject:self.city];
	}
	
	if (self.country) {
		[array addObject:[self.country uppercaseString]];
	}
    
	if (street) {
		return [NSString stringWithFormat:@"%@\n%@", street, [array componentsJoinedByString:@", "]];
	} else {
		return [array componentsJoinedByString:@", "];
	}
}

-(NSString *)infoURL {
	return [NSString stringWithFormat:@"http://www.warmshowers.org/user/%@/", self.hostid];
}

/*
 -(NSString *)contactURL {
 // return [NSString stringWithFormat:@"http://www.warmshowers.org/user/%@/contact", self.hostid];
 return [NSString stringWithFormat:@"/user/%@/contact", self.hostid];
 }*/

-(BOOL)needsUpdate {
	// one week
	return ([self isStale] || (self.last_updated_details == nil) || (abs([self.last_updated_details timeIntervalSinceNow]) > 604800 ));
	
	// two weeks
	// return (self.last_updated_details == nil) || (abs([self.last_updated_details timeIntervalSinceNow]) > 1209600 );
}

-(BOOL)isStale {
	// return (self.last_updated_details == nil) || (abs([self.last_updated_details timeIntervalSinceNow]) > 60 );
	// two weeks
	return (self.last_updated_details == nil) || (abs([self.last_updated_details timeIntervalSinceNow]) > 1209600 );
}

-(NSUInteger)pinColour {
	if ([self.favourite boolValue]) {
		return MKPinAnnotationColorGreen;
	} else if (self.last_updated_details != nil) {
		// indicates we have cached data
		return MKPinAnnotationColorPurple;
	} else {
		return MKPinAnnotationColorRed;
	}
}

-(BOOL)animatesDrop {
	return NO;
}

-(NSString *)trimmedPhoneNumber {
	// return [self.homephone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSArray *comps = [self.homephone componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
	NSMutableArray *words = [NSMutableArray array];
	for (NSString *comp in comps) {
		if([comp length] > 0) {
			[words addObject:comp];
		}
	}
	
	return [words componentsJoinedByString:@""];
}


-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    self.latitude = [NSNumber numberWithFloat:newCoordinate.latitude];
    self.longitude = [NSNumber numberWithFloat:newCoordinate.longitude];
}

-(CLLocationCoordinate2D)coordinate {
	CLLocationCoordinate2D c;
    
	c.latitude = [self.latitude floatValue];
	c.longitude = [self.longitude floatValue];
	
	return c;
}

// convenience method
-(CLLocation *)location {
	return [[CLLocation alloc] initWithLatitude:[self.latitude doubleValue] longitude:[self.longitude doubleValue]];
}

-(void)purgeFeedback {
    for (Feedback *feedback in self.feedback) {
        [feedback delete];
    }
}

@end