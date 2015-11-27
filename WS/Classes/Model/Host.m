//
//  Copyright (C) 2015 Warm Showers Foundation
//  http://warmshowers.org/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
        const static NSInteger schemaVersion = 40;
        
        NSString *key = [NSString stringWithFormat:@"RHSchemaVersion-%@", [self modelName]];
        NSInteger version = [[NSUserDefaults standardUserDefaults] integerForKey:key];
        
        if (version != schemaVersion) {
            [self deleteStore];
            [[NSUserDefaults standardUserDefaults] setInteger:schemaVersion forKey:key];
        }
    }
}

+(NSString *)modelName {
    return @"WS";
}

+(Host *)hostWithID:(NSNumber *)hostID {
    
    Host *host = [Host getWithPredicate:[NSPredicate predicateWithFormat:@"hostid=%d", [hostID intValue]]];
    
    if (host) {
        return host;
    }
    
    host = [Host newEntity];
    host.hostid = hostID;
    
    return host;
}

+(Host *)fetchOrCreate:(NSDictionary *)dict {
    
    NSNumber *hostid = @([[dict objectForKey:@"uid"] intValue]);
    
    Host *host = [Host hostWithID:hostid];
    
    host.bed = [NSNumber numberWithInt:[[dict objectForKey:@"bed"] intValue]];
    host.bikeshop = [dict objectForKey:@"bikeshop"];
    host.campground = [dict objectForKey:@"campground"];
    host.city = [dict objectForKey:@"city"];
    
    host.comments = [[dict objectForKey:@"comments"] trim];
    host.country = [dict objectForKey:@"country"];
    host.food = [NSNumber numberWithInt:[[dict objectForKey:@"food"] intValue]];
    host.fullname = [[dict objectForKey:@"fullname"] trim];
    host.homephone = [dict objectForKey:@"homephone"];
    host.mobilephone = [dict objectForKey:@"mobilephone"];
    
    // host.imageURL = [dict objectForKey:@"profile_image_profile_picture"];
    host.imageURL = [dict objectForKey:@"profile_image_mobile_photo_456"];
    host.imageThumbURL = [dict objectForKey:@"profile_image_profile_picture"];
    
    host.kitchenuse = [NSNumber numberWithInt:[[dict objectForKey:@"kitchenuse"] intValue]];
    host.laundry = [NSNumber numberWithInt:[[dict objectForKey:@"laundry"] intValue]];
    host.lawnspace = [NSNumber numberWithInt:[[dict objectForKey:@"lawnspace"] intValue]];
    host.maxcyclists = [NSNumber numberWithInt:[[dict objectForKey:@"maxcyclists"] intValue]];
    host.motel = [dict objectForKey:@"motel"];
    host.name = [dict objectForKey:@"name"];
    host.notcurrentlyavailable = [NSNumber numberWithInteger:[[dict objectForKey:@"notcurrentlyavailable"] intValue]];
    // TEST
    // host.notcurrentlyavailable = @YES;
    host.postal_code = [dict objectForKey:@"postal_code"];
    host.province = [dict objectForKey:@"province"];
    host.sag = [NSNumber numberWithInt:[[dict objectForKey:@"sag"] intValue]];
    host.shower = [NSNumber numberWithInt:[[dict objectForKey:@"shower"] intValue]];
    host.storage = [NSNumber numberWithInt:[[dict objectForKey:@"storage"] intValue]];
    host.street = [dict objectForKey:@"street"];
    host.preferred_notice = [dict objectForKey:@"preferred_notice"];
    
    NSString *latitude = [dict objectForKey:@"latitude"];
    NSString *longitude = [dict objectForKey:@"longitude"];
    
    host.latitude = [NSNumber numberWithDouble:[latitude doubleValue]];
    host.longitude = [NSNumber numberWithDouble:[longitude doubleValue]];
    
    NSTimeInterval last_login_int = [[dict objectForKey:@"login"] doubleValue];
    host.last_login = [NSDate dateWithTimeIntervalSince1970:last_login_int];
    
    NSTimeInterval member_since = [[dict objectForKey:@"created"] doubleValue];
    host.member_since = [NSDate dateWithTimeIntervalSince1970:member_since];
    
    // host.last_updated_details = [NSDate date];
    
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

+(NSString *)trimmedPhoneNumber:(NSString *)phoneNumber {
    
    NSArray *comps = [phoneNumber componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSMutableArray *words = [NSMutableArray array];
    for (NSString *comp in comps) {
        if([comp length] > 0) {
            [words addObject:comp];
        }
    }
    
    return [words componentsJoinedByString:@""];
}


-(NSString *)title {
    return self.fullname ? self.fullname : self.name;
}

-(void)updateDistanceFromLocation:(CLLocation *)location {
    CLLocationCoordinate2D coord = [self coordinate];
    CLLocation *host_location = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
    
    CLLocationDistance distance = [location distanceFromLocation:host_location];
    
    self.distance = [NSNumber numberWithDouble:distance];
}

-(NSString *)subtitle {
    WSAppDelegate *delegate = [WSAppDelegate sharedInstance];
    
    CLLocation *userLocation = [delegate userLocation];
    
    if (userLocation != nil) {
        CLLocation *host_location = [self location];
        
        NSString *bearing = NSLocalizedStringFromBearing( [userLocation bearingToLocation:host_location] );
        CLLocationDistance distance = [host_location distanceFromLocation:userLocation];

        if LocaleIsMetric {
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
    return [NSString stringWithFormat:@"https://www.warmshowers.org/user/%@/", self.hostid];
}

-(BOOL)needsUpdate {
    return (self.last_updated_details == nil) || (fabs([self.last_updated_details timeIntervalSinceNow]) > kDay );
}

-(BOOL)isStale {
    return (self.last_updated_details == nil) || (fabs([self.last_updated_details timeIntervalSinceNow]) > kWeek );
}

-(NSUInteger)pinColour {
    if ([self.favourite boolValue]) {
        return MKPinAnnotationColorGreen;
    } else {
        return MKPinAnnotationColorRed;
    }
    /*
     if ([self.favourite boolValue]) {
     return MKPinAnnotationColorGreen;
     } else if (self.last_updated_details != nil) {
     // indicates we have cached data
     return MKPinAnnotationColorPurple;
     } else {
     return MKPinAnnotationColorRed;
     }
     */
}

-(NSString *)statusString {
    return self.notcurrentlyavailableValue ? NSLocalizedString(@"Not Available", nil) : NSLocalizedString(@"Available", nil);
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

/*
 -(void)purgeFeedback {
 for (Feedback *feedback in self.feedback) {
 [feedback delete];
 }
 }
 */

@end