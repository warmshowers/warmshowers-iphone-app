//
//  SingleThreadTableViewController.h
//  WS
//
//  Created by Christopher Meyer on 10/05/15.
//  Copyright (c) 2015 Red House Consulting GmbH. All rights reserved.
//

#import "RHCoreDataTableViewController.h"
#import "Thread.h"

@interface SingleThreadTableViewController : RHCoreDataTableViewController

@property (nonatomic, strong) Thread *thread;

@end