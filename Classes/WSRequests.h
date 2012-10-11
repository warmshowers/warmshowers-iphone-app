//
//  TrackMyTourRequest.h
//  TrackMyTour
//
//  Created by Christopher Meyer on 1/7/10.
//  Copyright 2010 Red House Consulting GmbH. All rights reserved.
//

#define kMaxResults 50

#import <MapKit/MapKit.h>
@class Host;

@interface WSRequests : NSObject<NSXMLParserDelegate>

+(void)requestWithMapView:(MKMapView *)mapView;
+(void)hostDetailsWithHost:(Host *)host;
+(void)hostFeedbackWithHost:(Host *)host;

@end