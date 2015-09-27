//
//  HostsTableViewController.m
//  WS
//
//  Created by Christopher Meyer on 31/05/15.
//  Copyright (c) 2015 Red House Consulting GmbH. All rights reserved.
//

#import "HostsTableViewController.h"
#import "Host.h"
#import "HostInfoViewController.h"

@interface HostsTableViewController ()
@property (strong, nonatomic) NSPredicate *searchPredicate;
@end

static NSString *CellIdentifier = @"2dcc246d-59aa-497c-b2d8-438b2eee35d5";

@implementation HostsTableViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[RHTableViewCellStyleSubtitleLighterDetail class] forCellReuseIdentifier:CellIdentifier];
    
    self.searchPredicate = [NSPredicate predicateWithFormat:@"comments CONTAINS[cd] %@ OR name CONTAINS[cd] %@ OR fullname CONTAINS[cd] %@ OR city CONTAINS[cd] %@", self.searchString, self.searchString, self.searchString, self.searchString];
    
    [self.tableView setEstimatedRowHeight:44.0f];
    [self.tableView setRowHeight:UITableViewAutomaticDimension];
     [self setEnableSectionIndex:YES];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setFetchedResultsController:nil];
    [self.tableView reloadData];
}

-(NSArray *)sortDescriptors {
    return @[[NSSortDescriptor sortDescriptorWithKey:@"fullname" ascending:YES]];
}

-(NSPredicate *)predicate {
    if (self.searchString) {
        NSMutableArray *predicates = [NSMutableArray arrayWithObject:self.basePredicate];
        
        for (NSString *term in [self.searchString whitespaceTokenize]) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"comments CONTAINS[cd] %@ OR name CONTAINS[cd] %@ OR fullname CONTAINS[cd] %@ OR city CONTAINS[cd] %@ OR province CONTAINS[cd] %@", term, term, term, term, term];
            [predicates addObject:predicate];
        }
        
        return [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    } else {
        return self.basePredicate;
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
                                                                              sectionNameKeyPath:@"fullname.firstLetter"
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
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell.imageView setImageWithURL:[NSURL URLWithString:host.imageThumbURL] placeholderImage:[UIImage imageNamed:@"ws-40"]];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HostInfoViewController *controller = [HostInfoViewController new];
    controller.host = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (self.splitViewController) {
        [self.splitViewController showDetailViewController:controller.wrapInNavigationController sender:nil];
    } else {
        [self.navigationController pushViewController:controller animated:YES];
    }
}


@end
