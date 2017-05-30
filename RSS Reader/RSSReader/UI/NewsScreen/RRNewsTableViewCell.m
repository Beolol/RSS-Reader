//
//  RRNewsTableViewCell.m
//  RSSReader
//
//  Created by Timofey Taran on 30.05.17.
//  Copyright © 2017 Timofey Taran. All rights reserved.
//

#import "RRNewsTableViewCell.h"
#import "UIColor+RSSReader.h"


@implementation RRNewsTableViewCell

#pragma mark - LifeCycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.newsImageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:NULL];
}


- (void)dealloc
{
    [self.newsImageView removeObserver:self forKeyPath:@"image"];
}


- (void)showBackgroundWithImage:(BOOL)showWithImage
{
    self.gradientImageView.hidden = !showWithImage;
    
    if (showWithImage)
    {
        self.newsImageView.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        self.newsImageView.backgroundColor = [UIColor RRColorWithRed:110.0 Green:110.0 Blue:110.0 Alpha:1.0];
    }
}


#pragma mark - Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"image"])
    {
        [self showBackgroundWithImage:(self.newsImageView.image != nil)];
    }
}


@end
