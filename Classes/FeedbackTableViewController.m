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


-(void)viewDidLoad  {
	[super viewDidLoad];
	[self setTitle:@"Feedback"];
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
			[cell.textLabel setText:NSLocalizedString(@"From", nil)];
			[cell.detailTextLabel setText:rec.fullname];
			break;
		case 1:
			[cell.textLabel setText:NSLocalizedString(@"Comments", nil)];
			[cell.detailTextLabel setText:rec.body];
			break;
		case 2:
			[cell.textLabel setText:NSLocalizedString(@"Date", nil)];
			[cell.detailTextLabel setText:[rec.date formatWithUTCTimeZone]];
			break;
	}
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
		[cell.detailTextLabel setFont:[UIFont systemFontOfSize:13]];
		[cell.detailTextLabel setNumberOfLines:0];
		[cell.detailTextLabel setLineBreakMode:NSLineBreakByWordWrapping];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	}
	
	[self configureCell:cell atIndexPath:indexPath];
	
	return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];	
	UILineBreakMode lineBreakMode = cell.detailTextLabel.lineBreakMode;
	
	if (lineBreakMode == NSLineBreakByWordWrapping) {

		NSString *text = cell.detailTextLabel.text;
		UIFont *font   = cell.detailTextLabel.font;

		// 20 is the left and right margins
		// 111 is trial-and-error with iOS7
		CGFloat detailLabelWidth = tableView.width - 20 - 110;

		CGSize withinSize = CGSizeMake(detailLabelWidth, MAXFLOAT);

		CGRect textRect = [text boundingRectWithSize:withinSize
											 options:NSStringDrawingUsesLineFragmentOrigin
										  attributes:@{NSFontAttributeName:font}
											 context:nil];

		CGSize size = textRect.size;

		return MAX(kRHDefaultCellHeight, size.height + kRHTopBottomMargin*2);

	}
	
	return kRHDefaultCellHeight;
}

@end
