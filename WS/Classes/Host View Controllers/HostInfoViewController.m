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
    __weak HostInfoViewController *bself = self;
    
    self.refreshControl = [RHRefreshControl refreshControlWithBlock:^(RHRefreshControl *refreshControl) {
        
        if (bself.host.last_updated_details == nil) {
            [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading...", nil) maskType:SVProgressHUDMaskTypeGradient];
        }
        
        [WSRequests hostDetailsWithHost:bself.host success:^(NSURLSessionDataTask *task, id responseObject) {
            
            [refreshControl endRefreshing];
            
            [SVProgressHUD dismiss];
            
            [WSRequests hostFeedbackWithHost:bself.host];
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            [refreshControl endRefreshing];
            [SVProgressHUD dismiss];
            
            if (bself.host.last_updated_details == nil) {
                // [[RHAlertView alertWithOKButtonWithTitle:nil message:NSLocalizedString(@"An error occurred while loading the details of this host. Please check your network connection and try again.", nil)] show];
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Error loading host details.", nil)];
            } else if (self.host.isStale) {
                [[RHAlertView alertWithOKButtonWithTitle:nil message:NSLocalizedString(@"The details of this host haven't been updated in a while and might be out of date. Please connect to a network and refresh before attempting to contact this host.", nil)] show];
            }
            
        }];
    }];
    
}


-(void)refreshToolbar {
    __weak HostInfoViewController *bself = self;
    
    UIImage *starImage = self.host.favouriteValue ? [UIImage imageNamed:@"iconmonstr-star-2-icon"] : [UIImage imageNamed:@"iconmonstr-star-5-icon"];
    
    RHBarButtonItem *favouriteToggle = [[RHBarButtonItem alloc] initWithImage:starImage block:^{
        Host *host = bself.host;
        host.favouriteValue = !host.favouriteValue;
        [Host commit];
    }];
    
    RHBarButtonItem *compose = [[RHBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose block:^{
        [bself presentComposeViewController];
    }];
    
    NSArray *toolbarItems = @[favouriteToggle,
                              [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                              compose
                              ];
    
    [self setToolbarItems:toolbarItems animated:YES];
}

-(void)loadView {
    RHTableView *tableView = [[RHTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.tableViewCellLayout = [RHTableViewCellLayout formLayout];
    self.tableView = tableView;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:animated];
    
    __weak HostInfoViewController *bself = self;
    
    [self.host setDidUpdateBlock:^() {
        
        NSNumber *newFavouriteState = [bself.host.changedValues objectForKey:@"favourite"];
        
        if (newFavouriteState) {
            if ([newFavouriteState boolValue]) {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Marked as favourite", nil)];
            } else {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Unmarked as favourite", nil)];
            }
        }
        
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
    
    // must go here for the header to render correctly
    [self refreshTableView];
    
    if (self.host.needsUpdate) {
        [(RHRefreshControl *)self.refreshControl refresh];
    }
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
    
    [self.host setDidUpdateBlock:nil];
    [self.host setDidDeleteBlock:nil];
}

-(void)setLastUpdatedDate {
    if (self.host.last_updated_details) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Updated", nil), self.host.last_updated_details.formatWithLocalTimeZone]];
    } else {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Updated", nil), NSLocalizedString(@"never", nil)]];
    }
}

-(void)refreshTableView {
    
    __weak HostInfoViewController *bself = self;
    
    [self setLastUpdatedDate];
    [self refreshToolbar];
    
    RHTableView *tableView = (RHTableView *)self.tableView;
    
    [tableView reset];
    
    [tableView addSectionWithSectionHeaderText:nil];
    
    RHTableViewCell *cell = [tableView addCell:[RHTableViewCell
                                               cellWithImage:nil
                                                label:self.host.fullname]];
    
    [cell.imageView2 setImageWithURL:[NSURL URLWithString:self.host.imageURL] placeholderImage:[UIImage imageNamed:@"ws"]];
    [cell setHeightBlock:^CGFloat {
        return 180;
    }];
        

    
    
    // [self.imageView setImageWithURL:[NSURL URLWithString:[self.host imageURL]] placeholderImage:[UIImage imageNamed:@"ws"]];
    
    [tableView addSectionWithSectionHeaderText:nil];
    
    NSString *feedbackLabel = [NSString stringWithFormat:@"%@ (%lu)", NSLocalizedString(@"View Feedback", nil), (unsigned long)[self.host.feedback count]];
    
    // NSString *feedbackLabel = NSLocalizedString(@"View Feedback", nil);
    
     cell = [tableView addCell:feedbackLabel
                                didSelectBlock:^{
                                    FeedbackTableViewController *controller = [[FeedbackTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
                                    [controller setHost:bself.host];
                                    [bself.navigationController pushViewController:controller animated:YES];
                                }
                             ];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    [tableView addSectionWithSectionHeaderText:nil];
    [tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Address", nil) largeLabel:[[self.host address] trim]]];
    [tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Phone", nil) largeLabel:self.host.homephone]];
    [tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Mobile", nil) largeLabel:self.host.mobilephone]];
    
    [tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Notice", nil) largeLabel:self.host.preferred_notice]];
    [tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Status", nil) largeLabel:self.host.statusString]];
    [tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Distance", nil) largeLabel:self.host.subtitle]];
    [tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Mbr Since", nil) largeLabel:self.host.member_since.formatWithLocalTimeZoneWithoutTime]];
    [tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Last Login", nil) largeLabel:[NSString stringWithFormat:NSLocalizedString(@"%@ ago", nil), self.host.last_login.timesince]]];
    
    
    [tableView addSectionWithSectionHeaderText:NSLocalizedString(@"Comments", nil)];
    // [tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Comments", nil) largeLabel:self.host.comments.trim]];
    [tableView addCell:[RHTableViewCell cellWithSingleLabel:self.host.comments.trim]];
    
    [tableView addSectionWithSectionHeaderText:NSLocalizedString(@"Member Information", nil)];
    [tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Max Guests", nil) largeLabel:[NSString stringWithFormat:@"%i", [self.host.maxcyclists intValue]]]];
    [tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Motel", nil) largeLabel:self.host.motel]];
    [tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Camping", nil) largeLabel:self.host.campground]];
    [tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Bike Shop", nil) largeLabel:self.host.bikeshop]];
    [tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Bed", nil) largeLabel:self.host.bed.boolLabel]];
    [tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Laundry", nil) largeLabel:self.host.laundry.boolLabel]];
    [tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Kitchen", nil) largeLabel:self.host.kitchenuse.boolLabel]];
    [tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Lawnspace", nil) largeLabel:self.host.lawnspace.boolLabel]];
    [tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Storage", nil) largeLabel:self.host.storage.boolLabel]];
    [tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Shower", nil) largeLabel:self.host.shower.boolLabel]];
    [tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"SAG", nil) largeLabel:self.host.sag.boolLabel]];
    [tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Food", nil) largeLabel:self.host.food.boolLabel]];
    
    [tableView reloadData];
    
}

#pragma mark AlertView Delegate

-(void)showActions:(id)sender {
    // if (self.host.last_updated_details) {
        
        RHActionSheet *popoverActionsheet = [[RHActionSheet alloc] init];
        
        __weak Host *bHost = self.host;
        __weak HostInfoViewController *bself = self;
        
        [popoverActionsheet addButtonWithTitle:NSLocalizedString(@"Contact Host", nil) block:^{
            [bself presentComposeViewController];
        }];
        
        [popoverActionsheet addButtonWithTitle:NSLocalizedString(@"Open in Safari", nil) block:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[bHost infoURL]]];
        }];
        
        
        [popoverActionsheet addButtonWithTitle:NSLocalizedString(@"View in Maps", nil) block:^{
            [MKMapView openInMapsWithAnnotation:bHost];
        }];
        
        if ([self.host.favourite boolValue]) {
            [popoverActionsheet addButtonWithTitle:NSLocalizedString(@"Unmark as Favourite", nil) block:^{
                bHost.favouriteValue = NO;
                [Host commit];
                [[NSNotificationCenter defaultCenter] postNotificationName:kShouldRedrawMapAnnotation object:nil userInfo:[NSDictionary dictionaryWithObject:bHost forKey:@"host"]];
            }];
        } else {
            [popoverActionsheet addButtonWithTitle:NSLocalizedString(@"Mark as Favourite", nil) block:^{
                bHost.favouriteValue = YES;
                [Host commit];
                [[NSNotificationCenter defaultCenter] postNotificationName:kShouldRedrawMapAnnotation object:nil userInfo:[NSDictionary dictionaryWithObject:bHost forKey:@"host"]];
            }];
        }
     
        [popoverActionsheet addCancelButton];
        
        [popoverActionsheet showFromBarButtonItem:sender animated:YES];
  //  }
}


/*
-(HostInfoTopView *)topView {
    
    if (_topView == nil) {
    
       self.topView = [UIView viewFromNibNamed:@"HostInfoTopView" owner:self];

        self.topView.height = 200;
        
        [_topView.imageView setImageWithURL:[NSURL URLWithString:self.host.imageURL] placeholderImage:[UIImage imageNamed:@"ws"]];
        [_topView.titleLabel setText:self.host.title];
    }
    
    return _topView;
    
}
*/

-(void)presentComposeViewController {
    ComposeMessageViewController *controller = [ComposeMessageViewController controllerWithHost:self.host];
    UINavigationController *navController = [controller wrapInNavigationControllerWithPresentationStyle:UIModalPresentationPageSheet];
    [self presentViewController:navController animated:YES completion:nil];
}

@end