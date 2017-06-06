//
//  RRNewsManager.m
//  RSSReader
//
//  Created by Timofey Taran on 30.05.17.
//  Copyright © 2017 Timofey Taran. All rights reserved.
//

#import "RRNewsManager.h"
#import "RRXMLParser.h"
#import "RRDataManager.h"
#import "RRResource+CoreDataClass.h"
#import "RRNews+CoreDataClass.h"

@interface RRNewsManager () <RRXMLParserDelegate>

@property (nonatomic) NSMutableDictionary *newsDictionary;

@property (nonatomic) RRXMLParser *xmlParser;

@end


@implementation RRNewsManager


#pragma mark - Initialization

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _newsResourceArray = [[[RRDataManager sharedManager] resultArrayResources] copy];
        _xmlParser = [[RRXMLParser alloc] init];
        _xmlParser.delegate = self;
        
        _newsDictionary = [NSMutableDictionary dictionary];
    }
    
    return self;
}


+ (RRNewsManager*)sharedManager
{
    static RRNewsManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[RRNewsManager alloc] init];
    });
    
    return manager;
}

+ (NSString *)formattedDateStringWithDate:(NSDate *)date
{
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"];
        dateFormatter.dateFormat = @"dd MMMM yyyy' г.' HH:mm";
    });
    
    return [dateFormatter stringFromDate:date];
}


#pragma mark - RRNewsManager Methods

- (NSArray<RRNews *> *)getNewsArrayWithTag:(NSString *)tag updateNewsBlock:(RRNewsBlock)updateBlock cancelBlock:(RRNewsBlock)cancelBlock
{
    NSMutableArray<RRNews *> *newsArray = [NSMutableArray array];
    
    for (RRResource *resource in self.newsResourceArray) {
        if ([resource.tag isEqualToString:tag]) {
            newsArray = [[[RRDataManager sharedManager] newsArrayWithResource:resource] copy];
        }
    }
    self.cancelBlock = cancelBlock;
    
    if (newsArray.count == 0)
    {
        NSString *link = [self linkStringWithTag:tag];
        self.updateBlock = updateBlock;

        [self.xmlParser parseXMLWithURLString:link];
    }
    
    return newsArray;
}

- (NSString *)linkStringWithTag:(NSString *)tag
{
    NSString* link = nil;
    
    for (RRResource *resource in self.newsResourceArray) {
        if ([resource.tag isEqualToString:tag]) {
            link = resource.link;
        }
    }
    
    return link;
}

- (void)updateNewsWithTag:(NSString *)tag
{
    NSString *link = [self linkStringWithTag:tag];
    
    [self.xmlParser parseXMLWithURLString:link];
}


- (NSString *)tagWithIndex:(NSUInteger)index
{
    NSString* tag = nil;
    
    for (RRResource *resource in self.newsResourceArray) {
        if (resource.number == (int32_t)index) {
            tag = resource.tag;
        }
    }
    
    return tag;
}


- (void)moveTagAtIndex:(NSUInteger)sourceIndex toIndex:(NSUInteger)destinationIndex
{
    [[RRDataManager sharedManager] moveTagAtIndex:sourceIndex toIndex:destinationIndex];
    self.newsResourceArray = [[[RRDataManager sharedManager] resultArrayResources] copy];
}

- (void)deleteResourceAtIndex:(NSUInteger)index
{
    [[RRDataManager sharedManager] deleteResourceAtIndex:index];
    self.newsResourceArray = [[[RRDataManager sharedManager] resultArrayResources] copy];
}

- (void)addResourceWithTag:(NSString *)tag link:(NSString *)link
{
    [[RRDataManager sharedManager] addResourceWithTag:tag link:link number:self.newsResourceArray.count];
    self.newsResourceArray = [[[RRDataManager sharedManager] resultArrayResources] copy];
}

#pragma mark - RRXMLParserDelegate

- (void)parser:(RRXMLParser *)parser didFinishWithResult:(NSArray<NSDictionary *> *)resultArray urlString:(NSString *)urlString
{
    RRResource *currentResource = nil;
    
    for (RRResource *resource in self.newsResourceArray) {
        if ([resource.link isEqualToString:urlString]) {
            currentResource = resource;
            break;
        }
    }
    
    if ([[RRDataManager sharedManager] addNewsWithResult:resultArray resource:currentResource]) {
        self.newsResourceArray = [[[RRDataManager sharedManager] resultArrayResources] copy];
        self.updateBlock();
    }
    else
    {
        self.cancelBlock();
    }
}


@end
