// MKMapView+ZoomLevel.h

#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)

-(void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate zoomLevel:(NSUInteger)zoomLevel animated:(BOOL)animated;
-(int)getZoomLevel;

@end 