//
//  MBBookmarksListViewControllerTableViewController.m
//  MapBookmarksApp
//
//  Created by Admin on 11.12.15.
//  Copyright © 2015 Admin. All rights reserved.
//

#import "MBBookmarksListViewController.h"
#import "MBMainViewController.h"
#import "Bookmark+CoreDataProperties.h"
#import "MBAlertViewHelper.h"
#import "MBBookmarkDetailsViewController.h"

static NSString * const kFromListToDetailsSegueId = @"FromLIstToDetailsSegue";

@interface MBBookmarksListViewController ()

- (UIViewController *)getPreviousViewController;
- (void)saveManagedContex;
- (void)setSharedTableView:(UITableView *)tableView;

@end

@implementation MBBookmarksListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setSharedTableView:self.tableView];
     self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

- (UIViewController *)getPreviousViewController {
    NSUInteger numberOfControlles = [[self.navigationController viewControllers]count];
    
    if(numberOfControlles < 2){
        return nil;
    } else {
        return [[self.navigationController viewControllers]objectAtIndex:numberOfControlles - 2];
    }
}

- (void)saveManagedContex {
    NSError *error = nil;
    if ([self.managedObjectContex hasChanges] && ![self.managedObjectContex save:&error]) {
        // Handle the error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        [MBAlertViewHelper showAlertFromViewController:self withError:error];
    }
}

- (void)setSharedTableView:(UITableView *)tableView {
    
    MBMainViewController *mainViewController = (MBMainViewController *)[self getPreviousViewController];
    if(mainViewController != nil) {
        mainViewController.sharedTableView = tableView;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return [[self.fetchedResultsController sections]count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [[[self.fetchedResultsController sections]objectAtIndex:section]numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MBBookmarksListCell" forIndexPath:indexPath];
    
    Bookmark *currentBookmark = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = currentBookmark.title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Bookmark *bookmark = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.managedObjectContex deleteObject:bookmark];
        [self saveManagedContex];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier]isEqualToString:kFromListToDetailsSegueId] == YES) {
        
        MBBookmarkDetailsViewController *destinationController = [segue destinationViewController];
        destinationController.managedObjectContex = self.managedObjectContex;
        destinationController.fetchedResultsController = self.fetchedResultsController;
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        destinationController.chosenBookmark = [self.fetchedResultsController objectAtIndexPath:indexPath];
        destinationController.currentIndexPath = indexPath;
    }
}


@end
