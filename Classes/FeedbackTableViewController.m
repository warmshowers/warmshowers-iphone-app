//
//  FeedbackTableViewController.m
//  WS
//
//  Created by Christopher Meyer on 9/19/12.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.
//

#import "WSAppDelegate.h"
#import "Host.h"
#import "FeedbackTableViewController.h"
#import "Feedback.h"

@interface FeedbackTableViewController ()

@end

@implementation FeedbackTableViewController
@synthesize host;

/*
 -(void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 [self.navigationController setToolbarHidden:YES animated:animated];
 }
 */


-(void)viewDidLoad  {
	[super viewDidLoad];
	[self setTitle:@"Feedback"];
	/*
     UIBarButtonItem *recommendButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add Feedback", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(showAddWaypointModal:)];
     [recommendButton setWidth:200];
     
     NSArray *toolbarItems = [NSArray arrayWithObjects:
     [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
     recommendButton,
     [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
     nil];
     
     [toolbarItems makeObjectsPerformSelector:@selector(release)];
     [self setToolbarItems:toolbarItems animated:YES];
     */
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
		// [fetchedResultsController setDelegate:self];
		
		
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
    
    Feedback *rec = [[self.fetchedResultsController fetchedObjects] objectAtIndex:section];
    NSDate *ninetyseventy = [NSDate dateWithTimeIntervalSince1970:0];
    
    if ([rec.date isEqualToDate:ninetyseventy]) {
        return 2;
    } else {
        return 3;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"";
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	Feedback *rec = [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.section];
	
	switch (indexPath.row) {
		case 0:
			[cell.textLabel setText:@"From"];
			[cell.detailTextLabel setText:rec.fullname];
			break;
		case 1:
			[cell.textLabel setText:@"Comments"];
			[cell.detailTextLabel setText:rec.body];
			break;
		case 2:
			[cell.textLabel setText:@"Date"];
			NSDateFormatter *df = [[NSDateFormatter alloc] init];
			[df setDateStyle:NSDateFormatterMediumStyle];
			[df setTimeStyle:NSDateFormatterNoStyle];
			[cell.detailTextLabel setText:[df stringFromDate:rec.date]];
			break;
	}
}

-(UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
		[cell.detailTextLabel setFont:[UIFont systemFontOfSize:13]];
		[cell.detailTextLabel setNumberOfLines:0];
		[cell.detailTextLabel setLineBreakMode:UILineBreakModeWordWrap];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	}
	
	[self configureCell:cell atIndexPath:indexPath];
	
	return cell;
}


-(CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *_cell = [self tableView:_tableView cellForRowAtIndexPath:indexPath];
	
	UILineBreakMode lineBreakMode = _cell.detailTextLabel.lineBreakMode;
	
	if (lineBreakMode == UILineBreakModeWordWrap) {
		NSString *text = _cell.detailTextLabel.text;
		UIFont *font = _cell.detailTextLabel.font;
		
		CGRect table_frame = self.tableView.frame;
		float margin = IsIPad ? 183 : 113;
		CGSize withinSize = CGSizeMake(table_frame.size.width-margin, MAXFLOAT);
		CGSize size = [text sizeWithFont:font constrainedToSize:withinSize lineBreakMode:lineBreakMode];
		
		return MAX(44, size.height + 22);
	}
	
	return 44;
}






@end
