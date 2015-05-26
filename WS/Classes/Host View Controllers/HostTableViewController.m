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
#import "WSRequests.h"

static NSString *CellIdentifier = @"2dcc246d-59aa-497c-b2d8-438b2eee35d5";

@implementation HostTableViewController

#pragma mark - View lifecycle
-(void)viewDidLoad {
	[super viewDidLoad];
    [self setTitle:NSLocalizedString(@"Search", nil)];
    [self addSearchBarWithPlaceHolder:NSLocalizedString(@"Search", nil)];
    
    [self.tableView registerClass:[RHTableViewCellStyleSubtitleLighterDetail class] forCellReuseIdentifier:CellIdentifier];
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

/*
-(void)helpButtonPressed:(id)sender {
	[[RHAlertView alertWithOKButtonWithTitle:NSLocalizedString(@"Help", nil) message:NSLocalizedString(@"Hosts are sorted by proximity to your location.\n\nA green dot indicates a host is marked as a favourite.  A purple dot indicates the host details are cached and can be accessed offline.  A red dot indicates the host is not cached.", nil)] show];
}
*/


-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [super updateSearchResultsForSearchController:searchController];
    
    NSString *searchString = searchController.searchBar.text;
    [WSRequests searchHostsWithKeyword:searchString];
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


-(NSPredicate *)predicate {
    if (self.searchString) {
        
        NSMutableArray *predicates = [NSMutableArray arrayWithObject:[NSPredicate predicateWithFormat:@"(notcurrentlyavailable != 1)"]];
        
        for (NSString *term in [self.searchString whitespaceTokenize]) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"comments CONTAINS[cd] %@ OR name CONTAINS[cd] %@ OR fullname CONTAINS[cd] %@ OR city CONTAINS[cd] %@ OR province CONTAINS[cd] %@", term, term, term, term, term];
            [predicates addObject:predicate];
        }

        return [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    } else {
        return [NSPredicate predicateWithFormat:@"notcurrentlyavailable != 1 AND distance != nil"];
    }
}


-(NSArray *)sortDescriptors {
    if (self.searchString) {
        return @[[NSSortDescriptor sortDescriptorWithKey:@"fullname" ascending:YES]];
    } else {
        return @[[NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES]];
    }
}


-(NSFetchedResultsController *)fetchedResultsController {
    if (fetchedResultsController == nil) {
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		
		[fetchRequest setEntity:[Host entityDescription]];
		[fetchRequest setSortDescriptors:[self sortDescriptors]];
		[fetchRequest setPredicate:[self predicate]];
		
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
    Host *host = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.textLabel.text= [host title];
	cell.detailTextLabel.text = [host subtitle];
	
	/*
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
     */
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:host.imageURL] placeholderImage:[UIImage imageNamed:@"ws"]];
	
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
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