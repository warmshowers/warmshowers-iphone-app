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
@property (strong, nonatomic) IBOutlet UIViewController *mapPropertiesViewController;
@property (strong, nonatomic) IBOutlet UIButton *pageCurlImageButton;


-(void)zoomToCurrentLocation:(id)sender;
-(void)redrawAnnotations;
-(void)removeNonVisibleAnnotations;
-(void)infoButtonPressed:(id)sender;

-(IBAction)mapTypeSegmentedControl:(UISegmentedControl *)sender;
-(IBAction)showMapProperties:(id)sender;

@end