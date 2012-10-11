//
//  HostInfoTableViewController.h
//  WS
//
//  Created by Christopher Meyer on 10/17/10.
//  Copyright 2010 Red House Consulting GmbH. All rights reserved.
//

#import "RHActionSheet.h"
@class Host, DynamicHeightTextTableViewCell, AFJSONRequestOperation;

@interface HostInfoViewController : UITableViewController

@property (nonatomic, retain) Host *host;
@property (nonatomic, retain) UILabel *statusLabel;
@property (nonatomic, assign, getter = isShowingLoadingIndicator) BOOL showingLoadingIndicator;
@property (nonatomic, retain) RHActionSheet *popoverActionsheet;

-(void)refreshHost;
-(void)setLastUpdatedDate;

-(void)showActions:(id)sender;
-(void)refreshTableView:(BOOL)show;

@end