//
//  ContactHostViewController.m
//  WS
//
//  Created by Christopher Meyer on 4/3/12.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.
//

#import "ComposeMessageViewController.h"
#import "WSAppDelegate.h"
#import "Host.h"
#import "WSHTTPClient.h"
#import "SVProgressHUD.h"

@interface ComposeMessageViewController ()
// -(void)resizeEverything;
@end

@implementation ComposeMessageViewController



-(void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    [self setTitle:NSLocalizedString(@"Contact Host",nil)];
    
    [self.messageToTextLabel setText:[self.host fullname]];
    [self.textView setText:[NSString stringWithFormat:@"Hello %@,\n\n", [self.host fullname]]];
    
    [self.textView observeKeyboard];
    
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
 
    __weak ComposeMessageViewController *bself = self;
    
    self.navigationItem.rightBarButtonItem = [RHBarButtonItem itemWithTitle:NSLocalizedString(@"Send", nil) block:^{
        
        RHAlertView *alert = [RHAlertView alertWithTitle:NSLocalizedString(@"Confirm", nil) message:NSLocalizedString(@"Send message?", nil)];
        
        [alert addCancelButton];
        [alert addButtonWithTitle:NSLocalizedString(@"Send", nil) block:^{
            [bself sendButtonPressed:nil];
        }];
        
        [alert show];
        
    }];
    
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
  //  [self.subjectTextField becomeFirstResponder];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 0) {
        [self.textView becomeFirstResponder];
    }
    
    return YES;
}







-(void)sendButtonPressed:(id)sender {
    
    NSString *subject = self.subjectTextField.text;
    NSString *message = [NSString stringWithFormat:@"%@\n\nSent from the <a href='http://itunes.com/apps/warmshowers'>Warm Showers App for iPhone/iPad</a>", self.textView.text];
    
    if ([subject length] == 0) {
        // [RHNotificationView notificationMessage:@"Subject is required" withNavigationController:self.navigationController];
        [SVProgressHUD showErrorWithStatus:@"Subject is required"];
        return;
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            subject, @"subject",
                            message, @"message",
                            self.host.hostid, @"uid",
                            nil];
    
    [[WSHTTPClient sharedHTTPClient] POST:@"/services/rest/contact/contact" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSNumber *status = [responseObject objectForKey:@"status"];
        NSString *message = [responseObject objectForKey:@"message"];
        
        if ([status boolValue]) {
            [SVProgressHUD showSuccessWithStatus:@"Message sent!"];
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [SVProgressHUD dismiss];
            [[RHAlertView alertWithOKButtonWithTitle:nil message:message] show];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD dismiss];
        [[RHAlertView alertWithOKButtonWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription]] show];
    }];
    
    
    [SVProgressHUD showWithStatus:@"Sending..." maskType:SVProgressHUDMaskTypeGradient];
    
}

-(void)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dealloc {
    [self.textView stopObservingKeyboard];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end