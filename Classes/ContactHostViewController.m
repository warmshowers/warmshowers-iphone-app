//
//  ContactHostViewController.m
//  WS
//
//  Created by Christopher Meyer on 4/3/12.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.
//

#import "ContactHostViewController.h"
#import "WSAppDelegate.h"
#import "Host.h"
#import "WSHTTPClient.h"
#import "SVProgressHUD.h"

@interface ContactHostViewController ()
// -(void)resizeEverything;
@end

@implementation ContactHostViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

		if (IsIPhone) {
			// Swiping down keyboard only works with iPhone
			// [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
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
	// [self.subjectTextField becomeFirstResponder];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField.tag == 0) {
		[self.textView becomeFirstResponder];
	}

	return YES;
}


-(void)textViewDidChange:(UITextView *)textView {
    [self.view setNeedsLayout];

	// http://stackoverflow.com/questions/18122289/determine-scroll-offset-for-uitextview-in-uiscrollview
	NSString *substringToSelection = [textView.text substringToIndex:textView.selectedRange.location];
	UIFont* textFont = textView.font;

	CGRect boundingRect = [substringToSelection boundingRectWithSize:CGSizeMake(textView.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:textFont} context:nil];
	CGRect translatedRect = [textView convertRect:boundingRect toView:self.scrollView];

	translatedRect.origin.y += textFont.capHeight;

	if (!CGRectContainsPoint(self.scrollView.bounds, CGPointMake(CGRectGetMaxX(translatedRect), CGRectGetMaxY(translatedRect)))) {
		[self.scrollView scrollRectToVisible:translatedRect animated:YES];
	}

}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

	CGSize contentSize = self.textView.contentSize;

	UIFont *textFont = self.textView.font;

	[self.textView setHeight:contentSize.height + textFont.capHeight];

	// [self.textView setBackgroundColor:[UIColor greenColor]];

	[self.scrollView autoContentSize];

}

-(void)keyboardWillShow:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];

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

-(void)keyboardWillHide:(NSNotification *)notification {

    // UIView *keyboardView = [[UIApplication sharedApplication] keyboardView];
    // [keyboardView removeGestureRecognizer:self.swipeGesture];
    /*********/

	NSDictionary  *userInfo = [notification userInfo];

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

	/*
	 UIView *keyboardView = [[UIApplication sharedApplication] keyboardView];
	 [keyboardView removeGestureRecognizer:self.swipeGesture];
	 */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	
}

@end