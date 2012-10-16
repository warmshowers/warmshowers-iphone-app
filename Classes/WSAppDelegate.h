//
//  WSAppDelegate.h
//  WS
//
//  Created by Christopher Meyer on 10/16/10.
//  Copyright 2010 Red House Consulting GmbH. All rights reserved.
//

#define kVersion 304	// 301 - Added member_since field
						// 302

#define kShouldRedrawMapAnnotation @"ShouldRedrawMapAnnotations"
#define kAuthenticationStatusChangedNotificationName @"AuthenticationHasChanged"
#define kNetworkError @"Check your network connection"

#define IsIPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IsIPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#import <MapKit/MapKit.h>
#import "AFHTTPClient.h"

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

@end