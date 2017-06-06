//
//  RRNewsManager.h
//  RSSReader
//
//  Created by Timofey Taran on 30.05.17.
//  Copyright © 2017 Timofey Taran. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RRNews;

typedef void (^RRNewsBlock)(void);

@interface RRNewsManager : NSObject

@property (nonatomic) NSMutableArray *newsResourceArray;
@property (nonatomic, copy) void(^updateBlock)(void);

+ (RRNewsManager*)sharedManager;

+ (NSString *)formattedDateStringWithDate:(NSDate *)date;

- (NSArray<RRNews *> *)getNewsArrayWithTag:(NSString *)tag updateNewsBlock:(RRNewsBlock)updateBlock;
- (void)updateNewsWithTag:(NSString *)tag;
- (void)addResourceWithTag:(NSString *)tag link:(NSString *)link;
- (void)moveTagAtIndex:(NSUInteger)sourceIndex toIndex:(NSUInteger)destinationIndex;
- (void)deleteResourceAtIndex:(NSUInteger)index;
- (NSString *)tagWithIndex:(NSUInteger)index;

@end
