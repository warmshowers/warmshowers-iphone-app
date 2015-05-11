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
                
                Thread *thread = [Thread newOrExistingEntityWithPredicate:[NSPredicate predicateWithFormat:@"threadid=%d", [threadid intValue]]];
                
                [thread setThreadid:threadid];
                [thread setSubject:subject];
                
                [thread setParticipants:nil];
                
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
    
    [(RHRefreshControl *)self.refreshControl refresh];
}


-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Thread *thread = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell.textLabel setText:thread.subject];
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