//
//  LeftMenuViewController.m
//  WS
//
//  Created by Christopher Meyer on 08/05/15.
//  Copyright (c) 2015 Red House Consulting GmbH. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "UIViewController+ECSlidingViewController.h"

#import "HostTableViewController.h"
#import "FavouriteHostTableViewController.h"
#import "AllThreadsTableViewController.h"


@interface LeftMenuViewController ()
@property (nonatomic, strong) RHTableView *tableView;
-(RHBarButtonItem *)leftMenuButton;
@end

@implementation LeftMenuViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedString(@"Warmshowers", nil)];
    
    //   [self.tableView setDeselectRowAfterSelect:NO];
    
    [self.tableView addSectionWithSectionHeaderText:NSLocalizedString(@"Find Hosts", nil)];
    
    __weak LeftMenuViewController *bself = self;
    
    RHTableViewCell *cell = [RHTableViewCell cellWithLabelText:NSLocalizedString(@"Map", nil)
                                               detailLabelText:nil
                                                didSelectBlock:^{
                                                    UIViewController *controller = self.hostMapViewController;
                                                    
                                                    [bself.slidingViewController setTopViewController:[controller wrapInNavigationController]];
                                                    [bself.slidingViewController resetTopViewAnimated:YES];
                                                }
                                                         style:UITableViewCellStyleDefault
                                                         image:nil
                                                 accessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [self.tableView addCell:cell];
    
    cell = [RHTableViewCell cellWithLabelText:NSLocalizedString(@"List", nil)
                              detailLabelText:nil
                               didSelectBlock:^{
                                   UIViewController *controller = [[HostTableViewController alloc] initWithStyle:UITableViewStylePlain];
                                   
                                   [controller.navigationItem setLeftBarButtonItem:[self leftMenuButton]];
                                   
                                   [bself.slidingViewController setTopViewController:[controller wrapInNavigationController]];
                                   [bself.slidingViewController resetTopViewAnimated:YES];
                               }
                                        style:UITableViewCellStyleDefault
                                        image:nil
                                accessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [self.tableView addCell:cell];
    
    cell = [RHTableViewCell cellWithLabelText:NSLocalizedString(@"Favourites", nil)
                              detailLabelText:nil
                               didSelectBlock:^{
                                   
                                   UIViewController *controller = [[FavouriteHostTableViewController alloc] initWithStyle:UITableViewStylePlain];
                                   
                                   [controller.navigationItem setLeftBarButtonItem:[self leftMenuButton]];
                                   
                                   [bself.slidingViewController setTopViewController:[controller wrapInNavigationController]];
                                   [bself.slidingViewController resetTopViewAnimated:YES];
                               }
                                        style:UITableViewCellStyleDefault
                                        image:nil
                                accessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [self.tableView addCell:cell];
    
    
    
    
    [self.tableView addSectionWithSectionHeaderText:NSLocalizedString(@"Messages", nil)];
    
    cell = [RHTableViewCell cellWithLabelText:NSLocalizedString(@"Inbox", nil)
                              detailLabelText:nil
                               didSelectBlock:^{
                                   
                                   AllThreadsTableViewController *inboxTableViewController = [AllThreadsTableViewController new];
                                   inboxTableViewController.navigationItem.leftBarButtonItem = [self leftMenuButton];
                                   
                                   UISplitViewController *splitViewController = [UISplitViewController new];
                                   [splitViewController setViewControllers:@[[inboxTableViewController wrapInNavigationController], [UIViewController new]]];
                                   [splitViewController setPreferredDisplayMode:UISplitViewControllerDisplayModeAllVisible];
                                   [splitViewController setDelegate:self];
                                   [bself.slidingViewController setTopViewController:splitViewController];
                                   
                                   [bself.slidingViewController resetTopViewAnimated:YES];
                                   
                               }
                                        style:UITableViewCellStyleDefault
                                        image:nil
                                accessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [self.tableView addCell:cell];
    
    
    [self.tableView addSectionWithSectionHeaderText:nil];
    
    
    cell = [RHTableViewCell cellWithLabelText:NSLocalizedString(@"About", nil)
                              detailLabelText:nil
                               didSelectBlock:^{
                                   [bself.slidingViewController resetTopViewAnimated:YES];
                                   
                               }
                                        style:UITableViewCellStyleDefault
                                        image:nil
                                accessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    [self.tableView addCell:cell];
    
    
    
    cell = [RHTableViewCell cellWithLabelText:NSLocalizedString(@"Logout", nil)
                              detailLabelText:nil
                               didSelectBlock:^{
                                   [bself.slidingViewController resetTopViewAnimated:YES];
                                   
                               }
                                        style:UITableViewCellStyleDefault
                                        image:nil
                                accessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    [self.tableView addCell:cell];
    
}

-(RHTableView *)tableView {
    if (_tableView == nil) {
        self.tableView = [[RHTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    }
    
    return _tableView;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGestureTapping;
}


-(RHBarButtonItem *)leftMenuButton {
    return [RHBarButtonItem itemWithImage:[UIImage imageNamed:@"menu_black-48"] block:^{
        [self.slidingViewController resetTopViewAnimated:YES];
        [self.slidingViewController anchorTopViewToRightAnimated:YES];
    }];
}

-(void)loadView {
    self.tableView = [[RHTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.view = self.tableView;
}

-(HostMapViewController *)hostMapViewController {
    if (_hostMapViewController == nil) {
        self.hostMapViewController = [[HostMapViewController alloc] initWithNibName:@"HostMapViewController" bundle:nil];
        [_hostMapViewController.navigationItem setLeftBarButtonItem:[self leftMenuButton]];
    }
    
    return _hostMapViewController;
}



#pragma mark -
#pragma mark UISplitViewControllerDelegate
- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    
    if ([secondaryViewController isKindOfClass:[UIViewController class]]) {
        // If the detail controller doesn't have an item, display the primary view controller instead
        return YES;
    }
    
    return NO;
    
}




#pragma mark -

@end