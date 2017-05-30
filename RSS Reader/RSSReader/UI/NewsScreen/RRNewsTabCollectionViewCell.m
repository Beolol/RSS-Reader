//
//  RRNewsTabCollectionViewCell.m
//  RSSReader
//
//  Created by Timofey Taran on 30.05.17.
//  Copyright © 2017 Timofey Taran. All rights reserved.
//

#import "RRNewsTabCollectionViewCell.h"


@implementation RRNewsTabCollectionViewCell


- (void)setSelected:(BOOL)selected
{
    if (selected)
    {
        self.newsTagLabel.textColor = [UIColor whiteColor];
        self.newsTagLabel.font = [UIFont boldSystemFontOfSize:17.0];
    }
    else
    {
        self.newsTagLabel.textColor = [UIColor lightGrayColor];
        self.newsTagLabel.font = [UIFont systemFontOfSize:17.0];
    }
}


@end
