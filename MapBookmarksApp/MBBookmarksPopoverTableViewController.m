//
//  MBBookmarksPopoverTableViewController.m
//  MapBookmarksApp
//
//  Created by Admin on 12.12.15.
//  Copyright © 2015 Admin. All rights reserved.
//

#import "MBBookmarksPopoverTableViewController.h"
#import "Bookmark+CoreDataProperties.h"
#import "MBMainViewController.h"

static NSString * const kToMapViewSegueID = @"ToMapViewSegue";

@interface MBBookmarksPopoverTableViewController ()

@end

@implementation MBBookmarksPopoverTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    NSString *segueId = [segue identifier];
    if([segueId isEqualToString:kToMapViewSegueID]) {
        MBMainViewController *mapViewController = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Bookmark *chosenEndPoint = [self.fetchedResultsController objectAtIndexPath:indexPath];
        mapViewController.routingEndPoint = chosenEndPoint;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return [[self.fetchedResultsController sections]count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [[[self.fetchedResultsController sections]objectAtIndex:section]numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MBBookmarksPopoverCell" forIndexPath:indexPath];
    
    Bookmark *currentBookmark = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = currentBookmark.title;
    
    return cell;
}

@end
