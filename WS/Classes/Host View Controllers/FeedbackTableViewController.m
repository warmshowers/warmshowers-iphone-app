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

#import "WSAppDelegate.h"
#import "FeedbackTableViewController.h"
#import "Feedback.h"
#import "WSRequests.h"

static NSString *const CellIdentifier = @"1c8416b1-fe7d-4fbb-af58-d18b8efca04d";

@interface FeedbackTableViewController ()
@end

@implementation FeedbackTableViewController

-(void)viewDidLoad  {
	[super viewDidLoad];
	[self setTitle:NSLocalizedString(@"Feedback", nil)];
    [self.tableView registerNib:[UINib nibWithNibName:@"RHSingleLabelTableViewCell" bundle:[NSBundle bundleForClass:[RHTableViewCell class]]] forCellReuseIdentifier:CellIdentifier];
    [self.tableView setRowHeight:UITableViewAutomaticDimension];
    [self.tableView setEstimatedRowHeight:44];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
//	[self.navigationController setToolbarHidden:YES animated:YES];
    
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        // NSLog(@"%@", @"no");
    }
    
}

-(NSArray *)sortDescriptors {
    return @[[NSSortDescriptor sortDescriptorWithKey:@"nid" ascending:NO]];
}

-(NSPredicate *)predicate {
    return [NSPredicate predicateWithFormat:@"host=%@", self.host];
}

-(NSFetchedResultsController *)fetchedResultsController {
    if (fetchedResultsController == nil) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        [fetchRequest setEntity:[Feedback entityDescription]];
        [fetchRequest setSortDescriptors:[self sortDescriptors]];
        [fetchRequest setPredicate:[self predicate]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                            managedObjectContext:[Feedback managedObjectContextForCurrentThread]
                                                                              sectionNameKeyPath:@"nid"
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
    Feedback *rec = [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.section];
    RHTableViewCell *mcell = (RHTableViewCell *)cell;
    [mcell.largeLabel setText:rec.body];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    Feedback *feedback = [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.section];
    return [NSString stringWithFormat:@"%@ / %@ / %@ (%@)", feedback.fullname, feedback.ratingValue, [feedback.date formatWithLocalTimeZoneWithoutTime], feedback.hostOrGuest];
}

@end