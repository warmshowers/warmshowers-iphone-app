//
//  FavouriteHostTableViewController.m
//  WS
//
//  Created by Christopher Meyer on 11/16/11.
//  Copyright (c) 2011 Red House Consulting GmbH. All rights reserved.
//

#import "FavouriteHostTableViewController.h"
#import "WSAppDelegate.h"
#import "Host.h"

@implementation FavouriteHostTableViewController

-(id)initWithStyle:(UITableViewStyle)style {
	if (self=[super initWithStyle:style]) {
        self.title = @"Favourites";
    }
 
	return self;
}

-(void)updateDistances {
	CLLocation *current_location = [[WSAppDelegate sharedInstance] userLocation];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSArray *hosts = [Host fetchWithPredicate:[NSPredicate predicateWithFormat:@"favourite=1 AND notcurrentlyavailable != 1"]];
		
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
		NSEntityDescription *entity = [Host entityDescription];
		[fetchRequest setEntity:entity];
		
		// [fetchRequest setFetchBatchSize:20];		
		// [fetchRequest setFetchLimit:50];
		
		// Edit the sort key as appropriate.
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[fetchRequest setSortDescriptors:sortDescriptors];
		
		NSPredicate *predicate;
		if (self.searchString) {
			//NSPredicate *_myPredicate = [NSPredicate predicateWithFormat:@"(firstname CONTAINS[cd] %@) OR (lastname CONTAINS[cd] %@)", _mySearchKey, _mySearchKey];
			predicate = [NSPredicate predicateWithFormat:@"(notcurrentlyavailable != 1) AND (distance != nil AND favourite=1) AND (comments CONTAINS[cd] %@ OR name CONTAINS[cd] %@ OR fullname CONTAINS[cd] %@ OR city CONTAINS[cd] %@)", self.searchString, self.searchString, self.searchString, self.searchString];
		} else {
			predicate = [NSPredicate predicateWithFormat:@"notcurrentlyavailable != 1 AND distance != nil AND favourite=1"];
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


@end
