//
//  Copyright (C) 2015 Warm Showers Foundation
//  http://warmshowers.org/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "SearchHostsTableViewController.h"
#import "Host.h"
#import "HostInfoViewController.h"
#import "WSAppDelegate.h"
#import "WSRequests.h"

static NSString *CellIdentifier = @"2dcc246d-59aa-497c-b2d8-438b2eee35d5";

@implementation SearchHostsTableViewController

#pragma mark - View lifecycle
-(void)viewDidLoad {
	[super viewDidLoad];
    [self setTitle:NSLocalizedString(@"Search", nil)];
    [self addSearchBarWithPlaceHolder:NSLocalizedString(@"Search", nil)];
    
    [self.tableView registerClass:[RHTableViewCellStyleSubtitleLighterDetail class] forCellReuseIdentifier:CellIdentifier];
    
    [self.tableView setEstimatedRowHeight:44.0f];
    [self.tableView setRowHeight:UITableViewAutomaticDimension];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
    [self setFetchedResultsController:nil];
    [self.tableView reloadData];
  //   [self updateDistances];

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

    if ([searchString length] >= 3) {
        [WSRequests searchHostsWithKeyword:searchString];
    }
}

/*
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
*/

-(NSPredicate *)predicate {
    if (self.searchString) {
        
        NSMutableArray *predicates = [NSMutableArray arrayWithObject:[NSPredicate predicateWithFormat:@"(notcurrentlyavailable != 1)"]];
        
        for (NSString *term in [self.searchString whitespaceTokenize]) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"comments CONTAINS[cd] %@ OR name CONTAINS[cd] %@ OR fullname CONTAINS[cd] %@ OR city CONTAINS[cd] %@ OR province CONTAINS[cd] %@", term, term, term, term, term];
            [predicates addObject:predicate];
        }

        return [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    } else {
        return [NSPredicate predicateWithFormat:@"notcurrentlyavailable != 1"];
    }
}


-(NSArray *)sortDescriptors {
    
    return @[[NSSortDescriptor sortDescriptorWithKey:@"fullname" ascending:YES]];
    
    /*
    if (self.searchString) {
        return @[[NSSortDescriptor sortDescriptorWithKey:@"fullname" ascending:YES]];
    } else {
        return @[[NSSortDescriptor sortDescriptorWithKey:@"fullname" ascending:YES]];
    }
     */
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
    [cell.imageView setImageWithURL:[NSURL URLWithString:host.imageURL] placeholderImage:[UIImage imageNamed:@"ws"]];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	[self configureCell:cell atIndexPath:indexPath];
	
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HostInfoViewController *controller = [HostInfoViewController new];
	controller.host = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[self.navigationController pushViewController:controller animated:YES];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 54;
}

@end