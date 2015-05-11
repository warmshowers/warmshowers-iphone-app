//
//  LeftMenuViewController.h
//  WS
//
//  Created by Christopher Meyer on 08/05/15.
//  Copyright (c) 2015 Red House Consulting GmbH. All rights reserved.
//

#import "HostMapViewController.h"

@interface LeftMenuViewController : UIViewController<UISplitViewControllerDelegate>

@property (nonatomic, strong) HostMapViewController *hostMapViewController;

@end