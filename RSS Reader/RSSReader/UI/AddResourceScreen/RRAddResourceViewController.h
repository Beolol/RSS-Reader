//
//  RRAddResourceViewController.h
//  RSSReader
//
//  Created by user on 30.05.17.
//  Copyright © 2017 Timofey Taran. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RRAddResourceViewController;

#pragma mark - RRAddResourceDelegate

@protocol RRAddResourceDelegate <NSObject>

- (void)addResourceInsertNewObject:(RRAddResourceViewController *)resource;
- (void)addResource:(RRAddResourceViewController *)resource editResourceAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface RRAddResourceViewController : UIViewController

@property (weak, nonatomic) id<RRAddResourceDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextField *tagResourceTextField;
@property (weak, nonatomic) IBOutlet UITextField *linkResourceTextField;
@property (nonatomic) NSIndexPath *indexPath;

@end
