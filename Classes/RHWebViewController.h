//
//  PPRWebViewController.h
//
//  Created by Matt Drance on 6/30/10.
//  Copyright 2010 Bookhouse. All rights reserved.
//

@protocol RHWebViewControllerDelegate;

@interface RHWebViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate>

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) BOOL shouldShowDoneButton;
@property (nonatomic, retain) UIActionSheet *popoverActionsheet;

-(void)fadeWebViewIn;

@end