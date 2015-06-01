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
#import "WSRequests.h"

@implementation SearchHostsTableViewController

#pragma mark - View lifecycle
-(void)viewDidLoad {
	[super viewDidLoad];
    [self setTitle:NSLocalizedString(@"Search", nil)];
    
    [self setBasePredicate:[NSPredicate predicateWithFormat:@"notcurrentlyavailable != 1"]];
    [self addSearchBarWithPlaceHolder:NSLocalizedString(@"Search", nil)];
}

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

@end