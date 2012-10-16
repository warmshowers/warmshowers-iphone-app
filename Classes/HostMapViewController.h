//
//  MapViewController.h
//  WS
//
//  Created by Christopher Meyer on 10/16/10.
//  Copyright 2010 Red House Consulting GmbH. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>
#import "RHActionSheet.h"

@interface HostMapViewController : UIViewController <NSFetchedResultsControllerDelegate, MKMapViewDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign) int lastZoomLevel;

@property (nonatomic, assign) BOOL locationUpdated;
@property (nonatomic, assign) BOOL hasRunOnce;
@property (nonatomic, strong) RHActionSheet *popoverActionsheet;


-(void)zoomToCurrentLocation:(id)sender;
-(void)redrawAnnotations;
-(void)removeNonVisibleAnnotations;

-(void)infoButtonPressed:(id)sender;

@end