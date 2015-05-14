//
//  HostInfoViewController.m
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
#import "ContactHostViewController.h"
#import "WSHTTPClient.h"
#import "FeedbackTableViewController.h"
#import "MKMapView+Utils.h"

@implementation HostInfoViewController

static NSString *CellIdentifier = @"Cell";

#pragma mark -
#pragma mark Table view data source

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedString(@"Host Info", nil)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                           target:self
                                                                                           action:@selector(showActions:)];
    
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 200, 20)];
    
    [self.statusLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [self.statusLabel setTextAlignment:NSTextAlignmentCenter];
    
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
    
    [self.tableView registerClass:[RHTableViewCellStyleValue2 class] forCellReuseIdentifier:CellIdentifier];
    
    [self.tableView setTableHeaderView:self.topView];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  
    NSNumber *oldValue = [change objectForKey:NSKeyValueChangeOldKey];
    NSNumber *newValue = [change objectForKey:NSKeyValueChangeNewKey];
    
    if ([oldValue isEqualToNumber:newValue]) {
        // nothing changed, do nothing
    } else if ([newValue boolValue]) {
        RHAlertView *alert = [RHAlertView alertWithTitle:NSLocalizedString(@"Host no longer available", nil) message:NSLocalizedString(@"This host is no longer available and will no longer be displayed on the map or in the host list.", nil)];
        
        __weak HostInfoViewController *bself = self;
        
        [alert addButtonWithTitle:kOK block:^{
            [bself.navigationController popViewControllerAnimated:YES];
        }];
        
        [alert show];
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:animated];
    
    [self.host addObserver:self forKeyPath:@"notcurrentlyavailable" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    __weak HostInfoViewController *bself = self;
    [self.host setDidUpdateBlock:^() {
        [bself refreshTableView:NO];
    }];
    
    if ([self.host needsUpdate]) {
        [self refreshHost];
    } else {
        [self refreshTableView:NO];
    }
    
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
    
    [self.host removeObserver:self forKeyPath:@"notcurrentlyavailable"];
    [self.host setDidUpdateBlock:nil];
    
     [self.navigationController setToolbarHidden:YES animated:animated];
}

-(void)refreshHost {
    
    [self refreshTableView:YES];
    
    __weak UINavigationController *bNavigationController = self.navigationController;
    
    if ([[WSHTTPClient sharedHTTPClient] reachable]) {
        [WSRequests hostDetailsWithHost:self.host];
        [WSRequests hostFeedbackWithHost:self.host];
        
    } else if (self.host.last_updated_details == nil) {
        RHAlertView *alert = [RHAlertView alertWithTitle:nil message:NSLocalizedString(@"An error occurred while loading the host details. Please check your network connection and try again.", nil)];
        
        [alert addButtonWithTitle:kOK block:^{
            [bNavigationController popViewControllerAnimated:YES];
        }];
        
        [alert show];
    } else if ([self.host isStale]) {
        [[RHAlertView alertWithOKButtonWithTitle:nil message:NSLocalizedString(@"This host hasn't been updated in a while and might be out of date. Please connect to a network and refresh before attempting to contact this host.", nil)] show];
        [self refreshTableView:NO];
    } else {
        [self refreshTableView:NO];
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

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isShowingLoadingIndicator) {
        return 0;
    } else {
        return 3;
    }
}

-(void)refreshTableView:(BOOL)show {
    [self setLastUpdatedDate];
    [self setShowingLoadingIndicator:show];
    
    if (show) {
        [self.tableView setTableHeaderView:nil];
    } else {
        [self.tableView setTableHeaderView:self.topView];
    }
    
    [self.tableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 9;
        case 1:
            return 1;
        default:
            return 12;
    }
}


// Customize the appearance of table view cells.
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [cell.detailTextLabel setNumberOfLines:0];
    [cell.detailTextLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    switch (indexPath.section) {
            
        case 0:
            if (indexPath.row == 0) {
                
                cell.textLabel.text = NSLocalizedString(@"Address", nil);
                cell.detailTextLabel.text = [[self.host address] trim];
                
            } else if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"Phone", nil);
                
                if (self.host.homephone) {
                    cell.detailTextLabel.text = self.host.homephone;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                } else {
                    cell.detailTextLabel.text = NSLocalizedString(@"n/a", nil);
                }
            } else if (indexPath.row == 2) {
                cell.textLabel.text = NSLocalizedString(@"Mobile", nil);
                    cell.detailTextLabel.text = self.host.mobilephone;
                if ((self.host.mobilephone) && IsIPhone) {
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                } else {
                    cell.detailTextLabel.text = NSLocalizedString(@"n/a", nil);
                }
            } else if (indexPath.row == 3) {
                cell.textLabel.text = NSLocalizedString(@"Comments", nil);
                cell.detailTextLabel.text = [self.host.comments trim];
                // [cell.detailTextLabel setLineBreakMode:NSLineBreakByWordWrapping];
            } else if (indexPath.row == 4) {
                cell.textLabel.text = NSLocalizedString(@"Notice", nil);
                cell.detailTextLabel.text = self.host.preferred_notice;
            } else if (indexPath.row == 5) {
                cell.textLabel.text = NSLocalizedString(@"Status", nil);
                if ([self.host.notcurrentlyavailable boolValue]) {
                    cell.detailTextLabel.text = NSLocalizedString(@"Not available", nil);
                } else {
                    cell.detailTextLabel.text = NSLocalizedString(@"Available", nil);
                }
            } else if (indexPath.row == 6) {
                cell.textLabel.text = NSLocalizedString(@"Distance", nil);
                cell.detailTextLabel.text = [self.host subtitle];
            } else if (indexPath.row == 7) {
                cell.textLabel.text = NSLocalizedString(@"Mbr Since", nil);
                cell.detailTextLabel.text = [self.host.member_since formatWithUTCTimeZone];
            } else if (indexPath.row == 8) {
                cell.textLabel.text = NSLocalizedString(@"Last Login", nil);
                cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ ago", nil), [self.host.last_login timesince]];
            }
            
            break;
            
        case 1:
            if (indexPath.row == 0) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"FeedbackCell"];
                cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Feedback (%i)", nil), [self.host.feedback count]];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            break;
            
        case 2:
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"Max Guest", nil);
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", [self.host.maxcyclists intValue]];
            } else if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"Motel", nil);
                cell.detailTextLabel.text = self.host.motel;
            } else if (indexPath.row == 2) {
                cell.textLabel.text = NSLocalizedString(@"Camping", nil);
                cell.detailTextLabel.text = self.host.campground;
            } else if (indexPath.row == 3) {
                cell.textLabel.text = NSLocalizedString(@"Bike Shop", nil);
                cell.detailTextLabel.text = self.host.bikeshop;
            } else if (indexPath.row == 4) {
                cell.textLabel.text = NSLocalizedString(@"Bed", nil);
                cell.detailTextLabel.text = [self.host.bed boolValue] ? kYes : kNo;
            } else if (indexPath.row == 5) {
                cell.textLabel.text = NSLocalizedString(@"Laundry", nil);
                cell.detailTextLabel.text = [self.host.laundry boolValue] ? kYes : kNo;
            } else if (indexPath.row == 6) {
                cell.textLabel.text = NSLocalizedString(@"Kitchen", nil);
                cell.detailTextLabel.text = [self.host.kitchenuse boolValue] ? kYes : kNo;
            } else if (indexPath.row == 7) {
                cell.textLabel.text = NSLocalizedString(@"Lawnspace", nil);
                cell.detailTextLabel.text = [self.host.lawnspace boolValue] ? kYes : kNo;
            } else if (indexPath.row == 8) {
                cell.textLabel.text = NSLocalizedString(@"Storage", nil);
                cell.detailTextLabel.text = [self.host.storage boolValue] ? kYes : kNo;
            } else if (indexPath.row == 9) {
                cell.textLabel.text = NSLocalizedString(@"Shower", nil);
                cell.detailTextLabel.text = [self.host.shower boolValue] ? kYes : kNo;
            } else if (indexPath.row == 10) {
                cell.textLabel.text = NSLocalizedString(@"SAG", nil);
                cell.detailTextLabel.text = [self.host.sag boolValue] ? kYes : kNo;
            } else if (indexPath.row == 11) {
                cell.textLabel.text = NSLocalizedString(@"Food", nil);
                cell.detailTextLabel.text = [self.host.food boolValue] ? kYes : kNo;
            }
        default:
            break;
    }
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

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

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
            // case 0:
            // return @"Contact";
        case 1:
            return NSLocalizedString(@"Member Information", nil);
        default:
            break;
    }
    
    return @"";
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    UILineBreakMode lineBreakMode = cell.detailTextLabel.lineBreakMode;
    
    if (lineBreakMode == NSLineBreakByWordWrapping) {
        
        NSString *text = cell.detailTextLabel.text;
        UIFont *font   = cell.detailTextLabel.font;
        
        // 20 is the left and right margins
        // 111 is trial-and-error with iOS7
        CGFloat detailLabelWidth = tableView.width - 20 - 110;
        
        CGSize withinSize = CGSizeMake(detailLabelWidth, CGFLOAT_MAX);
        
        CGRect textRect = [text boundingRectWithSize:withinSize
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:font}
                                             context:nil];
        
        CGSize size = textRect.size;
        
        return MAX(kRHDefaultCellHeight, size.height + kRHTopBottomMargin*2);
    }
    
    return 44;
}

#pragma mark AlertView Delegate

-(void)showActions:(id)sender {
    if (self.host.last_updated_details != nil) {
        RHActionSheet *popoverActionsheet = [[RHActionSheet alloc] init];
        
        __weak Host *bHost = self.host;
        __weak UINavigationController *bNavController = self.navigationController;
        
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
        
        [popoverActionsheet addButtonWithTitle:NSLocalizedString(@"View Online", nil) block:^{
            RHWebViewController *controller = [[RHWebViewController alloc] init];
            [controller setUrl:[NSURL URLWithString:[bHost infoURL]]];
            [controller setShouldShowDoneButton:YES];
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
            [bNavController presentViewController:navController animated:YES completion:nil];
        }];
        
        [popoverActionsheet addButtonWithTitle:NSLocalizedString(@"Contact Host", nil) block:^{
            ContactHostViewController *controller = [[ContactHostViewController alloc] initWithNibName:@"ContactHostViewController" bundle:nil];
            [controller setHost:bHost];
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
            [navController setModalPresentationStyle:UIModalPresentationPageSheet];
            [bNavController presentViewController:navController animated:YES completion:nil];
        }];
        
        [popoverActionsheet addCancelButtonWithTitle:kCancel];
        
        [popoverActionsheet showFromBarButtonItem:sender animated:YES];
    }
}


-(UIView *)topView {
    
    if (_topView == nil) {
        
        CGFloat viewWidth = self.view.bounds.size.width;
        CGFloat baseHeight =  IsIPad ? 180 : 160;
        
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, baseHeight)];
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

@end