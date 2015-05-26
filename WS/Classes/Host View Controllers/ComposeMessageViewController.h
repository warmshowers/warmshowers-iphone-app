//
//  ComposeMessageViewController.h
//  WS
//
//  Created by Christopher Meyer on 4/3/12.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.
//

#import "Host.h"
#import "Thread.h"

@interface ComposeMessageViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate>

@property (strong, nonatomic) Host *host;
@property (strong, nonatomic) Thread *thread;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UILabel *messageToTextLabel;
@property (strong, nonatomic) IBOutlet UITextField *subjectTextField;
@property (strong, nonatomic) IBOutlet UITextView *textView;


+(ComposeMessageViewController *)controllerWithHost:(Host *)host;
+(ComposeMessageViewController *)controllerWithThread:(Thread *)thread;

@end