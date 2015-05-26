//
//  FeedbackTableViewController.m
//  WS
//
//  Created by Christopher Meyer on 9/19/12.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.
//

#import "WSAppDelegate.h"
#import "FeedbackTableViewController.h"
#import "Feedback.h"

static NSString *CellIdentifier = @"1c8416b1-fe7d-4fbb-af58-d18b8efca04d";

@interface FeedbackTableViewController ()
@end

@implementation FeedbackTableViewController

-(void)viewDidLoad  {
	[super viewDidLoad];
	[self setTitle:NSLocalizedString(@"Feedback", nil)];
    [self.tableView registerNib:[UINib nibWithNibName:@"RHLabelTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    [self.tableView setRowHeight:UITableViewAutomaticDimension];
    [self.tableView setEstimatedRowHeight:44];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.navigationController setToolbarHidden:YES animated:YES];
}

-(NSFetchedResultsController *)fetchedResultsController {
    if (fetchedResultsController == nil) {
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		
		[fetchRequest setEntity:[Feedback entityDescription]];
		
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[fetchRequest setSortDescriptors:sortDescriptors];
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"host=%@", self.host];
		[fetchRequest setPredicate:predicate];
		
		self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																			managedObjectContext:[Feedback managedObjectContextForCurrentThread]
																			  sectionNameKeyPath:nil
																					   cacheName:nil];
		
		NSError *error = nil;
		if (![fetchedResultsController performFetch:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		}
    }
	
    return fetchedResultsController;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController fetchedObjects] count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Feedback *rec = [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.section];
    RHLabelTableViewCell *mcell = (RHLabelTableViewCell *)cell;
    [mcell.label setText:rec.body];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    Feedback *feedback = [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.section];
    return [NSString stringWithFormat:@"%@ / %@ (%@)", feedback.fullname, [feedback.date formatWithLocalTimeZoneWithoutTime], feedback.hostOrGuest];
}

@end