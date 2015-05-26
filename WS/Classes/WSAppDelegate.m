//
//  WSAppDelegate.m
//  WS
//
//  Created by Christopher Meyer on 10/16/10.
//  Copyright 2010 Red House Consulting GmbH. All rights reserved.
//

#import "WSAppDelegate.h"
#import "HostMapViewController.h"
#import "RHManagedObjectContextManager.h"
#import "SegmentsController.h"
#import "HostMapViewController.h"
#import "HostTableViewController.h"
#import "FavouriteHostTableViewController.h"
#import "SVProgressHUD.h"
#import "Host.h"
#import "WSHTTPClient.h"
#import "Crittercism.h"
#import "ECSlidingViewController.h"
#import "LeftMenuViewController.h"
#import "Lockbox.h"
#import "WSRequests.h"
#import "LoginViewController.h"

@interface WSAppDelegate ()
@property (nonatomic, strong) ECSlidingViewController *slidingViewController;
-(NSArray *)segmentViewControllers;
-(void)promptForUsernameAndPassword;
@end

@implementation WSAppDelegate

#pragma mark -
#pragma mark Application lifecycle

+(WSAppDelegate *)sharedInstance {
    return (WSAppDelegate *)[[UIApplication sharedApplication] delegate];
}
/*
 NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"ws-name"];
 NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"ws-password"];
 */


#pragma mark -
#pragma mark Setters/Getters

-(NSString *)username {
    return [Lockbox stringForKey:@"ws-username"] ? [Lockbox stringForKey:@"ws-username"] : @"";
}

-(void)setUsername:(NSString *)username {
    [Lockbox setString:username forKey:@"ws-username"];
}

-(NSString *)password {
    return [Lockbox stringForKey:@"ws-password"] ? [Lockbox stringForKey:@"ws-password"] : @"";
}

-(void)setPassword:(NSString *)password {
    [Lockbox setString:password forKey:@"ws-password"];
}

-(BOOL)isLoggedIn {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"ws-loggedin"];
}

-(void)setIsLoggedIn:(BOOL)isLoggedIn {
    [[NSUserDefaults standardUserDefaults] setBool:isLoggedIn forKey:@"ws-loggedin"];
}

#pragma mark -
// See http://schwiiz.org/?p=1734
-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
#ifdef DEBUG
#else
    NSString *cPath = [[NSBundle mainBundle] pathForResource:@"crittercism" ofType:@"plist"];
    NSDictionary *cSettings = [[NSDictionary alloc] initWithContentsOfFile:cPath];
    NSString *appid = [cSettings objectForKey:@"appid"];
    if (appid) {
        [Crittercism enableWithAppID:appid];
    }
#endif
    
    // Setup the window, but don't add the rootViewController yet
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
    // -doesRequireMigration is a method in my RHManagedObject Core Data framework. Function should be self explanatory.
    if ([Host doesRequireMigration]) {
        // SVProgressHUD displays an animated spinner
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Upgrading...", nil) maskType:SVProgressHUDMaskTypeGradient];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            // Just accessing the Core Data stack forces the schema upgrade
            [Host managedObjectContextForCurrentThread];
            
            // Show long enough to see what's going on.
            [NSThread sleepForTimeInterval:1.0];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Success!",nil)];
                [self postApplication:application didFinishLaunchingWithOptions:launchOptions];
            });
        });
        
    } else {
        [self postApplication:application didFinishLaunchingWithOptions:launchOptions];
    }
    
    return YES;
}

-(BOOL)postApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    LeftMenuViewController *leftMenuViewController = [[LeftMenuViewController alloc] init];
    
    self.slidingViewController = [ECSlidingViewController slidingWithTopViewController:[leftMenuViewController.hostMapViewController wrapInNavigationController]];
    self.slidingViewController.underLeftViewController = leftMenuViewController; // [leftMenuViewController wrapInNavigationController];
    self.slidingViewController.anchorRightRevealAmount = 280.0f;
    
    
    [SVProgressHUD setBackgroundColor:[UIColor darkGrayColor]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    
    [self.window setTintColor:kWSBaseColour];
    self.window.rootViewController = self.slidingViewController;
    
    
    [self.window makeKeyAndVisible];
    
    // [[NSDate formatter] setTimeStyle:NSDateFormatterNoStyle];
    
    // is this the right place for this?
    [self.navigationController setToolbarHidden:NO];
    
    
    
    
    [self autologin];
    
    return YES;
}



-(CLLocationManager *)locationManager {
    
    if (_locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        
        if ([CLLocationManager locationServicesEnabled]) {
            [_locationManager startUpdatingLocation];
        }
    }
    
    return _locationManager;
    
}

-(NSArray *)segmentViewControllers {
    if (_segmentViewControllers == nil) {
        UIViewController *map   = [[HostMapViewController alloc] initWithNibName:@"HostMapViewController" bundle:nil];
        UIViewController *list  = [[HostTableViewController alloc] initWithStyle:UITableViewStylePlain];
        UIViewController *list2 = [[FavouriteHostTableViewController alloc] initWithStyle:UITableViewStylePlain];
        self.segmentViewControllers = [NSArray arrayWithObjects:map, list, list2, nil];
    }
    
    return _segmentViewControllers;
}

-(void)requestLocationAuthorization {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

-(CLLocation *)userLocation {
    return [self.locationManager location];
}

// does this belong here?
-(void)autologin {
    NSLog(@"%@", @"Auto Login Called");
    if (self.isLoggedIn) {
        [WSRequests loginWithUsername:[self username]
                             password:[self password]
                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                  [self loginSuccess];
                              }
                              failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  [[WSAppDelegate sharedInstance] logout];
                              }];
    } else {
        [self logout];
    }
}


#pragma mark Authentication
-(void)presentLoginPrompt {
    [self promptForUsernameAndPassword];
}

-(void)loginSuccess {
    [self setIsLoggedIn:YES];
    [self requestLocationAuthorization];
}

-(void)logout {
    [self setIsLoggedIn:NO];
    [self presentLoginPrompt];
}

-(void)promptForUsernameAndPassword {
    LoginViewController *loginController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [loginController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self.slidingViewController presentViewController:loginController animated:YES completion:nil];
}

@end