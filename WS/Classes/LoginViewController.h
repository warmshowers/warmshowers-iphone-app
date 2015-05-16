//
//  LoginViewController.h
//  WS
//
//  Created by Christopher Meyer on 15/05/15.
//  Copyright (c) 2015 Red House Consulting GmbH. All rights reserved.
//

#import "BButton.h"

@interface LoginViewController : UIViewController
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *usernameField;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *passwordField;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet BButton *loginButton;

@end
