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

#import "HostMapViewController.h"
#import "Host.h"
#import "MKMapView+Utils.h"
#import "MKMapView+ZoomLevel.h"
#import "WSAppDelegate.h"
#import "HostInfoViewController.h"
#import "RHAboutViewController.h"
#import "HostsTableViewController.h"
#import "WSHTTPClient.h"

#import "KPAnnotation.h"

@interface HostMapViewController()
@property (nonatomic, strong) KPClusteringController *clusteringController;

@end

@implementation HostMapViewController
#pragma mark -
#pragma mark View lifecycle


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = NSLocalizedString(@"Map", nil);
        self.locationUpdated = NO;
        self.hasRunOnce = NO;
    }
    
    return self;
}


-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.lastZoomLevel = [self.mapView zoomLevel];
    
  //  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redrawAnnotations) name:kShouldRedrawMapAnnotation object:nil];

    self.clusteringController = [[KPClusteringController alloc] initWithMapView:self.mapView];
    [self.clusteringController setDelegate:self];
    
    [self redrawAnnotations];
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // This might be overly complicated.  The IB MapView has the delegate set to nil
    // and the showLocation set to false.  We want everything to be initialized before we
    // start receiving location events.  This following approach ensures we receive just one
    // location update and region change on the map.  Should initiate a single update request,
    // which will also force an authentication check.  Yeah, complicated, but I think it works.
    if (self.hasRunOnce == NO) {
        [self.mapView setDelegate:self];
        [self.mapView setShowsUserLocation:YES];
        
        self.hasRunOnce = YES;
    }
}

-(void)logoutActionSheet:(id)sender {
    
    UIAlertController *actionSheet = [UIAlertController actionSheetWithTitle:nil
                                                                     message:nil
                                                               barButtonItem:sender];
    
    [actionSheet addDestructiveButtonWithTitle:NSLocalizedString(@"Logout", nil) block:^(UIAlertAction * _Nonnull action) {
         [[WSAppDelegate sharedInstance] performSelector:@selector(logout)];
    }];
    
    [actionSheet addCancelButton];
    
    [actionSheet presentInViewController:self];
}

#pragma mark -
#pragma mark Fetched results controller

-(NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController == nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        [fetchRequest setEntity:[Host entityDescription]];
        [fetchRequest setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"hostid" ascending:YES]]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"notcurrentlyavailable != 1"]];
     
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                            managedObjectContext:[Host managedObjectContextForCurrentThread]
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
        [_fetchedResultsController setDelegate:self];
        
        
        NSError *error = nil;
        if (![_fetchedResultsController performFetch:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            // abort();
        }
    }
    
    return _fetchedResultsController;
}

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    [[WSHTTPClient sharedHTTPClient] cancelAllOperations];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    CLLocation *location = userLocation.location;
    
    if (location && (self.locationUpdated == NO)) {
        [self.mapView setCenterCoordinate:userLocation.location.coordinate zoomLevel:8 animated:YES];
        self.locationUpdated = YES;
    }
}


// Called when map is moved or zoomed in or out
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    NSArray *visibleAnnotations = [self.mapView visibleAnnotations];
    BOOL animatePin = ([visibleAnnotations count] < 35);
    
    [self.clusteringController refresh:animatePin];
    [[WSHTTPClient sharedHTTPClient] requestWithMapView:self.mapView];
}

/*
-(BOOL)clusteringControllerShouldClusterAnnotations:(KPClusteringController *)clusteringController {
    return self.mapView.zoomLevel < 14; // Find zoom level that suits your dataset
}
*/

#pragma mark -
#pragma mark Fetched results controller delegate

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self redrawAnnotations];
    
    // this doesn't seem to work if the objects are inserted off the main thread (??)
    //if ([[[controller managedObjectContext] insertedObjects] count] > 0) {
      //   [self redrawAnnotations];
   // }
}

-(void)zoomToCurrentLocation:(id)sender {
    MKUserLocation *userLocation = [self.mapView userLocation];
    [self.mapView setCenterCoordinate:userLocation.coordinate animated:YES];
}

-(void)redrawAnnotations {
    self.fetchedResultsController = nil;
    [self.clusteringController setAnnotations:[self.fetchedResultsController fetchedObjects]];
}

-(void)clusteringController:(KPClusteringController *)clusteringController configureAnnotationForDisplay:(KPAnnotation *)annotation {
    if ([annotation isCluster]) {
        annotation.title = [NSString stringWithFormat:@"%lu hosts", (unsigned long)annotation.annotations.count];
        
        NSString *radius = LocaleIsMetric
            ? [NSString stringWithFormat:@"%.1f km", annotation.radius/1000]
            :[NSString stringWithFormat:@"%.1f miles", annotation.radius/1609.344];
        
        annotation.subtitle = [NSString stringWithFormat:@"within %@", radius];
    } else {
        Host *host = [[annotation annotations] anyObject];
        [annotation setTitle:[host title]];
        [annotation setSubtitle:[host subtitle]];
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView *annotationView = nil;
    
    if ([annotation isKindOfClass:[KPAnnotation class]]) {
        KPAnnotation *kingpinAnnotation = (KPAnnotation *)annotation;
        
        if ([kingpinAnnotation isCluster]) {
            
            annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"cluster"];
            
            if (annotationView == nil) {
                annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:kingpinAnnotation reuseIdentifier:@"cluster"];
            }
            
            annotationView.pinColor = MKPinAnnotationColorPurple;
            
        } else {
            
            Host *host = (Host *)[[kingpinAnnotation annotations] anyObject];
            
            annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
            
            if (annotationView == nil) {
                annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:kingpinAnnotation reuseIdentifier:@"pin"];
            }
            
            annotationView.pinColor = [host pinColour];
            // annotationView.canShowCallout = YES;
        }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [button addTarget:self action:@selector(accessoryTapped:) forControlEvents:UIControlEventTouchUpInside];
        annotationView.rightCalloutAccessoryView = button;
        annotationView.canShowCallout = YES;
    }
    
    return annotationView;
}

-(void)accessoryTapped:(id)sender {
    NSArray *annotations = [self.mapView selectedAnnotations];
        KPAnnotation *kingpinAnnotation = [annotations firstObject];
    NSSet *kpAnnotations = [kingpinAnnotation annotations];
    
     if ([kpAnnotations count] == 1) {
        Host *host = [[kingpinAnnotation annotations] anyObject];
        HostInfoViewController *controller = [HostInfoViewController new];
        controller.host = host;
         
         
      //   [self.navigationController pushViewController:controller animated:YES];
         
         __weak UIViewController *bself = self;
         controller.navigationItem.leftBarButtonItem = [RHBarButtonItem itemWithBarButtonSystemItem:UIBarButtonSystemItemStop block:^{
             [bself dismissViewControllerAnimated:YES completion:nil];
         }];
         
         UINavigationController *navController = controller.wrapInNavigationController;
         navController.modalPresentationStyle = UIModalPresentationFormSheet;
         [self.navigationController presentViewController:navController animated:YES completion:nil];

    } else {
        HostsTableViewController *controller = [HostsTableViewController new];
        [controller setTitle:[NSString stringWithFormat:@"within %.0f meters", kingpinAnnotation.radius]];
        [controller setBasePredicate:[NSPredicate predicateWithFormat:@"self in %@", kpAnnotations]];
        // [self.navigationController pushViewController:controller animated:YES];

        __weak UIViewController *bself = self;
        controller.navigationItem.leftBarButtonItem = [RHBarButtonItem itemWithBarButtonSystemItem:UIBarButtonSystemItemStop block:^{
            [bself dismissViewControllerAnimated:YES completion:nil];
        }];
        
        UINavigationController *navController = controller.wrapInNavigationController;
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self.navigationController presentViewController:navController animated:YES completion:nil];
     }
}

-(IBAction)mapTypeSegmentedControl:(UISegmentedControl *)sender {
    switch ([sender selectedSegmentIndex]) {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        default:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
    }
}

@end