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

#import "WSAppDelegate.h"
#import "HostMapViewController.h"
#import "RHManagedObjectContextManager.h"
#import "HostMapViewController.h"
#import "SearchHostsTableViewController.h"
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
-(void)promptForUsernameAndPassword;
@end

@implementation WSAppDelegate

#pragma mark -
#pragma mark Application lifecycle

+(WSAppDelegate *)sharedInstance {
    return (WSAppDelegate *)[[UIApplication sharedApplication] delegate];
}

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
    
    [SVProgressHUD setBackgroundColor:kWSBaseColour];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    
    [self.window setTintColor:kWSBaseColour];
    self.window.rootViewController = self.slidingViewController;
    
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

-(void)requestLocationAuthorization {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

-(CLLocation *)userLocation {
    return [self.locationManager location];
}

-(void)autologin {
    NSLog(@"%@", @"Auto Login Called");
    if (self.isLoggedIn) {
        [WSRequests loginWithUsername:[self username]
                             password:[self password]
                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                  [self loginSuccess];
                              }
                              failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
                                  NSInteger statusCode = response.statusCode;
                                  if (statusCode > 200) {
                                      [[WSAppDelegate sharedInstance] logout];
                                  }
                              }];
    } else {
        [self logout];
    }
}

#pragma mark Authentication
-(void)loginSuccess {
    [self setIsLoggedIn:YES];
    [self requestLocationAuthorization];
}

-(void)logout {
    [self setIsLoggedIn:NO];
    [self promptForUsernameAndPassword];
}

-(void)promptForUsernameAndPassword {
    LoginViewController *loginController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [loginController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self.slidingViewController presentViewController:loginController animated:YES completion:nil];
}

@end