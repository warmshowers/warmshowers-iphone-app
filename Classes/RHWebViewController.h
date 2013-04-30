//
//  PPRWebViewController.h
//
//  Created by Matt Drance on 6/30/10.
//  Copyright 2010 Bookhouse. All rights reserved.
//

@protocol RHWebViewControllerDelegate;

@interface RHWebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) BOOL shouldShowDoneButton;
@property (nonatomic, strong) RHActionSheet *popoverActionsheet;

-(void)fadeWebViewIn;

@end