//
//  HostsTableViewController.h
//  WS
//
//  Created by Christopher Meyer on 31/05/15.
//  Copyright (c) 2015 Red House Consulting GmbH. All rights reserved.
//

#import "RHCoreDataTableViewController.h"

@interface HostsTableViewController : RHCoreDataTableViewController

@property (strong, nonatomic) NSPredicate *basePredicate;

@end
