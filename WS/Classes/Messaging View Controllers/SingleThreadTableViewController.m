//
//  SingleThreadTableViewController.m
//  WS
//
//  Created by Christopher Meyer on 10/05/15.
//  Copyright (c) 2015 Red House Consulting GmbH. All rights reserved.
//

#import "SingleThreadTableViewController.h"
#import "Host.h"
#import "Message.h"

static NSString *CellIdentifier = @"SingleThreadTableCell";

@interface SingleThreadTableViewController ()

@end

@implementation SingleThreadTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:self.thread.subject];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"RHLabelTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    
    [self.tableView setRowHeight:UITableViewAutomaticDimension];
    [self.tableView setEstimatedRowHeight:44];
    
    [self.thread refresh];
    
}





-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    RHLabelTableViewCell *mcell = (RHLabelTableViewCell *)cell;

   // [mcell.bodyLabel setText:[message.body stripHTML]];
   // [mcell.fromLabel setText:message.author.title];
   // [mcell.dateLabel setText:[message.timestamp formatWithLocalTimeZone]];
    [mcell.label setText:[message.body stripHTML]];
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