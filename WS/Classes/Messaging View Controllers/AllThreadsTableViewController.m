//
//  InboxTableViewController.m
//  WS
//
//  Created by Christopher Meyer on 09/05/15.
//  Copyright (c) 2015 Red House Consulting GmbH. All rights reserved.
//

#import "AllThreadsTableViewController.h"
#import "Thread.h"
#import "Host.h"
#import "SingleThreadTableViewController.h"

static NSString *CellIdentifier = @"ThreadsTableCell";

@interface AllThreadsTableViewController ()

@end


@implementation AllThreadsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedString(@"Inbox", nil)];
    
    [self.tableView registerClass:[RHTableViewCellStyleSubtitleLighterDetail class] forCellReuseIdentifier:CellIdentifier];
    
    self.refreshControl = [RHRefreshControl refreshControlWithBlock:^(RHRefreshControl *refreshControl) {
        NSString *path = @"/services/rest/message/get";
        
        [[WSHTTPClient sharedHTTPClient] POST:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            
            NSArray *all_ids = [responseObject pluck:@"thread_id"];
            
            [Thread deleteWithPredicate:[NSPredicate predicateWithFormat:@"NOT (threadid IN %@)", all_ids]];
            
            for (NSDictionary *dict in responseObject) {
                
                NSNumber *threadid = @([[dict objectForKey:@"thread_id"] intValue]);
                NSString *subject = [dict objectForKey:@"subject"];
                NSArray *participants = [dict objectForKey:@"participants"];
                NSNumber *is_new= @([[dict objectForKey:@"is_new"] intValue]);
//                NSNumber *count = [NSNumber numberWithInt:0]; // @([[dict objectForKey:@"count"] intValue]);
                
                NSNumber *count = @([[dict objectForKey:@"count"] intValue]);
                
                
                Thread *thread = [Thread newOrExistingEntityWithPredicate:[NSPredicate predicateWithFormat:@"threadid=%d", [threadid intValue]]];
                
                [thread setThreadid:threadid];
                [thread setSubject:subject];
                [thread setIs_new:is_new];
                [thread setParticipants:nil];
                [thread setCount:count];
                
                for (NSDictionary *participant in participants) {
                    NSNumber *hostid = @([[participant objectForKey:@"uid"] intValue]);
                    NSString *name = [participant objectForKey:@"name"];
                    
                    Host *host = [Host hostWithID:hostid];
                    [host setName:name];
                    
                    [thread addParticipantsObject:host];
                }
            }
            
            [Thread commit];
            
            [refreshControl endRefreshing];
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [refreshControl endRefreshing];
        }];
    }];
    
    // refresh on load
    [(RHRefreshControl *)self.refreshControl refresh];
}


-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Thread *thread = [self.fetchedResultsController objectAtIndexPath:indexPath];

    NSString *title = [NSString stringWithFormat:@"%@ (%ld)", thread.subject, (long)[thread.count integerValue]];
    
    
    [cell.textLabel setText:title];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    NSArray *participants = [thread.participants allObjects];
    NSArray *names = [participants arrayByPerformingSelector:@selector(title)];
    
    [cell.detailTextLabel setText:[names componentsJoinedByString:@", "]];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        
    Thread *thread = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    SingleThreadTableViewController *controller = [[SingleThreadTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [controller setThread:thread];

    
    UISplitViewController *split = self.splitViewController;
    
    [split showDetailViewController:[controller wrapInNavigationController] sender:nil];
    
}


-(NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController == nil) {
        NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"threadid" ascending:NO];
        
        NSPredicate *predicate = nil;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[Thread entityDescription]];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sort1, nil]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                            managedObjectContext:[Thread managedObjectContextForCurrentThread]
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
        
        fetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![fetchedResultsController performFetch:&error]) {
            NSLog(@"Unresolved error: %@", [error localizedDescription]);
        }
        
    }
    
    return fetchedResultsController;
}

@end