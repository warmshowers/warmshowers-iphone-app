//
//  HostInfoViewController.h
//  WS
//
//  Created by Christopher Meyer on 10/17/10.
//  Copyright 2010 Red House Consulting GmbH. All rights reserved.
//

#import "RHActionSheet.h"
@class Host;

@interface HostInfoViewController : UITableViewController

@property (nonatomic, strong) Host *host;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, assign, getter = isShowingLoadingIndicator) BOOL showingLoadingIndicator;
@property (nonatomic, strong) UIView *topView;

@property (strong, nonatomic) IBOutlet UIImageView *headerImageView;
@property (strong, nonatomic) IBOutlet UILabel *headerNameLabel;

-(void)refreshHost;
-(void)setLastUpdatedDate;

-(void)showActions:(id)sender;
-(void)refreshTableView:(BOOL)show;

@end