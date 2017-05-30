//
//  RRNewsManager.h
//  RSSReader
//
//  Created by Timofey Taran on 30.05.17.
//  Copyright © 2017 Timofey Taran. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RRNewsData;

extern NSString* const RRDataManagerDidUpdateNewsNotification;
extern NSString* const RRDataManagerNewsUserInfoKey;


@interface RRNewsManager : NSObject

@property (nonatomic) NSMutableArray<NSString *> *newsTabArray;
@property (nonatomic) NSMutableArray<NSString *> *newsLinkArray;

+ (RRNewsManager*)sharedManager;
- (NSArray<RRNewsData *> *)getNewsWithTag:(NSString *)tag;
- (void)updateNewsWithTag:(NSString *)tag;
- (void)moveTagAtIndex:(NSUInteger)sourceIndex toIndex:(NSUInteger)destinationIndex;
- (void)deleteResourceAtIndex:(NSUInteger)index;


@end
