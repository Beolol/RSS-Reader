//
//  RRDataManager.m
//  RSSReader
//
//  Created by user on 03.06.17.
//  Copyright © 2017 Timofey Taran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRDataManager.h"
#import "RRResource+CoreDataClass.h"
#import "RRNews+CoreDataClass.h"

@interface RRDataManager ()

@property (nonatomic) NSArray<NSDictionary<NSString *, NSString *> *> *newsResourceArray;

@end


@implementation RRDataManager
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (instancetype)init
{
    self = [super init];
    if (self) {
        _newsResourceArray = @[ @{@"tag" : @"В мире",
                                  @"link" : @"https://lenta.ru/rss/news/world",
                                  @"number" : @0
                                  },
                                @{@"tag" : @"Россия",
                                  @"link" : @"https://lenta.ru/rss/news/russia",
                                  @"number" : @1
                                  },
                                @{@"tag" : @"Культура",
                                  @"link" : @"https://lenta.ru/rss/news/culture",
                                  @"number" : @2
                                  },
                                @{@"tag" : @"Rambler",
                                  @"link" : @"https://news.rambler.ru/rss/head/",
                                  @"number" : @3
                                  }
                                ];
    }
    return self;
}

+ (RRDataManager*)sharedManager
{
    
    static RRDataManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[RRDataManager alloc] init];
    });
    
    return manager;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {

            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:[error localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
        }
    }
}

- (void)generateAndAddresourceIfNeeded
{
    NSError* error = nil;

    if ([self resultArrayResources].count > 0)
        return;
    
    for (NSDictionary<NSString *, NSString *> *resource in self.newsResourceArray) {
        NSNumber* number = (NSNumber *)resource[@"number"];
        
        [self resourceWithTag:resource[@"tag"] link:resource[@"link"] number:number.unsignedIntegerValue];
        
    }
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"%@", [error localizedDescription]);
    }
}

- (void)printResources
{
    NSArray *resultArray = [self resultArrayResources];
    
    for (id resource in resultArray) {
        if ([resource isKindOfClass:RRResource.class]) {
            RRResource *newsResource = (RRResource *)resource;
            NSLog(@"tag: %@\nlink: %@\nnumber: %d", newsResource.tag, newsResource.link, newsResource.number);
        }
    }
}

- (NSArray *)resultArrayResources
{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description =
    [NSEntityDescription entityForName:@"RRResource"
                inManagedObjectContext:self.managedObjectContext];
    
    NSSortDescriptor* nameDescriptor =
    [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    
    [request setSortDescriptors:@[nameDescriptor]];
    
    [request setEntity:description];
    
    NSError* requestError = nil;
    NSArray* resultArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
        return nil;
    }
    
    return resultArray;
}

- (RRResource*)resourceWithTag:(NSString*)tag link:(NSString *)link number:(NSUInteger)number
{
    
    RRResource* resource =
    [NSEntityDescription insertNewObjectForEntityForName:@"RRResource"
                                  inManagedObjectContext:self.managedObjectContext];
    
    resource.tag = tag;
    resource.link = link;
    resource.number = (int32_t)number;
    
    return resource;
}


- (void)deleteAllObjects {
    
    NSArray* allObjects = [self resultArrayResources];
    
    for (id object in allObjects) {
        [self.managedObjectContext deleteObject:object];
    }
    [self.managedObjectContext save:nil];
}

- (NSDate *)formattedDateWithString:(NSString *)stringDate
{
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"];
        dateFormatter.dateFormat = @"dd MMMM yyyy' г.' HH:mm";
    });
    
    return [dateFormatter dateFromString:stringDate];
}

#pragma mark - ResourceManipulation

- (void)addResourceWithTag:(NSString*)tag link:(NSString *)link number:(NSUInteger)number
{
    NSError *error;
    
    [self resourceWithTag:tag link:link number:number];
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"%@", [error localizedDescription]);
    }
}

- (void)deleteResourceAtIndex:(NSUInteger)index
{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description =
    [NSEntityDescription entityForName:@"RRResource"
                inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate* predicate =
    [NSPredicate predicateWithFormat:@"number == %d", (int32_t)index];
    
    [request setPredicate:predicate];
    [request setEntity:description];
    
    NSError* requestError = nil;
    NSArray* resultArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
        return;
    }
    
    for (id object in resultArray) {
        [self.managedObjectContext deleteObject:object];
    }
    [self.managedObjectContext save:nil];
    
    [self decrimentResourceAtIndex:index];
}


- (void)moveTagAtIndex:(NSUInteger)sourceIndex toIndex:(NSUInteger)destinationIndex
{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description =
    [NSEntityDescription entityForName:@"RRResource"
                inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate* predicate =
    [NSPredicate predicateWithFormat:@"number >= %d AND number <= %d", (int32_t)sourceIndex, (int32_t)destinationIndex];
    
    [request setPredicate:predicate];
    [request setEntity:description];
    
    NSError* requestError = nil;
    NSArray* resultArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
        return;
    }
    
    if (sourceIndex < destinationIndex)
    {
        for (RRResource* resource in resultArray) {
            if (resource.number == (int32_t)sourceIndex)
                resource.number = (int32_t)destinationIndex;
            else
                resource.number--;
        }
    }
    else
    {
        for (RRResource* resource in resultArray) {
            if (resource.number == (int32_t)sourceIndex)
                resource.number = (int32_t)destinationIndex;
            else
                resource.number++;
        }
    }
    
    [self.managedObjectContext save:nil];
}

- (void)decrimentResourceAtIndex:(NSUInteger)index
{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description =
    [NSEntityDescription entityForName:@"RRResource"
                inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate* predicate =
    [NSPredicate predicateWithFormat:@"number > %d", (int32_t)index];
    
    [request setPredicate:predicate];
    [request setEntity:description];
    
    NSError* requestError = nil;
    NSArray* resultArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
        return;
    }
    
    for (RRResource* object in resultArray) {
        object.number--;
    }
    
    [self.managedObjectContext save:nil];
}

#pragma mark - NewsManipulations

- (BOOL)addNewsWithResult:(NSArray<NSDictionary *> *)resultArray resource:(RRResource*)resource
{
    if (!resource || resultArray.count == 0)
        return NO;
 
    NSMutableSet *newsSet = [NSMutableSet set];
    
    for (NSDictionary* dict in resultArray)
    {
        if ([self isNewNewsWithHeader:dict[@"title"]]) {
            
            RRNews *news = [NSEntityDescription insertNewObjectForEntityForName:@"RRNews"
                                          inManagedObjectContext:self.managedObjectContext];
            news.imageURL = dict[@"imageUrl"];
            news.pubDate = [self formattedDateWithString:dict[@"pubDate"]];
            news.header = dict[@"title"];
            news.text = dict[@"description"];
            news.link = dict[@"link"];
            
            [newsSet addObject:news];
        }
    }
    
    if (newsSet.count == 0)
        return NO;
    
    NSError *error;
    
    resource.news = newsSet;

    if (![self.managedObjectContext save:&error]) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    return YES;
}


- (BOOL)isNewNewsWithHeader:(NSString *)header
{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description =
    [NSEntityDescription entityForName:@"RRNews"
                inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate* predicate =
    [NSPredicate predicateWithFormat:@"header == %@", header];
    
    [request setPredicate:predicate];
    [request setEntity:description];
    
    NSError* requestError = nil;
    NSArray* resultArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
        return NO;
    }
    
    return resultArray.count == 0 ? YES : NO;
}

- (NSArray<RRNews *> *)newsArrayWithResource:(RRResource *)resource
{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description =
    [NSEntityDescription entityForName:@"RRNews"
                inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate* predicate =
    [NSPredicate predicateWithFormat:@"resource.tag == %@", resource.tag];
    
    [request setPredicate:predicate];
    
    NSSortDescriptor* nameDescriptor =
    [[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending:NO];
    
    [request setSortDescriptors:@[nameDescriptor]];
    [request setEntity:description];
    
    NSError* requestError = nil;
    NSArray* resultArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    return resultArray;
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}


- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"RRModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"RRSReader.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
