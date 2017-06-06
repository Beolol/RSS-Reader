//
//  RRNews+CoreDataProperties.h
//  
//
//  Created by user on 06.06.17.
//
//

#import "RRNews+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface RRNews (CoreDataProperties)

+ (NSFetchRequest<RRNews *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *header;
@property (nullable, nonatomic, copy) NSString *imageURL;
@property (nullable, nonatomic, copy) NSString *link;
@property (nullable, nonatomic, copy) NSString *pubDate;
@property (nullable, nonatomic, copy) NSString *text;
@property (nullable, nonatomic, retain) RRResource *resource;

@end

NS_ASSUME_NONNULL_END
