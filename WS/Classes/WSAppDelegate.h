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

#define kWSBaseColour [UIColor colorFromHexString:@"0288D1"]
#define kShouldRedrawMapAnnotation @"ShouldRedrawMapAnnotations"
#define kNetworkError @"Check your network connection"

#import <MapKit/MapKit.h>

@class LoginViewController, SegmentsController;

@interface WSAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) SegmentsController *segmentsController;
@property (nonatomic, strong) NSArray *segmentViewControllers;
@property (nonatomic, strong) CLLocationManager *locationManager;

+(WSAppDelegate *)sharedInstance;

-(NSString *)username;
-(void)setUsername:(NSString *)username;
-(NSString *)password;
-(void)setPassword:(NSString *)password;
-(BOOL)isLoggedIn;
-(void)setIsLoggedIn:(BOOL)isLoggedIn;

-(void)loginSuccess;
-(void)logout;

-(void)logout;
-(CLLocation *)userLocation;
-(void)requestLocationAuthorization;
-(void)autologin;

@end