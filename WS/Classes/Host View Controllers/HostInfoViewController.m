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
    weakify(self);
    
    self.refreshControl = [RHRefreshControl refreshControlWithBlock:^(RHRefreshControl *refreshControl) {
        strongify(self);
        
        if (self.host.last_updated_details == nil) {
            [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading...", nil)];
        }
        
        [[WSHTTPClient sharedHTTPClient] hostDetailsWithHost:self.host].then(^() {
            
            [SVProgressHUD dismiss];
            
            // We don't return the promise since we don't necessarily want to wait for this to finish.
            [[WSHTTPClient sharedHTTPClient] hostFeedbackWithHost:self.host];
            
        }).catch(^(NSError *error) {
            
            NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
            
            if (response) {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"This host is no longer available.", nil)];
                [self.host delete];
                [Host commit];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [SVProgressHUD dismiss];
            }
            
        }).finally(^() {
            [refreshControl endRefreshing];
            
        });
        
    }];
}


-(void)refreshToolbar {
    weakify(self);
    
    UIImage *starImage = self.host.favouriteValue ? [UIImage imageNamed:@"iconmonstr-star-2-icon"] : [UIImage imageNamed:@"iconmonstr-star-5-icon"];
    
    RHBarButtonItem *favouriteToggle = [[RHBarButtonItem alloc] initWithImage:starImage block:^(RHBarButtonItem *barButtonItem) {
        strongify(self);
        Host *host = self.host;
        host.favouriteValue = !host.favouriteValue;
        [Host commit];
    }];
    
    RHBarButtonItem *compose = [[RHBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose block:^(RHBarButtonItem *barButtonItem) {
        strongify(self);
        [self presentComposeViewController];
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
    
    weakify(self);
    
    [self.host setDidUpdateBlock:^() {
        strongify(self);
        NSNumber *newFavouriteState = [self.host.changedValues objectForKey:@"favourite"];
        
        if (newFavouriteState) {
            if ([newFavouriteState boolValue]) {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Marked as favourite", nil)];
            } else {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Unmarked as favourite", nil)];
            }
        }
        [self refreshTableView];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShouldRedrawMapAnnotation object:nil];
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
    
    [tableView addSectionWithSectionHeaderText:nil];
    
    NSString *feedbackLabel = [NSString stringWithFormat:@"%@ (%lu)", NSLocalizedString(@"View Feedback", nil), (unsigned long)[self.host.feedback count]];
    
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
    [tableView addCell:[RHTableViewCell cellWithLeftLabel:NSLocalizedString(@"Username", nil) largeLabel:self.host.name]];
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
    
    UIAlertController *actionsheet = [UIAlertController actionSheetWithTitle:nil
                                                                     message:nil
                                                               barButtonItem:sender];
    weakify(self);
    
    [actionsheet addButtonWithTitle:NSLocalizedString(@"Contact Host", nil) block:^(UIAlertAction * _Nonnull action) {
        strongify(self);
        [self presentComposeViewController];
    }];
    
    [actionsheet addButtonWithTitle:NSLocalizedString(@"Open in Safari", nil) block:^(UIAlertAction * _Nonnull action) {
        strongify(self);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.host infoURL]]];
    }];
    
    
    [actionsheet addButtonWithTitle:NSLocalizedString(@"View in Maps", nil) block:^(UIAlertAction * _Nonnull action) {
        [MKMapView openInMapsWithAnnotation:self.host];
    }];
    
    if ([self.host.favourite boolValue]) {
        [actionsheet addButtonWithTitle:NSLocalizedString(@"Unmark as Favourite", nil) block:^(UIAlertAction * _Nonnull action) {
            strongify(self);
            self.host.favouriteValue = NO;
            [Host commit];
            [[NSNotificationCenter defaultCenter] postNotificationName:kShouldRedrawMapAnnotation object:nil];
        }];
    } else {
        [actionsheet addButtonWithTitle:NSLocalizedString(@"Mark as Favourite", nil) block:^(UIAlertAction * _Nonnull action) {
            strongify(self);
            self.host.favouriteValue = YES;
            [Host commit];
            [[NSNotificationCenter defaultCenter] postNotificationName:kShouldRedrawMapAnnotation object:nil];
        }];
    }
    
    [actionsheet addCancelButton];
    
    [actionsheet presentInViewController:self];
    
}

-(void)presentComposeViewController {
    ComposeMessageViewController *controller = [ComposeMessageViewController controllerWithHost:self.host];
    UINavigationController *navController = [controller wrapInNavigationControllerWithPresentationStyle:UIModalPresentationPageSheet];
    [self presentViewController:navController animated:YES completion:nil];
}

@end
