//
//  RRImageContainer.m
//  RSSReader
//
//  Created by Timofey Taran on 30.05.17.
//  Copyright © 2017 Timofey Taran. All rights reserved.
//

#import "RRImageContainer.h"


@implementation RRImageContainer


- (id)init
{
    self = [super init];
    
    if (self)
    {
        _imagesDictionary = [NSMutableDictionary dictionary];
    }
    
    return self;
}


+ (RRImageContainer *)sharedContainer
{
    static RRImageContainer* container = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        container = [[RRImageContainer alloc] init];
    });
    
    return container;
}


@end
