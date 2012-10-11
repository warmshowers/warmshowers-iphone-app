//
//  ContactHostViewController.h
//  WS
//
//  Created by Christopher Meyer on 4/3/12.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.
//
@class Host;

@interface ContactHostViewController : UIViewController<UITextViewDelegate>

@property (retain, nonatomic) Host *host;

@property (retain, nonatomic) IBOutlet UILabel *messageToTextLabel;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UITextView *textView;
@property (retain, nonatomic) IBOutlet UITextField *subjectTextField;
@property (retain, nonatomic) UISwipeGestureRecognizer *swipeGesture;

@property (retain, nonatomic) NSString *token;

@end
