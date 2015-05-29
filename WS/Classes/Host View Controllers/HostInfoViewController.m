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

#import "HostInfoViewController.h"
#import "Host.h"

#import "WSRequests.h"
#import "WSAppDelegate.h"
#import "NSDate+timesince.h"
#import "ComposeMessageViewController.h"
#import "WSHTTPClient.h"
#import "FeedbackTableViewController.h"
#import "MKMapView+Utils.h"
#import "NSNumber+WS.h"

@interface HostInfoViewController()
@property (strong, nonatomic) RHTableView *tableView;
@property (nonatomic, strong) UIView *topView;
-(void)presentComposeViewController;
@end

@implementation HostInfoViewController

static NSString *CellIdentifier = @"40e03609-53d8-49e2-8080-b7ccf4e8d234";

#pragma mark -
#pragma mark Table view data source

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedString(@"Host Info", nil)];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"RHLabelTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                           target:self
                                                                                           action:@selector(showActions:)];
    
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 200, 20)];
    [self.statusLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [self.statusLabel setTextAlignment:NSTextAlignmentCenter];
    
    
    __weak HostInfoViewController *bself = self;
    
    RHBarButtonItem *compose = [[RHBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose block:^{
        [bself presentComposeViewController];
    }];
    
    NSArray *toolbarItems = @[
                              [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshHost)],
                              [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                              [[UIBarButtonItem alloc] initWithCustomView:self.statusLabel],
                              [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                              compose
                              ];
    
    
    [self setToolbarItems:toolbarItems animated:YES];
}

-(void)loadView {
    self.tableView = [[RHTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.tableViewCellLayout = [RHTableViewCellLayout formLayout];
    self.view = self.tableView;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:animated];
    
    __weak HostInfoViewController *bself = self;
    
    [self.host setDidUpdateBlock:^() {
        if (bself.host.notcurrentlyavailableValue) {
            RHAlertView *alert = [RHAlertView alertWithTitle:NSLocalizedString(@"Host no longer available", nil)
                                                     message:NSLocalizedString(@"This host is no longer available and will be removed from the map and host list.", nil)];
            
            [alert addButtonWithTitle:kOK block:^{
                [bself.navigationController popViewControllerAnimated:YES];
            }];
            
            [alert show];
        } else {
            [bself refreshTableView];
        }
    }];
    
    [self.host setDidDeleteBlock:^() {
        // NSLog(@"%@", @"delete called");
    }];
    
    if ([self.host needsUpdate]) {
        [self refreshHost];
    }
    
    [self refreshTableView];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.host setDidUpdateBlock:nil];
    [self.host setDidDeleteBlock:nil];
    
    [self.navigationController setToolbarHidden:YES animated:animated];
}

-(void)refreshHost {
    
    __weak UINavigationController *bNavigationController = self.navigationController;
    
    if ([[WSHTTPClient sharedHTTPClient] reachable]) {
        
        [WSRequests hostDetailsWithHost:self.host];
        // [WSRequests hostFeedbackWithHost:self.host];
        
    } else if (self.host.last_updated_details == nil) {
        RHAlertView *alert = [RHAlertView alertWithTitle:nil message:NSLocalizedString(@"An error occurred while loading the details of this host. Please check your network connection and try again.", nil)];
        
        [alert addButtonWithTitle:kOK block:^{
            [bNavigationController popViewControllerAnimated:YES];
        }];
        
        [alert show];
    } else if ([self.host isStale]) {
        [[RHAlertView alertWithOKButtonWithTitle:nil message:NSLocalizedString(@"The details of this host hasn't been updated in a while and might be out of date. Please connect to a network and refresh before attempting to contact this host.", nil)] show];
    } else {
        
    }
}

-(void)setLastUpdatedDate {
    if (self.host.last_updated_details) {
        NSString *updated = [NSString stringWithFormat:NSLocalizedString(@"%@ ago", nil), [self.host.last_updated_details timesinceWithDepth:1]];
        [self.statusLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Updated: %@", nil), updated]];
    } else {
        [self.statusLabel setText:@""];
    }
}

-(void)refreshTableView {
    
    __weak HostInfoViewController *bself = self;
    
    [self setLastUpdatedDate];
    
    [self.tableView reset];
    
    if (self.host.last_updated_details) {
        
        [self.tableView setTableHeaderView:self.topView];
        
        [self.tableView addSectionWithSectionHeaderText:NSLocalizedString(@"Actions", nil)];
        
        // NSString *feedbackLabel = [NSString stringWithFormat:@"%@ (%i)", NSLocalizedString(@"Feedback (%i)", nil), [self.host.feedback count]];
        NSString *feedbackLabel = NSLocalizedString(@"Feedback", nil);
        
        RHTableViewCell *cell = [self.tableView addCell:feedbackLabel
                                         didSelectBlock:^{
                                             FeedbackTableViewController *controller = [[FeedbackTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
                                             [controller setHost:bself.host];
                                             [bself.navigationController pushViewController:controller animated:YES];
                                         }
                                 ];
        
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        [self.tableView addSectionWithSectionHeaderText:nil];
        [self.tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Address", nil) largeLabel:[[self.host address] trim]]];
        [self.tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Phone", nil) largeLabel:self.host.homephone]];
        [self.tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Mobile", nil) largeLabel:self.host.mobilephone]];
        [self.tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Comments", nil) largeLabel:[self.host.comments trim]]];
        [self.tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Notice", nil) largeLabel:self.host.preferred_notice]];
        [self.tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Status", nil) largeLabel:self.host.statusString]];
        [self.tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Distance", nil) largeLabel:self.host.subtitle]];
        [self.tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Mbr Since", nil) largeLabel:[self.host.member_since formatWithUTCTimeZone]]];
        [self.tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Last Login", nil) largeLabel:[NSString stringWithFormat:NSLocalizedString(@"%@ ago", nil), [self.host.last_login timesince]]]];
        
        [self.tableView addSectionWithSectionHeaderText:NSLocalizedString(@"Member Information", nil)];
        [self.tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Max Guests", nil) largeLabel:[NSString stringWithFormat:@"%i", [self.host.maxcyclists intValue]]]];
        [self.tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Motel", nil) largeLabel:self.host.motel]];
        [self.tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Camping", nil) largeLabel:self.host.campground]];
        [self.tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Bike Shop", nil) largeLabel:self.host.bikeshop]];
        [self.tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Bed", nil) largeLabel:self.host.bed.boolLabel]];
        [self.tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Laundry", nil) largeLabel:self.host.laundry.boolLabel]];
        [self.tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Kitchen", nil) largeLabel:self.host.kitchenuse.boolLabel]];
        [self.tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Lawnspace", nil) largeLabel:self.host.lawnspace.boolLabel]];
        [self.tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Storage", nil) largeLabel:self.host.storage.boolLabel]];
        [self.tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Shower", nil) largeLabel:self.host.shower.boolLabel]];
        [self.tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"SAG", nil) largeLabel:self.host.sag.boolLabel]];
        [self.tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Food", nil) largeLabel:self.host.food.boolLabel]];
        
        [self.tableView reloadData];
    }
}




// Customize the appearance of table view cells.
/*
 -(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
 RHTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 
 switch (indexPath.section) {
 
 case 0:
 if (indexPath.row == 0) {
 
 cell.leftLabel.text = NSLocalizedString(@"Address", nil);
 cell.largeLabel.text = [[self.host address] trim];
 
 } else if (indexPath.row == 1) {
 cell.leftLabel.text = NSLocalizedString(@"Phone", nil);
 
 if (self.host.homephone) {
 cell.largeLabel.text = self.host.homephone;
 cell.selectionStyle = UITableViewCellSelectionStyleBlue;
 } else {
 cell.largeLabel.text = NSLocalizedString(@"n/a", nil);
 }
 } else if (indexPath.row == 2) {
 cell.leftLabel.text = NSLocalizedString(@"Mobile", nil);
 cell.largeLabel.text = self.host.mobilephone;
 if ((self.host.mobilephone) && IsIPhone) {
 cell.selectionStyle = UITableViewCellSelectionStyleBlue;
 } else {
 cell.largeLabel.text = NSLocalizedString(@"n/a", nil);
 }
 } else if (indexPath.row == 3) {
 cell.leftLabel.text = NSLocalizedString(@"Comments", nil);
 cell.largeLabel.text = [self.host.comments trim];
 // [cell.largeLabel setLineBreakMode:NSLineBreakByWordWrapping];
 } else if (indexPath.row == 4) {
 cell.leftLabel.text = NSLocalizedString(@"Notice", nil);
 cell.largeLabel.text = self.host.preferred_notice;
 } else if (indexPath.row == 5) {
 cell.leftLabel.text = NSLocalizedString(@"Status", nil);
 if ([self.host.notcurrentlyavailable boolValue]) {
 cell.largeLabel.text = NSLocalizedString(@"Not available", nil);
 } else {
 cell.largeLabel.text = NSLocalizedString(@"Available", nil);
 }
 } else if (indexPath.row == 6) {
 cell.leftLabel.text = NSLocalizedString(@"Distance", nil);
 cell.largeLabel.text = [self.host subtitle];
 } else if (indexPath.row == 7) {
 cell.leftLabel.text = NSLocalizedString(@"Mbr Since", nil);
 cell.largeLabel.text = [self.host.member_since formatWithUTCTimeZone];
 } else if (indexPath.row == 8) {
 cell.leftLabel.text = NSLocalizedString(@"Last Login", nil);
 cell.largeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ ago", nil), [self.host.last_login timesince]];
 }
 
 break;
 
 
 return cell;
 }
 */


#pragma mark -
#pragma mark Table view delegate

/*
 -(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (IsIPhone && (indexPath.section == 0) && (indexPath.row == 1) && (self.host.homephone)) {
 RHAlertView *alert = [RHAlertView alertWithTitle:NSLocalizedString(@"Contact Host", nil) message:[NSString stringWithFormat:NSLocalizedString(@"Dial %@?", nil), self.host.homephone]];
 
 [alert addCancelButton];
 
 [alert addButtonWithTitle:kOK block:^{
 NSString *tel = [NSString stringWithFormat:@"tel://%@", [Host trimmedPhoneNumber:self.host.homephone]];
 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tel]];
 }];
 
 [alert show];
 } else if (IsIPhone && (indexPath.section == 0) && (indexPath.row == 2) && (self.host.mobilephone)) {
 RHAlertView *alert = [RHAlertView alertWithTitle:NSLocalizedString(@"Contact Host", nil) message:[NSString stringWithFormat:NSLocalizedString(@"Dial %@?", nil), self.host.mobilephone]];
 
 [alert addCancelButton];
 
 [alert addButtonWithTitle:kOK block:^{
 NSString *tel = [NSString stringWithFormat:@"tel://%@", [Host trimmedPhoneNumber:self.host.mobilephone]];
 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tel]];
 }];
 
 [alert show];
 } else if (indexPath.section == 1) {
 FeedbackTableViewController *controller = [[FeedbackTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
 [controller setHost:self.host];
 [self.navigationController pushViewController:controller animated:YES];
 }
 
 [tableView deselectRowAtIndexPath:indexPath animated:YES];
 }
 */


#pragma mark AlertView Delegate

-(void)showActions:(id)sender {
    if (self.host.last_updated_details) {
        
        RHActionSheet *popoverActionsheet = [[RHActionSheet alloc] init];
        
        __weak Host *bHost = self.host;
        __weak HostInfoViewController *bself = self;
        
        if ([self.host.favourite boolValue]) {
            [popoverActionsheet addButtonWithTitle:NSLocalizedString(@"Unmark as Favourite", nil) block:^{
                bHost.favourite = [NSNumber numberWithBool:NO];
                [Host commit];
                [[NSNotificationCenter defaultCenter] postNotificationName:kShouldRedrawMapAnnotation object:nil userInfo:[NSDictionary dictionaryWithObject:bHost forKey:@"host"]];
                
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Unmarked as favourite", nil)];
            }];
        } else {
            [popoverActionsheet addButtonWithTitle:NSLocalizedString(@"Mark as Favourite", nil) block:^{
                bHost.favourite = [NSNumber numberWithBool:YES];
                [Host commit];
                [[NSNotificationCenter defaultCenter] postNotificationName:kShouldRedrawMapAnnotation object:nil userInfo:[NSDictionary dictionaryWithObject:bHost forKey:@"host"]];
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Marked as favourite", nil)];
            }];
        }
        
        [popoverActionsheet addButtonWithTitle:NSLocalizedString(@"View in Maps", nil) block:^{
            [MKMapView openInMapsWithAnnotation:bHost];
        }];
        
        [popoverActionsheet addButtonWithTitle:NSLocalizedString(@"Open in Safari", nil) block:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[bHost infoURL]]];
        }];
        
        [popoverActionsheet addButtonWithTitle:NSLocalizedString(@"Contact Host", nil) block:^{
            [bself presentComposeViewController];
        }];
        
        [popoverActionsheet addCancelButton];
        
        [popoverActionsheet showFromBarButtonItem:sender animated:YES];
    }
}


-(UIView *)topView {
    
    if (_topView == nil) {
        CGFloat viewWidth = self.view.bounds.size.width;
        CGFloat baseHeight =  IsIPad ? 180 : 160;
        
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, baseHeight)];
        [_topView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_topView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_topView setBackgroundColor:[UIColor whiteColor]];
        
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, baseHeight-20, baseHeight-20)];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [imageView setImageWithURL:[NSURL URLWithString:[self.host imageURL]]
                  placeholderImage:[UIImage imageNamed:@"ws"]
         ];
        [_topView addSubview:imageView];
        
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(baseHeight, 0, viewWidth - baseHeight - 20, baseHeight)];
        [titleLabel setNumberOfLines:0];
        [titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [titleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
        [titleLabel setText:[self.host title]];
        [_topView addSubview:titleLabel];
    }
    
    return _topView;
    
}


-(void)presentComposeViewController {
    ComposeMessageViewController *controller = [ComposeMessageViewController controllerWithHost:self.host];
    UINavigationController *navController = [controller wrapInNavigationControllerWithPresentationStyle:UIModalPresentationPageSheet];
    [self presentViewController:navController animated:YES completion:nil];
}

@end