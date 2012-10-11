//
//  RHPromptForReview.m
//  Version: 0.2
//
//  Copyright (C) 2012 by Christopher Meyer
//  http://schwiiz.org/
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

#define kReviewPromptInterval 1814400 // three weeks
#define kMinLaunchesBeforePrompt 20
#define kAppID @"359056872"
#define kPromptTextKey @"rhpromptforreview-prompttext"
#define kNextCheckDateKey @"rhpromptforreview-nextcheck"
#define kLaunchCountKey @"rhpromptforreview-launchcount"

#import "RHPromptForReview.h"

@implementation RHPromptForReview

+(RHPromptForReview *)sharedInstance {
	static dispatch_once_t once;
	static RHPromptForReview *sharedInstance;
	dispatch_once(&once, ^ {
		sharedInstance = [RHPromptForReview new];
	});
	return sharedInstance;
}

-(id)init {
	if (self=[super init]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(promptForReview:) name:UIApplicationDidBecomeActiveNotification object:nil];
	}
	
	return self;
}

-(void)setNextCheckDate:(NSDate *)_date {
	[[NSUserDefaults standardUserDefaults] setObject:_date forKey:kNextCheckDateKey];
}

-(void)setIncrementLaunchCount:(NSInteger)_count {
	[[NSUserDefaults standardUserDefaults] setInteger:_count forKey:kLaunchCountKey];
}

-(NSInteger)incrementLaunchCount {
	NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:kLaunchCountKey] + 1;
	[self setIncrementLaunchCount:count];
	return count;
}

-(NSString *)promptText {
	NSString *text = [[NSUserDefaults standardUserDefaults] objectForKey:kPromptTextKey];
	
	if (text == nil) {
		text = NSLocalizedString(@"If you like this app, would you consider taking a few moments to rate it? We thank you for your support!", nil);
	} else {
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:kPromptTextKey];
	}
	
	return text;
}

-(NSDate *)nextCheckDate {
	NSDate *nextChecked = [[NSUserDefaults standardUserDefaults] objectForKey:kNextCheckDateKey];
	
	if (nextChecked == nil) {
		nextChecked = [NSDate dateWithTimeIntervalSinceNow:kReviewPromptInterval];
		[self setNextCheckDate:nextChecked];
	}
	
	return nextChecked;
}

-(void)setPromptText:(NSString *)_text {
	[[NSUserDefaults standardUserDefaults] setObject:_text forKey:kPromptTextKey];
	[self setNextCheckDate:[NSDate date]];
	[self setIncrementLaunchCount:kMinLaunchesBeforePrompt];
}


-(BOOL)shouldPrompt {
	NSDate *nextDate = [self nextCheckDate];
	NSInteger launchCount = [self incrementLaunchCount];
		
	return ([nextDate timeIntervalSinceNow] < 0) && (launchCount > kMinLaunchesBeforePrompt);
}


-(void)promptForReview:(id)sender {	
	if ([self shouldPrompt]) {		
		[self promptNow:nil];
	}
}

-(void)promptNow:(id)sender {
    
    RHAlertView *alert = [RHAlertView alertWithTitle:NSLocalizedString(@"Rate this App", nil) message:[self promptText]];
    
    [alert addButtonWithTitle:NSLocalizedString(@"Rate this App", nil) block:^{
        [self gotoReviews:nil];
    }];
    
    [alert addButtonWithTitle:NSLocalizedString(@"Ask me later", nil) block:nil];
    [alert addButtonWithTitle:NSLocalizedString(@"No thanks", nil) block:^{
        [self setNextCheckDate:[NSDate distantFuture]];
    }];
    
    [alert show];
    
	[self setNextCheckDate:[NSDate dateWithTimeIntervalSinceNow:kReviewPromptInterval]];
	[self setIncrementLaunchCount:0];
}

-(void)gotoReviews:(id)sender {
    NSString *str = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa";
    str = [NSString stringWithFormat:@"%@/wa/viewContentsUserReviews?", str]; 
    str = [NSString stringWithFormat:@"%@type=Purple+Software&id=%@", str, kAppID];
    	
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

@end