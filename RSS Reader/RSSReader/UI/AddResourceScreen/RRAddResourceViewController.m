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
        [[RRNewsManager sharedManager] addResourceWithTag:self.tagResourceTextField.text link:self.linkResourceTextField.text];
        [self.delegate addResourceInsertNewObject:self];
    }
    else
    {
        //@TODO edit resource
        [self.delegate addResource:self editResourceAtIndexPath:self.indexPath];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
