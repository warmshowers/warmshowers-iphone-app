//
//  FeedbackTableViewController.h
//  WS
//
//  Created by Christopher Meyer on 9/19/12.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.
//

#import "RHCoreDataTableViewController.h"

@class Host;

@interface FeedbackTableViewController : RHCoreDataTableViewController

@property (nonatomic, strong) Host *host;

@end
