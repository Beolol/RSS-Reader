//
//  RRDataManager.h
//  RSSReader
//
//  Created by user on 03.06.17.
//  Copyright © 2017 Timofey Taran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RRNews;
@class RRResource;

@interface RRDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

+ (RRDataManager*)sharedManager;

- (void)generateAndAddresourceIfNeeded;

- (NSArray *)resultArrayResources;

- (void)addResourceWithTag:(NSString*)tag link:(NSString *)link number:(NSUInteger)number;
- (void)moveTagAtIndex:(NSUInteger)sourceIndex toIndex:(NSUInteger)destinationIndex;
- (void)deleteResourceAtIndex:(NSUInteger)index;

- (BOOL)addNewsWithResult:(NSArray<NSDictionary *> *)resultArray resource:(RRResource*)resource;
- (NSArray<RRNews *> *)newsArrayWithResource:(RRResource *)resource;

- (void)printResources;
- (void)deleteAllObjects;

@end
