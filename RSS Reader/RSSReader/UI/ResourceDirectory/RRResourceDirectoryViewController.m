//
//  RRResourceDirectoryViewController.m
//  RSSReader
//
//  Created by user on 30.05.17.
//  Copyright © 2017 Timofey Taran. All rights reserved.
//

#import "RRResourceDirectoryViewController.h"
#import "RRResourceTableViewCell.h"
#import "RRNewsViewController.h"
#import "RRAddResourceViewController.h"
#import "RRNewsManager.h"

@interface RRResourceDirectoryViewController () <UITableViewDelegate, UITableViewDataSource, RRAddResourceDelegate>
@property (weak, nonatomic) IBOutlet UITableView *resourceTableView;


@end

@implementation RRResourceDirectoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)];
    
    self.navigationItem.rightBarButtonItem = editButton;
    
    self.resourceTableView.contentInset = UIEdgeInsetsMake(8, 0, 0, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [RRNewsManager sharedManager].newsTabArray.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.row < [RRNewsManager sharedManager].newsTabArray.count) {

    RRResourceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RRResourceCell" forIndexPath:indexPath];
    
    cell.tagLabel.text = [RRNewsManager sharedManager].newsTabArray[indexPath.row];
    cell.tagLinkLabel.text = [RRNewsManager sharedManager].newsLinkArray[indexPath.row];
    
    return cell;
        
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RRAddCell" forIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[RRNewsManager sharedManager] moveTagAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL canMove = indexPath.row != [RRNewsManager sharedManager].newsTabArray.count;
    return canMove;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [[RRNewsManager sharedManager] deleteResourceAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - UITableViewDelegate


- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (proposedDestinationIndexPath.row == [RRNewsManager sharedManager].newsTabArray.count || proposedDestinationIndexPath.row == sourceIndexPath.row) {
        return sourceIndexPath;
    }
    return proposedDestinationIndexPath;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == [RRNewsManager sharedManager].newsTabArray.count ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}


- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == [RRNewsManager sharedManager].newsTabArray.count ? 50.0 : 79.0;
}


#pragma mark - Actions

- (void)editAction:(UIBarButtonItem *)sender
{
    BOOL isEditing = self.resourceTableView.editing;
    
    [self.resourceTableView setEditing:!isEditing animated:YES];
    
    UIBarButtonSystemItem item = isEditing ? UIBarButtonSystemItemEdit : UIBarButtonSystemItemDone;
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:item target:self action:@selector(editAction:)];
    
    [self.navigationItem setRightBarButtonItem:editButton animated:YES];
}

#pragma mark - RRAddResourceDelegate

- (void)addResourceInsertNewObject:(RRAddResourceViewController *)resource
{
    NSUInteger row = [RRNewsManager sharedManager].newsTabArray.count-1;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.resourceTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)addResource:(RRAddResourceViewController *)resource editResourceAtIndexPath:(NSIndexPath *)indexPath
{
    [self.resourceTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showWithTag"])
    {
        RRNewsViewController *newsVC = [segue destinationViewController];
        
        NSIndexPath *indexPath = [self.resourceTableView indexPathForCell:(UITableViewCell *)sender];
        
            newsVC.currentNewsTabIndex = indexPath.row;
    }
    
    if ([segue.identifier isEqualToString:@"editResource"])
    {
        RRAddResourceViewController *resurceVC = [segue destinationViewController];
        resurceVC.delegate = self;
    }
}


@end
