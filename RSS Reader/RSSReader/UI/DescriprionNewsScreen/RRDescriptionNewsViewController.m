//
//  RRDescriptionNewsViewController.m
//  RSSReader
//
//  Created by Timofey Taran on 30.05.17.
//  Copyright © 2017 Timofey Taran. All rights reserved.
//

#import "RRDescriptionNewsViewController.h"
#import "RRNews+CoreDataClass.h"
#import "RRNewsManager.h"


const NSInteger RRIndent = 8;


@interface RRDescriptionNewsViewController ()


@property (weak, nonatomic) IBOutlet UIImageView *newsImageView;
@property (weak, nonatomic) IBOutlet UILabel *newsDateLabel;
@property (weak, nonatomic) IBOutlet UITextView *newsHeaderTextView;
@property (weak, nonatomic) IBOutlet UITextView *newsTextView;
@property (weak, nonatomic) IBOutlet UITextView *newsLinkTextView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *newsImageHightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *newsHeaderHightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *newsTextHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *newsLinkHeightConstraint;


@end


@implementation RRDescriptionNewsViewController


#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.newsDateLabel.text = [RRNewsManager formattedDateStringWithDate:self.newsData.pubDate];
    self.newsHeaderTextView.text = self.newsData.header;
    self.newsTextView.text = self.newsData.text;
    self.newsLinkTextView.text = self.newsData.link;
    
    if (self.newsImage)
    {
        self.newsImageView.image = self.newsImage;
    }
    else if (self.newsData.imageURL)
    {
        __weak RRDescriptionNewsViewController *weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:weakSelf.newsData.imageURL]];

            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.newsImageView.image = [UIImage imageWithData:imageData];
                
                [UIView animateWithDuration:0.3 animations:^{
                    [weakSelf resizeView];
                }];
            });
        });
    }
    
    [self initializationOfScrollToTop];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self resizeView];
}



#pragma mark - RRDescriptionNews Methods

- (void)setNewsWithNewsData:(RRNews *) newsData
{
    self.newsData = newsData;
}


#pragma mark - UI Update

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         [self resizeView];
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         [self.view layoutIfNeeded];
     }];
}


- (void)initializationOfScrollToTop
{
    self.newsTextView.scrollsToTop = NO;
    self.newsHeaderTextView.scrollsToTop = NO;
    self.newsLinkTextView.scrollsToTop = NO;
}


- (void)resizeView
{
    if (self.newsImageView.image)
    {
        CGSize imageSize = self.newsImageView.image.size;
        CGFloat imageResolution = imageSize.height / imageSize.width;
        CGFloat newHeight = self.view.frame.size.width * imageResolution;
        self.newsImageHightConstraint.constant = (newHeight > imageSize.height) ? imageSize.height : newHeight;
    }
    else
    {
        self.newsImageHightConstraint.constant = 0;
    }
    
    CGFloat newWidth = self.view.frame.size.width - 2 * RRIndent;
    self.newsHeaderHightConstraint.constant = ceilf([self.newsHeaderTextView sizeThatFits:CGSizeMake(newWidth, HUGE_VALF)].height);
    self.newsTextHeightConstraint.constant = ceilf([self.newsTextView sizeThatFits:CGSizeMake(newWidth, HUGE_VALF)].height);
    self.newsLinkHeightConstraint.constant = ceilf([self.newsLinkTextView sizeThatFits:CGSizeMake(newWidth, HUGE_VALF)].height);
    
    [self.view layoutIfNeeded];
}


@end
