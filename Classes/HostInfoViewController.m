//
//  HostInfoTableViewController.m
//  WS
//
//  Created by Christopher Meyer on 10/17/10.
//  Copyright 2010 Red House Consulting GmbH. All rights reserved.
//

#import "HostInfoViewController.h"
#import "Host.h"

#import "WSRequests.h"
#import "RHWebViewController.h"
#import "WSAppDelegate.h"
#import "NSDate+timesince.h"
#import "NSString+truncate.h"
#import "ContactHostViewController.h"

#import "WSHTTPClient.h"
#import "AFJSONRequestOperation.h"

#import "FeedbackTableViewController.h"
#import "SVProgressHUD.h"
#import "MKMapView+Utils.h"

@implementation HostInfoViewController
@synthesize host;
@synthesize statusLabel;
@synthesize showingLoadingIndicator;
@synthesize popoverActionsheet;

#pragma mark -
#pragma mark Table view data source

-(void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Host Info";
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																						   target:self
																						   action:@selector(showActions:)];
	
	self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 200, 20)];
	[self.statusLabel setBackgroundColor:[UIColor clearColor]];
	[self.statusLabel setFont:[UIFont systemFontOfSize:14]];
	[self.statusLabel setTextAlignment:UITextAlignmentCenter];
	
	if IsIPad {
		[self.statusLabel setTextColor:[UIColor darkGrayColor]];
	} else {
		[self.statusLabel setTextColor:[UIColor whiteColor]];
	}
	
	UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	[fixed setWidth:18];
	
	NSArray *toolbarItems = [NSArray arrayWithObjects:
							 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshHost)],
							 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
							 [[UIBarButtonItem alloc] initWithCustomView:self.statusLabel],
							 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
							 fixed,
							 nil];
	

	[self setToolbarItems:toolbarItems animated:YES];
    
	[self.host addObserver:self forKeyPath:@"last_updated_details" options:0 context:nil];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	[self refreshTableView:NO];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.navigationController setToolbarHidden:NO animated:animated];
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self refreshTableView:NO];
	
	if ([self.host needsUpdate]) {
		[self refreshHost];
	}
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.popoverActionsheet dismissWithClickedButtonIndex:[self.popoverActionsheet cancelButtonIndex] animated:YES];
}


-(void)refreshHost {
	
	[self refreshTableView:YES];
	
	if ([[WSHTTPClient sharedHTTPClient] reachable]) {
		[WSRequests hostDetailsWithHost:self.host];
		[WSRequests hostFeedbackWithHost:self.host];
		
	} else if (self.host.last_updated_details == nil) {
        RHAlertView *alert = [RHAlertView alertWithTitle:nil message:@"An error occurred while loading the host details. Please check your network connection and try again."];
        
        [alert addButtonWithTitle:@"OK" block:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        [alert show];
	} else if ([self.host isStale]) {
        [[RHAlertView alertWithOKButtonWithTitle:nil message:@"This host hasn't been updated in a while and might be out of date. Please connect to a network and refresh before attempting to contact this host."] show];
		[self refreshTableView:NO];
	} else {
		[self refreshTableView:NO];
	}
}

-(void)setLastUpdatedDate {
	if (self.host.last_updated_details) {
		NSString *updated = [NSString stringWithFormat:@"%@ ago", [self.host.last_updated_details timesinceWithDepth:1]];
		[self.statusLabel setText:[NSString stringWithFormat:@"Updated: %@", updated]];
	} else {
		[self.statusLabel setText:@""];
	}
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (self.isShowingLoadingIndicator) {
		return 0;
	} else {
		return 4;
	}
}


-(void)refreshTableView:(BOOL)show {
	
	if ([self.host.notcurrentlyavailable boolValue]) {
        
        [[RHAlertView alertWithOKButtonWithTitle:@"Host no longer available" message:@"This host is no longer available and will no longer be displayed on the map or in the host list."] show];
        
		[self.navigationController popViewControllerAnimated:YES];
		
	} else {
		
		/*
		 self.showingLoadingIndicator = show;
		
		if (self.isShowingLoadingIndicator) {
			[SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];
		} else {
			[SVProgressHUD dismiss];
		}
		  */
		
		
		[self setLastUpdatedDate];
		self.showingLoadingIndicator = show;
		[self.tableView reloadData];
	}
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
        case 0:
            return 1;
		case 1:
			return 8;
		case 2:
			return 1;
		default:
			return 12;
	}
}


// Customize the appearance of table view cells.
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
		[cell.detailTextLabel setFont:[UIFont systemFontOfSize:13]];
		[cell.detailTextLabel setNumberOfLines:0];
		[cell.detailTextLabel setLineBreakMode:UILineBreakModeWordWrap];
    }
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	switch (indexPath.section) {
        case 0:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            
            [cell.imageView setImage:[UIImage imageNamed:@"Icon-72-rounded"]];
            
            [cell.textLabel setText:[self.host title]];
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell setBackgroundView:[[UIView alloc] initWithFrame:CGRectZero]];
            [cell.textLabel setNumberOfLines:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            return cell;
            
            
		case 1:
			/*if (indexPath.row == 0) {
             cell.textLabel.text = @"Name";
             cell.detailTextLabel.text = [self.host title];
             
             } else
             */
            if (indexPath.row == 0) {
				// cell = self.addressCell;
				cell.textLabel.text = @"Address";
				cell.detailTextLabel.text = [[self.host address] trim];
				
			} else if (indexPath.row == 1) {
				cell.textLabel.text = @"Phone";
				cell.detailTextLabel.text = self.host.homephone;
				if (self.host.homephone) {
					cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				}
				
			} else if (indexPath.row == 2) {
				cell.textLabel.text = @"Comments";
				cell.detailTextLabel.text = [self.host.comments trim];
				
			} else if (indexPath.row == 3) {
				cell.textLabel.text = @"Notice";
				cell.detailTextLabel.text = self.host.preferred_notice;
				
			} else if (indexPath.row == 4) {
				cell.textLabel.text = @"Status";
				if ([self.host.notcurrentlyavailable boolValue]) {
					cell.detailTextLabel.text = @"Not available";
				} else {
					cell.detailTextLabel.text = @"Available";
				}
				
			} else if (indexPath.row == 5) {
 				cell.textLabel.text = @"Distance";
				cell.detailTextLabel.text = [self.host subtitle];
                
            } else if (indexPath.row == 6) {
				cell.textLabel.text = @"Mbr Since";
				cell.detailTextLabel.text = [self.host.member_since formatWithUTCTimeZone];
				
				
			} else if (indexPath.row == 7) {
				cell.textLabel.text = @"Last Login";
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ago", [self.host.last_login timesince]];
            }
			
			break;
		case 2:
			if (indexPath.row == 0) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"FeedbackCell"];
				cell.textLabel.text = [NSString stringWithFormat:@"Feedback (%i)", [self.host.feedback count]];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			break;
		case 3:
			if (indexPath.row == 0) {
				cell.textLabel.text = @"Max Guest";
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", [self.host.maxcyclists intValue]];
			} else if (indexPath.row == 1) {
				cell.textLabel.text = @"Motel";
				cell.detailTextLabel.text = self.host.motel;
			} else if (indexPath.row == 2) {
				cell.textLabel.text = @"Camping";
				cell.detailTextLabel.text = self.host.campground;
			} else if (indexPath.row == 3) {
				cell.textLabel.text = @"Bike Shop";
				cell.detailTextLabel.text = self.host.bikeshop;
			} else if (indexPath.row == 4) {
				cell.textLabel.text = @"Bed";
				cell.detailTextLabel.text = [self.host.bed boolValue] ? @"Yes" : @"No";
			} else if (indexPath.row == 5) {
				cell.textLabel.text = @"Laundry";
				cell.detailTextLabel.text = [self.host.laundry boolValue] ? @"Yes" : @"No";
			} else if (indexPath.row == 6) {
				cell.textLabel.text = @"Kitchen";
				cell.detailTextLabel.text = [self.host.kitchenuse boolValue] ? @"Yes" : @"No";
			} else if (indexPath.row == 7) {
				cell.textLabel.text = @"Lawnspace";
				cell.detailTextLabel.text = [self.host.lawnspace boolValue] ? @"Yes" : @"No";
			} else if (indexPath.row == 8) {
				cell.textLabel.text = @"Storage";
				cell.detailTextLabel.text = [self.host.storage boolValue] ? @"Yes" : @"No";
			} else if (indexPath.row == 9) {
				cell.textLabel.text = @"Shower";
				cell.detailTextLabel.text = [self.host.shower boolValue] ? @"Yes" : @"No";
			} else if (indexPath.row == 10) {
				cell.textLabel.text = @"SAG";
				cell.detailTextLabel.text = [self.host.sag boolValue] ? @"Yes" : @"No";
			} else if (indexPath.row == 11) {
				cell.textLabel.text = @"Food";
				cell.detailTextLabel.text = [self.host.food boolValue] ? @"Yes" : @"No";
			}
		default:
			break;
	}
	
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ((indexPath.section == 0) && (indexPath.row == 1)) {
		[self showActions:self.navigationItem.rightBarButtonItem];
		
	} else if (IsIPhone && (indexPath.section == 1) && (indexPath.row == 1) && (self.host.homephone)) {
        
        RHAlertView *alert = [RHAlertView alertWithTitle:@"Contact Host" message:[NSString stringWithFormat:@"Dial %@?", self.host.homephone]];
        
        [alert addButtonWithTitle:@"OK" block:^{
            NSString *tel = [NSString stringWithFormat:@"tel://%@", [self.host trimmedPhoneNumber]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tel]];
        }];
        
        [alert addCancelButton];
        [alert show];
        
	} else if (indexPath.section == 2) {
		FeedbackTableViewController *controller = [[FeedbackTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
		[controller setHost:self.host];
		[self.navigationController pushViewController:controller animated:YES];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
            // case 0:
			// return @"Contact";
		case 2:
			return @"Member Information";
		default:
			break;
	}
	
	return @"";
}

-(CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *_cell = [self tableView:_tableView cellForRowAtIndexPath:indexPath];
	UILineBreakMode lineBreakMode = _cell.detailTextLabel.lineBreakMode;
    
    if (indexPath.section == 0) {
        return 80;
    } else if (lineBreakMode == UILineBreakModeWordWrap) {
		NSString *text = _cell.detailTextLabel.text;
		UIFont *font = _cell.detailTextLabel.font;
		
		CGRect table_frame = self.tableView.frame;
		float margin = IsIPad ? 183 : 113;
		CGSize withinSize = CGSizeMake(table_frame.size.width-margin, MAXFLOAT);
		CGSize size = [text sizeWithFont:font constrainedToSize:withinSize lineBreakMode:lineBreakMode];
		
		return MAX(44, size.height + 22);
	}
	
	return 44;
}


#pragma mark AlertView Delegate

-(void)showActions:(id)sender {
	if (self.host.last_updated_details != nil) {
		self.popoverActionsheet = [[RHActionSheet alloc] init];
		
		__weak Host *bHost = self.host;
		__weak UINavigationController *bNavController = self.navigationController;
		
		if ([self.host.favourite boolValue]) {
			[self.popoverActionsheet addButtonWithTitle:@"Unmark as Favourite" block:^{
				bHost.favourite = [NSNumber numberWithBool:NO];
				[Host commit];
				[[NSNotificationCenter defaultCenter] postNotificationName:kShouldRedrawMapAnnotation object:nil userInfo:[NSDictionary dictionaryWithObject:bHost forKey:@"host"]];
				
				[SVProgressHUD showSuccessWithStatus:@"Unmarked as favourite"];
			}];
		} else {
			[self.popoverActionsheet addButtonWithTitle:@"Mark as Favourite" block:^{
				bHost.favourite = [NSNumber numberWithBool:YES];
				[Host commit];
				[[NSNotificationCenter defaultCenter] postNotificationName:kShouldRedrawMapAnnotation object:nil userInfo:[NSDictionary dictionaryWithObject:bHost forKey:@"host"]];
				[SVProgressHUD showSuccessWithStatus:@"Marked as favourite"];
			}];
		}
		
		[self.popoverActionsheet addButtonWithTitle:@"View in Maps" block:^{
            [MKMapView openInMapsWithAnnotation:bHost];
		}];
		
		[self.popoverActionsheet addButtonWithTitle:@"View Online" block:^{
			RHWebViewController *controller = [[RHWebViewController alloc] init];
			[controller setUrl:[NSURL URLWithString:[bHost infoURL]]];
			[controller setShouldShowDoneButton:YES];
			
			UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
			[bNavController presentModalViewController:navController animated:YES];
			
		}];
		
		[self.popoverActionsheet addButtonWithTitle:@"Contact Host" block:^{
			ContactHostViewController *controller = [[ContactHostViewController alloc] initWithNibName:@"ContactHostViewController" bundle:nil];
			[controller setHost:bHost];
			
			UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
			[navController setModalPresentationStyle:UIModalPresentationPageSheet];
			[bNavController presentModalViewController:navController animated:YES];
		}];
		
		[self.popoverActionsheet addCancelButtonWithTitle:@"Cancel"];
		
		[self.popoverActionsheet showFromBarButtonItem:sender animated:YES];
	}
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
	[self.host removeObserver:self forKeyPath:@"last_updated_details"];
	
	
}

@end