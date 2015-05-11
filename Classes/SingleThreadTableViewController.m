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
    
    [self.tableView registerClass:[RHTableViewCellStyleSubtitleLighterDetail class] forCellReuseIdentifier:CellIdentifier];
    
    
    __weak Thread *wThread = self.thread;
    
    self.refreshControl = [RHRefreshControl refreshControlWithBlock:^(RHRefreshControl *refreshControl) {
        NSString *path = @"/services/rest/message/getThread";
        NSDictionary *parameters =  @{
                                      @"thread_id": [self.thread.threadid stringValue],
                                      };
        
        [[WSHTTPClient sharedHTTPClient] POST:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            
            Thread *bThread = [wThread objectInCurrentThreadContextWithError:nil];
            
            NSArray *msgs = [responseObject objectForKey:@"messages"];
            
            NSArray *all_msgids = [msgs pluck:@"mid"];
            
            [Message deleteWithPredicate:[NSPredicate predicateWithFormat:@"thread = %@ AND NOT (mid IN %@)", bThread, all_msgids]];
            
            
            for (NSDictionary *dict in msgs) {
                
                NSNumber *mid = @([[dict objectForKey:@"mid"] intValue]);
                NSString *body = [dict objectForKey:@"body"];
                
                NSDictionary *author = [dict objectForKey:@"author"];
                NSNumber *uid = @([[author objectForKey:@"uid"] intValue]);
                NSString *name = [author objectForKey:@"name"];
                
                Message *message = [Message newOrExistingEntityWithPredicate:[NSPredicate predicateWithFormat:@"mid=%d", [mid intValue]]];
                [message setMid:mid];
                [message setBody:body];
                [message setThread:bThread];
                
                Host *host = [Host hostWithID:uid];
                [host setName:name];
                [host setHostid:uid];
                
                [message setAuthor:host];
            }
            
            [Message commit];
            
            [refreshControl endRefreshing];
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [refreshControl endRefreshing];
        }];
    }];
    
    [(RHRefreshControl *)self.refreshControl refresh];
}


-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell.textLabel setText:message.body];
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
        NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"body" ascending:YES];
        
        NSPredicate *predicate = [self predicate];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[Message entityDescription]];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sort1, nil]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                            managedObjectContext:[Message managedObjectContextForCurrentThread]
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