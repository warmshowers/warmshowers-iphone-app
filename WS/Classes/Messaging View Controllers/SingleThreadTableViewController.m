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

#import "SingleThreadTableViewController.h"
#import "Host.h"
#import "Message.h"
#import "ComposeMessageViewController.h"
#import "WSRequests.h"

static NSString *CellIdentifier = @"d8bd8a42-1303-444b-b1f0-aca389ee9cd7";

@interface SingleThreadTableViewController ()

@end

@implementation SingleThreadTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:self.thread.subject];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"RHSingleLabelTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    
    [self.tableView setRowHeight:UITableViewAutomaticDimension];
    [self.tableView setEstimatedRowHeight:44.0f];
    
    __weak SingleThreadTableViewController *bself = self;
    
    self.navigationItem.rightBarButtonItem = [[RHBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply block:^{
        ComposeMessageViewController *controller = [ComposeMessageViewController controllerWithThread:bself.thread];
        UINavigationController *navController = [controller wrapInNavigationControllerWithPresentationStyle:UIModalPresentationPageSheet];
        [bself presentViewController:navController animated:YES completion:nil];
    }];
}

-(void)viewWillAppear:(BOOL)animated {
     [self.thread refreshMessages];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.thread.is_newValue > 0) {
        // update the read status on the server
        [WSRequests markThreadAsRead:self.thread];
    
        // regardless of how that goes, locally change this
        // [self.thread setIs_newValue:@0];
        self.thread.is_newValue = 0;
        [MessageThread commit];
    }
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    RHTableViewCell *mcell = (RHTableViewCell *)cell;
    [mcell.largeLabel setText:message.body.stripHTML.trim];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

-(NSPredicate *)predicate {
    return [NSPredicate predicateWithFormat:@"thread = %@", self.thread];
}

-(NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController == nil) {
        NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
        
        NSPredicate *predicate = [self predicate];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[Message entityDescription]];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sort1, nil]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                            managedObjectContext:[Message managedObjectContextForCurrentThread]
                                                                              sectionNameKeyPath:@"timestamp"
                                                                                       cacheName:nil];
        
        fetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![fetchedResultsController performFetch:&error]) {
            NSLog(@"Unresolved error: %@", [error localizedDescription]);
        }
        
    }
    
    return fetchedResultsController;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    Message *msg = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return [NSString stringWithFormat:@"%@: %@ / %@", NSLocalizedString(@"From", nil), msg.author.title, [msg.timestamp formatWithLocalTimeZone]];
}

@end