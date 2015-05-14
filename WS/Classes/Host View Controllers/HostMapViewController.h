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
#import "KPClusteringController.h"

@interface HostMapViewController : UIViewController <NSFetchedResultsControllerDelegate, MKMapViewDelegate, KPClusteringControllerDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign) NSUInteger lastZoomLevel;

@property (nonatomic, assign) BOOL locationUpdated;
@property (nonatomic, assign) BOOL hasRunOnce;
@property (nonatomic, strong) RHActionSheet *popoverActionsheet;



-(IBAction)zoomToCurrentLocation:(id)sender;
-(void)redrawAnnotations;
-(void)infoButtonPressed:(id)sender;

-(IBAction)mapTypeSegmentedControl:(UISegmentedControl *)sender;

@end