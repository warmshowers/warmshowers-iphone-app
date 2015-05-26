//
//  ComposeMessageViewController.m
//  WS
//
//  Created by Christopher Meyer on 4/3/12.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.
//

#import "ComposeMessageViewController.h"
#import "WSAppDelegate.h"
#import "WSHTTPClient.h"
#import "SVProgressHUD.h"

@interface ComposeMessageViewController ()
@end

@implementation ComposeMessageViewController

+(ComposeMessageViewController *)controllerWithHost:(Host *)host {
    ComposeMessageViewController *controller = [[ComposeMessageViewController alloc] initWithNibName:@"ComposeMessageViewController" bundle:nil];
    [controller setHost:host];
    return controller;
}

+(ComposeMessageViewController *)controllerWithThread:(Thread *)thread {
    ComposeMessageViewController *controller = [self controllerWithHost:thread.user];
    [controller setThread:thread];
    return controller;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    [self.scrollView observeKeyboard];
    
    NSString *titleString = NSLocalizedString(@"Send Message", nil);
    [self setTitle:titleString];
    
    [self.messageToTextLabel setText:self.host.title];
    
    if (self.thread) {
        [self.subjectTextField setText:self.thread.subject];
    }
    
    [self.textView setText:[NSString stringWithFormat:@"Hello %@,\n\n", self.host.title]];
    
    __weak ComposeMessageViewController *bself = self;
    
    self.navigationItem.leftBarButtonItem = [[RHBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                           block:^{
                                                                                               [bself dismissViewControllerAnimated:YES completion:nil];
                                                                                           }];
    
    self.navigationItem.rightBarButtonItem = [RHBarButtonItem itemWithTitle:NSLocalizedString(@"Send", nil) block:^{
        
        [self.subjectTextField resignFirstResponder];
        [self.textView resignFirstResponder];
        
        RHAlertView *alert = [RHAlertView alertWithTitle:nil
                                                 message:NSLocalizedString(@"Send message?", nil)];
        
        [alert addCancelButton];
        [alert addButtonWithTitle:NSLocalizedString(@"Send", nil) block:^{
            [bself sendButtonPressed:nil];
        }];
        
        [alert show];
    }];
    
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                      attribute:NSLayoutAttributeLeading
                                                                      relatedBy:0
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0
                                                                       constant:0];
    [self.view addConstraint:leftConstraint];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                       attribute:NSLayoutAttributeTrailing
                                                                       relatedBy:0
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:0];
    [self.view addConstraint:rightConstraint];
    
}

-(void)textViewDidChange:(UITextView *)textView {
    [textView setNeedsLayout];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return (self.thread == nil);
}

-(void)sendButtonPressed:(id)sender {
    
    __weak ComposeMessageViewController *bself = self;
    
    NSString *subject = self.subjectTextField.text;
   // NSString *message = [NSString stringWithFormat:@"%@\n\nSent from the <a href='http://itunes.com/apps/warmshowers'>Warm Showers App for iPhone/iPad</a>", self.textView.text];
    
    NSString *message = self.textView.text;
    
    [SVProgressHUD showWithStatus:@"Sending..." maskType:SVProgressHUDMaskTypeGradient];
    
    if (self.thread) {
        
        [self.thread replyWithMessage:message success:^(NSURLSessionDataTask *task, id responseObject) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Message sent!", nil)];
            [bself dismissViewControllerAnimated:YES completion:nil];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [SVProgressHUD dismiss];
            [[RHAlertView alertWithOKButtonWithTitle:NSLocalizedString(@"Error", nil)
                                             message:NSLocalizedString(@"Your message could not be sent due to an error.", nil)] show];
        }];
        
    } else {
        
        [Thread newMessageToHost:self.host
                         subject:subject message:message success:^(NSURLSessionDataTask *task, id responseObject) {
                             [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Message sent!", nil)];
                             [bself dismissViewControllerAnimated:YES completion:nil];
                         } failure:^(NSURLSessionDataTask *task, NSError *error) {
                             [SVProgressHUD dismiss];
                             [[RHAlertView alertWithOKButtonWithTitle:NSLocalizedString(@"Error", nil)
                                                              message:NSLocalizedString(@"Your message could not be sent due to an error.", nil)] show];
                         }];
    }
    
    
}


-(void)dealloc {
    [self.scrollView stopObservingKeyboard];
}

@end