//
//  ContactHostViewController.m
//  WS
//
//  Created by Christopher Meyer on 4/3/12.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.
//

#import "ContactHostViewController.h"
#import "WSAppDelegate.h"
#import "UIScrollView+autoContentSize.h"
#import "Host.h"
#import "WSHTTPClient.h"
#import "DSActivityView.h"
#import "SVProgressHUD.h"

@interface ContactHostViewController ()
// -(void)resizeEverything;
@end

@implementation ContactHostViewController
@synthesize host;
@synthesize messageToTextLabel;
@synthesize scrollView;
@synthesize textView;
@synthesize subjectTextField;
@synthesize token;  /* needed anymore?? */
@synthesize swipeGesture;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
		
		if (IsIPhone) {
			// Swiping down keyboard only works with iPhone
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
		}
	}
	
	return self;
	
}


-(void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Contact Host"];
    
	[self.messageToTextLabel setText:[NSString stringWithFormat:@"Message to: %@", [self.host fullname]]];
	[self.textView setText:[NSString stringWithFormat:@"Hello %@,\n\n", [self.host fullname]]];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(sendButtonPressed:)];
    self.navigationItem.rightBarButtonItem = sendButton;
    
    
	/*
	 UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(sendButtonPressed:)];
	 self.navigationItem.rightBarButtonItem = sendButton;
	 [sendButton release];
	 */
	
	//	NSURL *contactURL = [NSURL URLWithString:[self.host contactURL]];
	
	/*
     [[WSHTTPClient sharedHTTPClient]
	 getPath:[self.host contactURL]
	 parameters:nil
	 success:^(AFHTTPRequestOperation *operation, id responseObject) {
     
     NSString *responseString = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] autorelease];
     NSError *error = NULL;
     
     NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"id=\"edit-form-token\" value=\"([0-9a-f]+)\"" options:NSRegularExpressionCaseInsensitive error:&error];
     NSTextCheckingResult *checkingResult = [regex firstMatchInString:responseString options:0 range:NSMakeRange(0, [responseString length])];
     
     self.token = [responseString substringWithRange:[checkingResult rangeAtIndex:1]];
     
     UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(sendButtonPressed:)];
     self.navigationItem.rightBarButtonItem = sendButton;
     [sendButton release];
     
	 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     
     
	 }];
     */
}


-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.subjectTextField becomeFirstResponder];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField.tag == 0) {
		[self.textView becomeFirstResponder];
	}
	
	return YES;
}


-(void)textViewDidChange:(UITextView *)textView {
    [self.view setNeedsLayout];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
	CGSize constraint = CGSizeMake(self.textView.frame.size.width, INT_MAX);
	
	CGSize singleHeight = [@"one" sizeWithFont:self.textView.font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	CGSize size = [self.textView.text sizeWithFont:self.textView.font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	
	CGRect frame = self.textView.frame;
	frame.size.height = size.height + ( singleHeight.height*2 );
	
	[self.textView setFrame:frame];
	[self.scrollView autoContentSize];
}

-(void)keyboardWillShow:(NSNotification *)_notification {
	NSDictionary  *userInfo = [_notification userInfo];
	
	NSTimeInterval animationDuration;
	UIViewAnimationCurve animationCurve;
	CGRect keyboardEndFrame;
	[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
	[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
	[[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
	
	CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame fromView:nil];
	CGFloat scrollViewWidth = self.scrollView.frame.size.width;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:animationDuration];
	[UIView setAnimationCurve:animationCurve];
	self.scrollView.frame = CGRectMake(0, 0, scrollViewWidth, keyboardFrame.origin.y);
	[UIView commitAnimations];
	
	[self.scrollView autoContentSize];
}

-(void)keyboardWillHide:(NSNotification *)_notification {
    
    UIView *keyboardView = [[UIApplication sharedApplication] keyboardView];
    [keyboardView removeGestureRecognizer:self.swipeGesture];
    /*********/
    
	NSDictionary  *userInfo = [_notification userInfo];
	
	NSTimeInterval animationDuration;
	UIViewAnimationCurve animationCurve;
	CGRect keyboardEndFrame;
	[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
	[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
	[[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:animationDuration];
	[UIView setAnimationCurve:animationCurve];
	self.scrollView.frame = self.view.frame;
	[UIView commitAnimations];
	
	[self.scrollView autoContentSize];
}

-(void)keyboardDidShow:(NSNotification *)_notification {
	UIView *keyboardView = [[UIApplication sharedApplication] keyboardView];
	self.swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self.textView action:@selector(resignFirstResponder)];
	self.swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
	[keyboardView addGestureRecognizer:self.swipeGesture];
}

-(void)sendButtonPressed:(id)sender {
	
	NSString *subject = self.subjectTextField.text;
	NSString *message = [NSString stringWithFormat:@"%@\n\nSent from the <a href='http://itunes.com/apps/warmshowers'>Warmshowers App for iPhone/iPad</a>", self.textView.text];
	
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
	
    NSURLRequest *nsurlrequest = [[WSHTTPClient sharedHTTPClient] requestWithMethod:@"POST" path:@"/services/rest/contact/contact" parameters:params];
    
    AFJSONRequestOperation *request = [AFJSONRequestOperation
                                       JSONRequestOperationWithRequest:nsurlrequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                           
                                           NSNumber *status = [JSON objectForKey:@"status"];
                                           NSString *message = [JSON objectForKey:@"message"];
                                           
                                           if ([status boolValue]) {
                                               [SVProgressHUD showSuccessWithStatus:@"Message sent!"];
                                               [self dismissViewControllerAnimated:YES completion:nil];
                                           } else {
                                               [SVProgressHUD dismiss];
                                               [[RHAlertView alertWithOKButtonWithTitle:nil message:message] show];
                                           }
                                       } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                           
                                           [SVProgressHUD dismiss];
                                           [[RHAlertView alertWithOKButtonWithTitle:nil message:[error localizedDescription]] show];
                                       }];
    
    
    [[WSHTTPClient sharedHTTPClient] enqueueHTTPRequestOperation:request];
    [SVProgressHUD showWithStatus:@"Sending..." maskType:SVProgressHUDMaskTypeGradient];
    
    
    /*
     [[WSHTTPClient sharedHTTPClient]
     postPath:@"/services/rest/contact/contact"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
     NSString *responseString = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] autorelease];
     
     [SVProgressHUD dismiss];
     
     NSString *success_string = @"The message has been sent.";
     BOOL success_sent = ([responseString rangeOfString:success_string].length > 0);
     
     if (success_sent) {
     [[RHAlertView alertWithOKButtonWithTitle:@"Message Sent" message:@"Your message was sent. You should receive a copy by e-mail if everything worked."] show];
     
     [self dismissModalViewControllerAnimated:YES];
     } else {
     [[RHAlertView alertWithOKButtonWithTitle:@"Send Error" message:@"An error occurred while sending your message."] show];
     }
     
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     
     [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
     }];
     */
    
}

-(void)cancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


-(void)viewDidUnload {
	[self setScrollView:nil];
	[self setTextView:nil];
	[self setMessageToTextLabel:nil];
	[self setSubjectTextField:nil];
	[super viewDidUnload];
}

-(void)dealloc {
    
    UIView *keyboardView = [[UIApplication sharedApplication] keyboardView];
    [keyboardView removeGestureRecognizer:self.swipeGesture];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
}

@end