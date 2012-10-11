//
//  MKMapView+Utils.m
//
//  Copyright (C) 2012 by Christopher Meyer
//  http://schwiiz.org/
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

#import "MKMapView+Utils.h"

@implementation MKMapView (Utils)

// Why is this a class function?  Well, it's not guaranteed that self.annotations will be in the correct order.
// If you think it might be then you can always pass mapView.annotations in as a parameter.
+(MKPolyline *)getPolyLine:(NSArray *)array {
	// create a c array of points.
	MKMapPoint* pointArr = malloc(sizeof(CLLocationCoordinate2D) * [array count]);
	
	int index = 0;
	for(id<MKAnnotation>annotation in array) {
		pointArr[index] = MKMapPointForCoordinate(annotation.coordinate);
		index++;
	}
	
	// create the polyline based on the array of points.
	MKPolyline *routeLine = [MKPolyline polylineWithPoints:pointArr count:[array count]];
	
	// clear the memory allocated earlier for the points
	free(pointArr);
	
	return routeLine;
}

+(void)openInMapsWithAnnotation:(id<MKAnnotation>)annotation {
    Class itemClass = [MKMapItem class];
    
    // http://developer.apple.com/library/ios/#documentation/MapKit/Reference/MKMapItem_class/Reference/Reference.html
    if (itemClass && [itemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
        // ios6
        MKPlacemark *placemark = [[[MKPlacemark alloc] initWithCoordinate:annotation.coordinate addressDictionary:nil] autorelease];
        MKMapItem *mapItem = [[[MKMapItem alloc] initWithPlacemark:placemark] autorelease];
        [mapItem setName:[annotation title]];
        [MKMapItem openMapsWithItems:[NSArray arrayWithObject:mapItem] launchOptions:nil];
        
    } else {
        // pre ios6
        NSString *base = @"maps:q=";
        CLLocationCoordinate2D location = annotation.coordinate;
        NSString *title = [[annotation title] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSString *urlString = [NSString stringWithFormat:@"%@%@@%f,%f", base, title, location.latitude, location.longitude];
        NSURL *url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:url];
    }
    
}

-(BOOL)annotionIsVisibile:(id<MKAnnotation>)annotation {
	return [[self visibleAnnotations] containsObject:annotation];
}

// This does not include the user location.
-(NSArray *)visibleAnnotations {
	return [[self annotationsInMapRect:self.visibleMapRect] allObjects];
}

-(NSArray *)nonVisibleAnnotations {
	NSMutableArray *a = [NSMutableArray arrayWithArray:[self annotationsWithoutUserLocation]];
	[a removeObjectsInArray:[self visibleAnnotations]];
	return a;
}

-(NSArray *)annotationsWithoutUserLocation {
	NSMutableArray *a = [NSMutableArray arrayWithArray:self.annotations];
	[a removeObject:self.userLocation];
	return a;
}

-(bounds)fetchBounds {
	MKMapRect mRect = self.visibleMapRect;
	
	MKMapPoint centerMapPoint = MKMapPointMake(mRect.origin.x + (mRect.size.width/2), mRect.origin.y + (mRect.size.height/2));
	MKMapPoint neMapPoint = MKMapPointMake(mRect.origin.x + mRect.size.width, mRect.origin.y);
	MKMapPoint swMapPoint = MKMapPointMake(mRect.origin.x, mRect.origin.y + mRect.size.height);
	
	CLLocationCoordinate2D ceCoord = MKCoordinateForMapPoint(centerMapPoint);
	CLLocationCoordinate2D neCoord = MKCoordinateForMapPoint(neMapPoint);
	CLLocationCoordinate2D swCoord = MKCoordinateForMapPoint(swMapPoint);
	
	bounds b;
	b.maxLatitude = neCoord.latitude;
	b.minLatitude = swCoord.latitude;
	b.maxLongitude = neCoord.longitude;
	b.minLongitude = swCoord.longitude;
	b.centerLatitude = ceCoord.latitude;
	b.centerLongitude = ceCoord.longitude;
	
	return b;
}

-(float)RandomFloatStart:(float)a end:(float)b {
    float random = ((float) rand()) / (float) RAND_MAX;
    float diff = b - a;
    float r = random * diff;
    return a + r;
}

// http://stackoverflow.com/questions/1254275/problem-in-moving-mkpinannotation-on-iphone-map
-(CLLocationCoordinate2D)randomLocation {
    // return CLLocationCoordinate2DMake([self RandomFloatStart:-90.0 end:90.0], [self RandomFloatStart:-180 end:180.0]);
	
    CLLocationCoordinate2D coord;
    coord.latitude = [self RandomFloatStart:-80.0 end:80.0];
    coord.longitude = [self RandomFloatStart:-160 end:160.0];
    return coord;
}


-(void)zoomToFitMapAnnotationsAnimated:(BOOL)_animated {
	[self zoomToFitWithAnnotations:self.annotations animated:_animated];
}

-(void)zoomToFitWithAnnotations:(NSArray *)_annotations animated:(BOOL)_animated {
	CLLocationCoordinate2D southWest;
	CLLocationCoordinate2D northEast;
	
	southWest.latitude = 90.0;
	southWest.longitude = 180;
	northEast.latitude = -90;
	northEast.longitude= -180;
	
	for (id<MKAnnotation>annotation in _annotations) {
		CLLocationCoordinate2D coord = annotation.coordinate;
		southWest.latitude  = MIN(southWest.latitude,  coord.latitude);
		southWest.longitude = MIN(southWest.longitude, coord.longitude);
		northEast.latitude  = MAX(northEast.latitude,  coord.latitude);
		northEast.longitude = MAX(northEast.longitude, coord.longitude);
	}
	
	CLLocation *locSouthWest = [[[CLLocation alloc] initWithLatitude:southWest.latitude longitude:southWest.longitude] autorelease];
	CLLocation *locNorthEast = [[[CLLocation alloc] initWithLatitude:northEast.latitude longitude:northEast.longitude] autorelease];
	CLLocationDistance meters = [locSouthWest distanceFromLocation:locNorthEast];
	
	MKCoordinateRegion region;
	region.center.latitude  = (southWest.latitude + northEast.latitude) / 2.0;
	region.center.longitude = (southWest.longitude + northEast.longitude) / 2.0;
	region.span.latitudeDelta = meters / 111319.5;
	region.span.longitudeDelta = 0.0;
	
	[self setRegion:[self regionThatFits:region] animated:_animated];
}

@end