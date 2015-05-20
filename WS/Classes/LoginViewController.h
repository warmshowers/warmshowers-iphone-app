//
//  LoginViewController.h
//  WS
//
//  Created by Christopher Meyer on 15/05/15.
//  Copyright (c) 2015 Red House Consulting GmbH. All rights reserved.
//

#import "BButton.h"
#import "RHKeyboardScrunchView.h"

@interface LoginViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet BButton *loginButton;
@property (strong, nonatomic) IBOutlet RHTextField *usernameTextField;
@property (strong, nonatomic) IBOutlet RHTextField *passwordTextField;
@property (strong, nonatomic) IBOutlet RHKeyboardScrunchView *scrunchView;

-(IBAction)loginButtonTapped:(id)sender;
-(IBAction)createAccountButtonTapped:(id)sender;
-(IBAction)learnAboutButtonTapped:(id)sender;

@end