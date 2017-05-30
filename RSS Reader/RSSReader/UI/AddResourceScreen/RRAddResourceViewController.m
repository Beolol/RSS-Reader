//
//  RRAddResourceViewController.m
//  RSSReader
//
//  Created by user on 30.05.17.
//  Copyright © 2017 Timofey Taran. All rights reserved.
//

#import "RRAddResourceViewController.h"
#import "RRResourceDirectoryViewController.h"
#import "RRNewsManager.h"

@interface RRAddResourceViewController ()

@end

@implementation RRAddResourceViewController


- (IBAction)addResource:(id)sender
{
    
    if ([self.tagResourceTextField.text isEqualToString:@""] || [self.linkResourceTextField.text isEqualToString:@""])
    {
        return;
    }
    
    if (!self.indexPath) {
        [[RRNewsManager sharedManager].newsTabArray addObject:self.tagResourceTextField.text];
        [[RRNewsManager sharedManager].newsLinkArray addObject:self.linkResourceTextField.text];
        [self.delegate addResourceInsertNewObject:self];
    }
    else
    {
        [RRNewsManager sharedManager].newsTabArray[self.indexPath.row] = self.tagResourceTextField.text;
        [RRNewsManager sharedManager].newsLinkArray[self.indexPath.row] = self.linkResourceTextField.text;
        [self.delegate addResource:self editResourceAtIndexPath:self.indexPath];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
