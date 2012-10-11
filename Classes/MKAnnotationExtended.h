//
//  MKAnnotationExtended.h
//  WS
//
//  Created by Christopher Meyer on 10/17/10.
//  Copyright 2010 Red House Consulting GmbH. All rights reserved.
//

#import <MapKit/MapKit.h>

@protocol MKAnnotationExtended <MKAnnotation>
	-(NSUInteger)pinColour;
	-(BOOL)animatesDrop;
@end
