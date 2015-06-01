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

#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import "_Host.h"

@interface Host : _Host<MKAnnotation> {
	CLLocationCoordinate2D coordinate;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

+(Host *)hostWithID:(NSNumber *)hostID;
+(Host *)fetchOrCreate:(NSDictionary *)dict;
+(NSArray *)hostsClosestToLocation:(CLLocation *)location withLimit:(int)limit;
+(NSString *)trimmedPhoneNumber:(NSString *)phoneNumber;

-(NSString *)title;
-(NSString *)subtitle;

-(void)updateDistanceFromLocation:(CLLocation *)location;

-(NSString *)infoURL;
-(NSString *)imageURL;
-(BOOL)isStale;
-(NSString *)statusString;

-(NSUInteger)pinColour;
-(CLLocation *)location;
-(NSString *)address;

@end