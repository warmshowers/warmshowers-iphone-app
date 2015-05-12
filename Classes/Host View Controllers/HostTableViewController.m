//
//  HostTableViewController.m
//  WS
//
//  Created by Christopher Meyer on 10/26/11.
//  Copyright (c) 2011 Red House Consulting GmbH. All rights reserved.
//

#import "HostTableViewController.h"
#import "Host.h"
#import "HostInfoViewController.h"
#import "WSAppDelegate.h"

@implementation HostTableViewController

#pragma mark - View lifecycle
-(id)initWithStyle:(UITableViewStyle)style {
	if (self=[super initWithStyle:style]) {
		self.title = NSLocalizedString(@"List", nil);
	}
	
	return self;
}

-(void)viewDidLoad {
	[super viewDidLoad];
	
	UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Help", nil) style:UIBarButtonItemStylePlain target:self action:@selector(helpButtonPressed:)];
	
	NSArray *toolbarItems = [NSArray arrayWithObjects:
							 // searchButton,
							 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
							 helpButton,
							 nil];
	
    
	[self setToolbarItems:toolbarItems animated:YES];
    
    [self addSearchBarWithPlaceHolder:NSLocalizedString(@"Filter Cached Hosts", nil)];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
    [self setFetchedResultsController:nil];
    [self.tableView reloadData];
    [self updateDistances];

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	self.navigationItem.hidesBackButton = YES;
}

-(void)helpButtonPressed:(id)sender {
	[[RHAlertView alertWithOKButtonWithTitle:NSLocalizedString(@"Help", nil) message:NSLocalizedString(@"Hosts are sorted by proximity to your location.\n\nA green dot indicates a host is marked as a favourite.  A purple dot indicates the host details are cached and can be accessed offline.  A red dot indicates the host is not cached.", nil)] show];
}


-(void)updateDistances {
	CLLocation *current_location = [[WSAppDelegate sharedInstance] userLocation];
    
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		// Merge the closests 50 and what the system thinks is currently the closest 50
		NSArray *hosts1 = [Host hostsClosestToLocation:current_location withLimit:100];
		NSArray *hosts2 = [Host fetchWithPredicate:[NSPredicate predicateWithFormat:@"distance != nil AND notcurrentlyavailable != 1"] sortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES] withLimit:100];
		
		NSMutableArray *hosts = [NSMutableArray arrayWithArray:hosts1];
        [hosts addObjectsFromArray:hosts2];
		
		for (Host *host in hosts) {
			[host updateDistanceFromLocation:current_location];
		}
		
		[Host commit];
	});
}


-(NSFetchedResultsController *)fetchedResultsController {
    if (fetchedResultsController == nil) {
		// Create the fetch request for the entity.
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		
		// Edit the entity name as appropriate.
		[fetchRequest setEntity:[Host entityDescription]];
		
		// [fetchRequest setFetchBatchSize:25];
		// [fetchRequest setFetchLimit:50];
		
		// Edit the sort key as appropriate.
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[fetchRequest setSortDescriptors:sortDescriptors];
        
		NSPredicate *predicate;
        
		if (self.searchString) {
			              predicate = [NSPredicate predicateWithFormat:@"(notcurrentlyavailable != 1) AND (comments CONTAINS[cd] %@ OR name CONTAINS[cd] %@ OR fullname CONTAINS[cd] %@ OR city CONTAINS[cd] %@ OR province CONTAINS[cd] %@)", self.searchString, self.searchString, self.searchString, self.searchString, self.searchString];
            
		} else {
			predicate = [NSPredicate predicateWithFormat:@"notcurrentlyavailable != 1 AND distance != nil"];
		}
        
		[fetchRequest setPredicate:predicate];
		
		// Edit the section name key path and cache name if appropriate.
		// nil for section name key path means "no sections".
		self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																			managedObjectContext:[Host managedObjectContextForCurrentThread]
																			  sectionNameKeyPath:nil
																					   cacheName:nil];
		[fetchedResultsController setDelegate:self];
        
		
		NSError *error = nil;
		if (![fetchedResultsController performFetch:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		}
    }
	
    return fetchedResultsController;
}


-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Host *host = (Host *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.textLabel.text= [host title];
	cell.detailTextLabel.text = [host subtitle];
	
	switch ([host pinColour]) {
		case MKPinAnnotationColorRed:
			cell.imageView.image = [UIImage imageNamed:@"DotRed"];
			break;
		case MKPinAnnotationColorPurple:
			cell.imageView.image = [UIImage imageNamed:@"DotPurple"];
			break;
		case MKPinAnnotationColorGreen:
			cell.imageView.image = [UIImage imageNamed:@"DotGreen"];
			break;
		default:
			cell.imageView.image = nil;
			break;
	}
	
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell"; // NB: matches identifier in XIB
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	[self configureCell:cell atIndexPath:indexPath];
	
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	HostInfoViewController *controller = [[HostInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
	controller.host = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[self.navigationController pushViewController:controller animated:YES];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 54;
}

@end