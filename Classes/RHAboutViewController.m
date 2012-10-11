//
//  RHAboutViewController.m
//  TrackMyTour
//
//  Created by Christopher Meyer on 8/26/12.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.
//

#import "RHAboutViewController.h"
#import "NSString+analytics.h"
#import "RHWebViewController.h"
#import "UIImage+scaleImage.h"
#import "RHPromptForReview.h"
#import "UIColor+utils.h"

@interface RHAboutViewController ()
-(UITableViewCell *)headerCell;
-(UITableViewCell *)subHeaderCell;
@end

@implementation RHAboutViewController

-(id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:NSLocalizedString(@"About", nil)];
	
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self.navigationController action:@selector(dismissModalViewControllerAnimated:)];
	
	self.navigationItem.leftBarButtonItem = doneButton;
	self.navigationController.navigationBar.tintColor = [UIColor colorFromHexString:@"2E74A5"];
	
	[doneButton release];
	
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.navigationController setToolbarHidden:YES animated:YES];
}

#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
		case 0:
			return 1;
		case 1:
			return 3;
		default:
			return 1;
	}
}

-(UITableViewCell *)headerCell {
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
	
	[cell.imageView setImage:[[UIImage imageNamed:@"Icon-72"] roundCornersOfRadius:10]];
	
	[cell.textLabel setFont:[UIFont boldSystemFontOfSize:20]];
	[cell.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
	[cell.detailTextLabel setTextColor:[UIColor darkTextColor]];
	
	NSString *build_number = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	NSString *short_version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	NSString *versionLabel = [NSString stringWithFormat:@" %@ %@ (%@)", NSLocalizedString(@"Version", nil), short_version, build_number];
	
	NSString *appName = @"Warmshowers.org";
	
	[cell.textLabel setText:appName];
	[cell.detailTextLabel setText:versionLabel];
	[cell setBackgroundColor:[UIColor clearColor]];
	[cell setBackgroundView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return cell;
}

-(UITableViewCell *)subHeaderCell {
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	[cell.textLabel setTextAlignment:UITextAlignmentCenter];
	[cell.textLabel setText:@"by Christopher Meyer"];
	[cell setBackgroundColor:[UIColor clearColor]];
	[cell setBackgroundView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	return cell;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			return [self headerCell];
		} else {
			return [self subHeaderCell];
		}
	}
	
	UITableViewCell *cell;
	
	switch (indexPath.section) {
		case 0:
			break;
		case 1:
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
			[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
			
			if ( indexPath.row == 0) {
				[cell.textLabel setText:NSLocalizedString(@"Follow us on Twitter", nil)];
			} else if (indexPath.row == 1) {
				[cell.textLabel setText:NSLocalizedString(@"Like us on Facebook", nil)];
			} else { // if (indexPath.row == 1) {
				[cell.textLabel setText:NSLocalizedString(@"Rate this App", nil)];
			}
            
			break;
		case 2:
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
			[cell.imageView setImage:[[UIImage imageNamed:@"trackmytour"] roundCornersOfRadius:10]];
			[cell.textLabel setText:@"TrackMyTour"];
			[cell.detailTextLabel setText:@"A tracking app for bike touring"];
			[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
			
			break;
	}
	
    return cell;
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			break;
		case 1:
			if (indexPath.row == 0) {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/warmshowers"]];
			} else if (indexPath.row == 1) {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.facebook.com/groups/135049549858210/"]];
			} else {
				[[RHPromptForReview sharedInstance] promptNow:nil];
			}
			break;
			
		default:
			if (indexPath.row == 0) {
				NSString *tmt = @"http://trackmytour.com/get/";
				NSString *url = [tmt stringByAppendingSource:@"warmshowers" medium:@"app" campaign:@"trackmytour"];
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
				break;
			}
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			if (indexPath.row == 0) {
				return 80;
			}
		case 2:
			return 80;
		default:
			return 44;
	}
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 1) {
		return @"Warmshowers";
	} else if (section == 2) {
		return @"Other Apps";
	}
	
	return @"";
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	switch (section) {
			//case 1:
			//	return @"\nTrackMyTour is another app";
		case 2:
			return @"The Warmshowers and TrackMyTour apps written by Christopher Meyer. Contact me at chris@schwiiz.org.";
			
		default:
			return @"";
	}
	
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end