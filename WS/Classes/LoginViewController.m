//
//  LoginViewController.m
//  WS
//
//  Created by Christopher Meyer on 15/05/15.
//  Copyright (c) 2015 Red House Consulting GmbH. All rights reserved.
//

#import "LoginViewController.h"
#import "WSRequests.h"
#import "WSAppDelegate.h"

@interface LoginViewController ()
@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.loginButton setType:BButtonTypePrimary];
    [self.scrunchView setBackgroundColor:kWSBaseColour];
    __weak LoginViewController *bself = self;
    
    [self.usernameTextField setText:[[WSAppDelegate sharedInstance] username]];
    
    [self.usernameTextField setShouldReturnBlock:^BOOL(RHTextField *textField) {
        [bself.passwordTextField becomeFirstResponder];
        return YES;
    }];
    
    [self.passwordTextField setShouldReturnBlock:^BOOL(RHTextField *textField) {
        [bself loginButtonTapped:nil];
        return YES;
    }];
    
}

// things get tight when the keyboard shows on the iPhone in landscape mode
-(NSUInteger)supportedInterfaceOrientations {
    if IsIPhone {
        return UIInterfaceOrientationMaskPortrait;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
    
}

-(IBAction)loginButtonTapped:(id)sender {
    
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    __weak LoginViewController *bself = self;
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Logging in...", nil) maskType:SVProgressHUDMaskTypeBlack];
    
    [WSRequests loginWithUsername:username
                         password:password
                          success:^(NSURLSessionDataTask *task, id responseObject) {
                              
                              [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Success!", nil)];
                              
                              [[WSAppDelegate sharedInstance] setUsername:username];
                              [[WSAppDelegate sharedInstance] setPassword:password];
                              [[WSAppDelegate sharedInstance] loginSuccess];
                              
                              [bself dismissViewControllerAnimated:YES completion:^{
                                  
                              }];
                              
                          } failure:^(NSURLSessionDataTask *task, NSError *error) {
                              [SVProgressHUD dismiss];
                              RHAlertView *alert = [RHAlertView alertWithTitle:NSLocalizedString(@"Warm Showers", nil)
                                                                       message:NSLocalizedString(@"Login failed. Please check your username and password and try again. If you don't have an account you can tap the Sign Up button to register.", nil)];
                              
                              [alert addButtonWithTitle:kOK block:^{
                                  //  [self logout];
                              }];
                              
                              [alert show];
                          }];
    
}

-(IBAction)createAccountButtonTapped:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.warmshowers.org/user/register"]];
}

-(IBAction)learnAboutButtonTapped:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.warmshowers.org/faq"]];
}


@end
