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
#import "RHPromptForReview.h"
#import "SVProgressHUD.h"
#import "Host.h"

#import "UIColor+utils.h"
#import "WSHTTPClient.h"

@interface WSAppDelegate ()
-(NSArray *)segmentViewControllers;
-(void)loginWithUsername:(NSString *)_username password:(NSString *)_password;
-(void)loginSuccess;
-(void)logout;
@end

@implementation WSAppDelegate
@synthesize window;
@synthesize navigationController;
@synthesize segmentsController;
@synthesize locationManager;
@synthesize segmentViewControllers;

#pragma mark -
#pragma mark Application lifecycle

+(WSAppDelegate *)sharedInstance {
	return (WSAppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	self.navigationController = [[UINavigationController alloc] initWithRootViewController:[self.segmentViewControllers objectAtIndex:0]];
	self.window.rootViewController = self.navigationController;
	[self.window makeKeyAndVisible];
	    
	[[NSUserDefaults standardUserDefaults] setInteger:kVersion forKey:@"ws-version"];
    
	[self.navigationController setToolbarHidden:NO];
	[self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:46/255.0 green:116/255.0 blue:165/255.0 alpha:1]];
	
	self.segmentsController = [[SegmentsController alloc] initWithNavigationController:self.navigationController viewControllers:[self segmentViewControllers]];
	
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	if ([CLLocationManager locationServicesEnabled]) {
		[self.locationManager startUpdatingLocation];
	}
    
    if ([self isLoggedIn]) {
        [RHPromptForReview sharedInstance];
    } else {
        [self loginWithPrompt:YES];
    }
    
    return YES;
}

-(NSArray *)segmentViewControllers {
	if (segmentViewControllers == nil) {
		UIViewController *map = [[HostMapViewController alloc] initWithNibName:@"HostMapViewController" bundle:nil];
		UIViewController *list = [[HostTableViewController alloc] initWithStyle:UITableViewStylePlain];
		UIViewController *list2 = [[FavouriteHostTableViewController alloc] initWithStyle:UITableViewStylePlain];
		self.segmentViewControllers = [NSArray arrayWithObjects:map, list, list2, nil];
	}
	
	return segmentViewControllers;
}

-(CLLocation *)userLocation {
	return [self.locationManager location];
}

-(void)loginWithoutPrompt {
    // NSLog(@"%@", @"loginWithoutPrompt");
	return [self loginWithPrompt:NO];
}

#pragma mark Authentication
-(void)loginWithPrompt:(BOOL)prompt {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (prompt) {
            [self promptForUsernameAndPassword];
        } else {
            NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"ws-name"];
            NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"ws-password"];
            [self loginWithUsername:username password:password];
        }
        
    });
}

-(void)loginSuccess {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ws-loggedin"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAuthenticationStatusChangedNotificationName object:nil userInfo:nil];
}

-(void)logout {
    NSURL *baseURL = [[WSHTTPClient sharedHTTPClient] baseURL];
	NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:baseURL];
	
	for (NSHTTPCookie *cookie in cookies) {
		[[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
	}
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ws-password"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ws-loggedin"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAuthenticationStatusChangedNotificationName object:nil userInfo:nil];
    
    [self loginWithPrompt:YES];
}

-(void)promptForUsernameAndPassword {
    RHAlertView *alert = [RHAlertView alertWithTitle:@"Warmshowers Login" message:@"Enter your username and password:"];
    [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:@"ws-name"];
    [[alert textFieldAtIndex:0] setText:name];
    
    __weak RHAlertView *bAlert = alert;
    [alert addButtonWithTitle:@"Login" block:^{
        NSString *name = [[bAlert textFieldAtIndex:0] text];
        NSString *password = [[bAlert textFieldAtIndex:1] text];
        
        [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"ws-name"];
        [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"ws-password"];
        
        [self loginWithUsername:name password:password];
    }];
    
    [alert addButtonWithTitle:@"Sign Up" block:^{
        RHAlertView *alert2 = [RHAlertView alertWithTitle:@"Warmshowers Sign Up" message:@"You will be redirected to the sign up page on Warmshowers.org."];
        
        [alert2 addButtonWithTitle:@"OK" block:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.warmshowers.org/user/register"]];
            [self loginWithPrompt:YES];
        }];
                
        [alert2 addButtonWithTitle:@"Cancel" block:^{
            [self loginWithPrompt:YES];
        }];
        
        [alert2 show];
    }];
    
    [alert show];
}


-(void)loginWithUsername:(NSString *)_username password:(NSString *)_password {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _username, @"username",
                            _password, @"password", nil];
    
    NSURLRequest *urlrequest = [[WSHTTPClient sharedHTTPClient] requestWithMethod:@"POST" path:@"/services/rest/user/login" parameters:params];
    
    AFJSONRequestOperation *request = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlrequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

        if ([self isLoggedIn] == NO) {
            [SVProgressHUD showSuccessWithStatus:@"Success!"];
        }

        [self loginSuccess];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [SVProgressHUD showSuccessWithStatus:@"Invalid login!"];
        [self promptForUsernameAndPassword];
    }];
    
    [[WSHTTPClient sharedHTTPClient] enqueueHTTPRequestOperation:request];
    
    if ([self isLoggedIn] == NO) {
        [SVProgressHUD showWithStatus:@"Logging in..." maskType:SVProgressHUDMaskTypeBlack];
    }
}

-(BOOL)isLoggedIn {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"ws-loggedin"];
}

#pragma mark App Delegate

-(void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	// [[RHManagedObjectContextManager sharedInstance] commit];
}


-(void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	
    // [[RHManagedObjectContextManager sharedInstance] commit];
}


-(void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


-(void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
-(void)applicationWillTerminate:(UIApplication *)application {
    // [[RHManagedObjectContextManager sharedInstance] commit];
}


@end