//
//  PPRWebViewController.m
//
//  Created by Matt Drance on 6/30/10.
//  Copyright 2010 Bookhouse. All rights reserved.
//

#import "RHWebViewController.h"

const float PPRWebViewControllerFadeDuration = 0.5;

@implementation RHWebViewController
@synthesize url;
@synthesize webView;
@synthesize activityIndicator;
@synthesize shouldShowDoneButton;
@synthesize popoverActionsheet;

- (void)viewDidLoad {
	// [self resetBackgroundColor];
	[self.view setBackgroundColor:[UIColor lightGrayColor]];
	[self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
	self.webView.alpha = 0.0;
    
    [self.activityIndicator startAnimating];
	
	UIBarButtonItem *actions = [[UIBarButtonItem alloc]
							 initWithBarButtonSystemItem:UIBarButtonSystemItemAction
							 target:self
							 action:@selector(actionButtonTapped:)];
	self.navigationItem.rightBarButtonItem = actions;
}

-(void)viewDidUnload {
    [super viewDidUnload];
	
    self.webView = nil;
    self.activityIndicator = nil;
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.popoverActionsheet dismissWithClickedButtonIndex:[self.popoverActionsheet cancelButtonIndex] animated:YES];
}

-(void)loadView {
    UIViewAutoresizing resizeAllMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectZero];
    mainView.autoresizingMask = resizeAllMask;
    self.view = mainView;
    
    webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.autoresizingMask = resizeAllMask;
    webView.scalesPageToFit = YES;
    webView.delegate = self;
	[self.view addSubview:webView];

    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];

    self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |
                                            UIViewAutoresizingFlexibleRightMargin |
                                            UIViewAutoresizingFlexibleBottomMargin |
                                            UIViewAutoresizingFlexibleLeftMargin;

	self.activityIndicator.center = CGPointMake(CGRectGetMidX(self.view.bounds), 
                                                CGRectGetMidY(self.view.bounds));

    [self.view addSubview:activityIndicator];
}

-(void)actionButtonTapped:(id)sender {
	
	self.popoverActionsheet = [RHActionSheet actionSheetWithTitle:nil];
	
	NSURL *burl = self.webView.request.URL;
	
	[self.popoverActionsheet addButtonWithTitle:@"Open in Safari" block:^{
		[[UIApplication sharedApplication] openURL:burl];
	}];
	
	[self.popoverActionsheet addCancelButton];
		
	[self.popoverActionsheet showFromBarButtonItem:sender animated:YES];
}


#pragma mark -
#pragma mark Actions
- (void)doneButtonTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)fadeWebViewIn {
    [UIView beginAnimations:@"Animage" context:nil];
    [UIView setAnimationDuration:PPRWebViewControllerFadeDuration];
    self.webView.alpha = 1.0;
    [UIView commitAnimations];    
}

#pragma mark -
#pragma mark Accessor overrides

// START:ShowDoneButton
- (void)setShouldShowDoneButton:(BOOL)shows {
    if (shouldShowDoneButton != shows) {
        [self willChangeValueForKey:@"showsDoneButton"];
        shouldShowDoneButton = shows;
        [self didChangeValueForKey:@"showsDoneButton"];
        if (shouldShowDoneButton) {
            UIBarButtonItem *done = [[UIBarButtonItem alloc]
                        initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                             target:self
                                             action:@selector(doneButtonTapped:)];
            self.navigationItem.leftBarButtonItem = done;
        } else {
            self.navigationItem.leftBarButtonItem = nil;
        }
    }
}


#pragma mark -
#pragma mark UIWebViewDelegate
// START:WebLoaded
- (void)webViewDidFinishLoad:(UIWebView *)wv {
    [self.activityIndicator stopAnimating];
    [self fadeWebViewIn];
	
    NSString *docTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title;"];
    if ([docTitle length] > 0) {
        self.navigationItem.title = docTitle;
    }
}

// END:WebLoaded
- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error {
    [self.activityIndicator stopAnimating];
}

#pragma mark Device Orientation
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

@end