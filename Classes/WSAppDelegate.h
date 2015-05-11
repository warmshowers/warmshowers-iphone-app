//
//  WSAppDelegate.h
//  WS
//
//  Created by Christopher Meyer on 10/16/10.
//  Copyright 2010 Red House Consulting GmbH. All rights reserved.
//

#define kShouldRedrawMapAnnotation @"ShouldRedrawMapAnnotations"
#define kAuthenticationStatusChangedNotificationName @"AuthenticationHasChanged"
#define kNetworkError @"Check your network connection"

#import <MapKit/MapKit.h>

@class LoginViewController, SegmentsController;

@interface WSAppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) SegmentsController *segmentsController;
@property (nonatomic, strong) NSArray *segmentViewControllers;
@property (nonatomic, strong) CLLocationManager *locationManager;

+(WSAppDelegate *)sharedInstance;

-(void)loginWithoutPrompt;
-(void)loginWithPrompt:(BOOL)prompt;
-(BOOL)isLoggedIn;
-(CLLocation *)userLocation;
-(void)requestLocationAuthorization;

@end