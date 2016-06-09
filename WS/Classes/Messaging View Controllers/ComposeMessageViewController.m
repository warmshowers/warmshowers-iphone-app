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

+(ComposeMessageViewController *)controllerWithThread:(MessageThread *)thread {
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
                                                                      attribute:NSLayoutAttributeLeading
                                                                     multiplier:1.0
                                                                       constant:0];
    [self.view addConstraint:leftConstraint];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                       attribute:NSLayoutAttributeTrailing
                                                                       relatedBy:0
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeTrailing
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
    
    [SVProgressHUD showWithStatus:@"Sending..."];
    
    if (self.thread) {
        
        [self.thread replyWithMessage:message success:^(NSURLSessionDataTask *task, id responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Message sent!", nil)];
                [bself dismissViewControllerAnimated:YES completion:nil];
            });
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [[RHAlertView alertWithOKButtonWithTitle:NSLocalizedString(@"Error", nil)
                                                 message:NSLocalizedString(@"Your message could not be sent due to an error.", nil)] show];
            });
        }];
        
    } else {
        
        [MessageThread newMessageToHost:self.host
                                subject:subject message:message success:^(NSURLSessionDataTask *task, id responseObject) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Message sent!", nil)];
                                        [bself dismissViewControllerAnimated:YES completion:nil];
                                    });
                                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [SVProgressHUD dismiss];
                                        [[RHAlertView alertWithOKButtonWithTitle:NSLocalizedString(@"Error", nil)
                                                                         message:NSLocalizedString(@"Your message could not be sent due to an error.", nil)] show];
                                    });
                                }];
    }
    
    
}


-(void)dealloc {
    [self.scrollView stopObservingKeyboard];
}

@end