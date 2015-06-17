//
//  MKMapView+Utils.m
//
//  Copyright (C) 2015 by Christopher Meyer
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

#define MINIMUM_ZOOM_ARC 0.014 //approximately 1 miles (1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR 1.15
#define MAX_DEGREES_ARC 360

#import "MKMapView+Utils.h"
#import "MKMapView+ZoomLevel.h"

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


/**
 * Chops up the array into groupings that do not cross the international date line
 */
+(NSArray *)getPolyLines:(NSArray *)array {
    
    NSMutableArray *polyLines = [NSMutableArray new];
    
    id<MKAnnotation>nextAnnotation;
    
    int index = 0;
    int startIndex = 0;
    
    for(id<MKAnnotation>annotation in array) {
        
        nextAnnotation = [array objectAtIndex:index+1 defaultValue:nil];
        
        if (nextAnnotation) {
            
            CLLocationCoordinate2D coord1 = [annotation coordinate];
            CLLocationCoordinate2D coord2 = [nextAnnotation coordinate];
            
            // First check: is the shorter distance between the points over the international dateline?  Yes, if their ABS sums exceed 180.
            // Second check: are the points on opposite sides of the international dateline? Yes, if their products are negative.
            if ( (fabs(coord1.longitude) + fabs(coord2.longitude) >= 180) && (coord1.longitude*coord2.longitude < 0) ){
                [polyLines addObject:[self getPolyLine:[array subarrayWithRange:NSMakeRange(startIndex, 1+index-startIndex)]]];
                startIndex = index + 1;
            }
            
        } else {
            
            [polyLines addObject:[self getPolyLine:[array subarrayWithRange:NSMakeRange(startIndex, 1+index-startIndex)]]];
            
        }
        
        index++;
    }
    
    return polyLines;
    
}

// This function accepts an MKAnnotation and opens it in the native iOS Maps App
+(void)openInMapsWithAnnotation:(id<MKAnnotation>)annotation {
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:annotation.coordinate addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:[annotation title]];
    [MKMapItem openMapsWithItems:[NSArray arrayWithObject:mapItem] launchOptions:nil];
}

/* This is not tested */
+(BOOL)canOpenInGoogleMaps {
    return ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]);
}

+(void)openInGoogleMapsWithAnnotation:(id<MKAnnotation>)annotation {
    if ([self canOpenInGoogleMaps]) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?center=%f,%f", annotation.coordinate.latitude, annotation.coordinate.longitude]];
        [[UIApplication sharedApplication] openURL:url];
    }
}
/* not tested yet */


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


-(void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate zoomLevel:(NSUInteger)zoomLevel offset:(CGPoint)offset animated:(BOOL)animated {
    
    MKCoordinateRegion region = [self coordinateRegionWithMapView:self centerCoordinate:coordinate andZoomLevel:zoomLevel];
    MKCoordinateSpan span = region.span;
    
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(
                                                                 coordinate.latitude  - (span.latitudeDelta  * offset.y * 0.5),
                                                                 coordinate.longitude - (span.longitudeDelta * offset.x * 0.5)
                                                                 );
    
    [self setCenterCoordinate:location zoomLevel:zoomLevel animated:animated];
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

-(CLLocationCoordinate2D)randomLocation {
    CLLocationCoordinate2D coord;
    coord.latitude = [self RandomFloatStart:-80.0 end:80.0];
    coord.longitude = [self RandomFloatStart:-160 end:160.0];
    return coord;
}

-(void)zoomToFitMapAnnotationsAnimated:(BOOL)animated {
    [self zoomToFitWithAnnotations:self.annotations animated:animated];
}

// http://brianreiter.org/2012/03/02/size-an-mkmapview-to-fit-its-annotations-in-ios-without-futzing-with-coordinate-systems/
-(void)zoomToFitWithAnnotations:(NSArray *)annotations animated:(BOOL)animated {
    
    NSUInteger count = [annotations count];
    if ( count == 0) {
        return;
    } //bail if no annotations
    
    //convert NSArray of id <MKAnnotation> into an MKCoordinateRegion that can be used to set the map size
    //can't use NSArray with MKMapPoint because MKMapPoint is not an id
    MKMapPoint points[count]; //C array of MKMapPoint struct
    for( int i=0; i<count; i++ ) { //load points C array by converting coordinates to points
        CLLocationCoordinate2D coordinate = [(id <MKAnnotation>)[annotations objectAtIndex:i] coordinate];
        points[i] = MKMapPointForCoordinate(coordinate);
    }
    //create MKMapRect from array of MKMapPoint
    MKMapRect mapRect = [[MKPolygon polygonWithPoints:points count:count] boundingMapRect];
    //convert MKCoordinateRegion from MKMapRect
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    
    //add padding so pins aren't scrunched on the edges
    region.span.latitudeDelta  *= ANNOTATION_REGION_PAD_FACTOR;
    region.span.longitudeDelta *= ANNOTATION_REGION_PAD_FACTOR;
    
    //but padding can't be bigger than the world
    if( region.span.latitudeDelta > MAX_DEGREES_ARC ) {
        region.span.latitudeDelta  = MAX_DEGREES_ARC;
    }
    
    if( region.span.longitudeDelta > MAX_DEGREES_ARC ) {
        region.span.longitudeDelta = MAX_DEGREES_ARC;
    }
    
    //and don't zoom in stupid-close on small samples
    if( region.span.latitudeDelta  < MINIMUM_ZOOM_ARC ) {
        region.span.latitudeDelta  = MINIMUM_ZOOM_ARC;
    }
    if( region.span.longitudeDelta < MINIMUM_ZOOM_ARC ) {
        region.span.longitudeDelta = MINIMUM_ZOOM_ARC;
    }
    
    //and if there is a sample of 1 we want the max zoom-in instead of max zoom-out
    if( count == 1 ) {
        region.span.latitudeDelta = MINIMUM_ZOOM_ARC;
        region.span.longitudeDelta = MINIMUM_ZOOM_ARC;
    }
    
    [self setRegion:region animated:animated];
}

@end