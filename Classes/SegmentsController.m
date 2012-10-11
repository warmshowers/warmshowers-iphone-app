//
//  SegmentManager.m
//  NavBasedSeg
//
//  Created by Marcus Crafter on 25/06/10.
//  Copyright 2010 Red Artisan. All rights reserved.
//

#import "SegmentsController.h"
#import "NSArray+PerformSelector.h"

@interface SegmentsController ()
@property (nonatomic, retain, readwrite) NSArray *viewControllers;
@property (nonatomic, retain, readwrite) UINavigationController *navigationController;
@end

@implementation SegmentsController
@synthesize viewControllers;
@synthesize navigationController;

-(id)initWithNavigationController:(UINavigationController *)_navigationController viewControllers:(NSArray *)_viewControllers {
    if (self = [super init]) {
        self.navigationController   = _navigationController;
        self.viewControllers = _viewControllers;

		UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[self.viewControllers arrayByPerformingSelector:@selector(title)]];
		[segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];

		for (int i=0; i < segmentedControl.numberOfSegments; i++) {
			[segmentedControl setWidth:80.0 forSegmentAtIndex:i];
		}	
				
		[segmentedControl addTarget:self action:@selector(indexDidChangeForSegmentedControl:) forControlEvents:UIControlEventValueChanged];		
		
		segmentedControl.selectedSegmentIndex = 0;
		[self indexDidChangeForSegmentedControl:segmentedControl];

		[segmentedControl release];		
    }
    return self;
}

-(void)indexDidChangeForSegmentedControl:(UISegmentedControl *)_segmentedControl {
    NSUInteger index = _segmentedControl.selectedSegmentIndex;
    UIViewController * incomingViewController = [self.viewControllers objectAtIndex:index];
    
    NSArray * theViewControllers = [NSArray arrayWithObject:incomingViewController];
    [self.navigationController setViewControllers:theViewControllers animated:NO];
    
    incomingViewController.navigationItem.titleView = _segmentedControl;
}

-(void)dealloc {
    [super dealloc];
    self.viewControllers = nil;
    self.navigationController = nil;
}

@end