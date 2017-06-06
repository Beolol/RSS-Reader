//
//  RRNews+CoreDataProperties.m
//  
//
//  Created by user on 06.06.17.
//
//

#import "RRNews+CoreDataProperties.h"

@implementation RRNews (CoreDataProperties)

+ (NSFetchRequest<RRNews *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"RRNews"];
}

@dynamic header;
@dynamic imageURL;
@dynamic link;
@dynamic pubDate;
@dynamic text;
@dynamic resource;

@end
