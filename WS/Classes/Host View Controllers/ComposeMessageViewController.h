//
//  ContactHostViewController.h
//  WS
//
//  Created by Christopher Meyer on 4/3/12.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.
//
@class Host;

@interface ComposeMessageViewController : UIViewController

@property (strong, nonatomic) Host *host;

@property (strong, nonatomic) IBOutlet UILabel *messageToTextLabel;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UITextField *subjectTextField;
// @property (strong, nonatomic) UISwipeGestureRecognizer *swipeGesture;

@property (strong, nonatomic) NSString *token;

@end