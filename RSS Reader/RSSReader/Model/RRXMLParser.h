//
//  XMLParser.h
//  RSSReader
//
//  Created by Timofey Taran on 30.05.17.
//  Copyright © 2017 Timofey Taran. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString* const RRXMLParserImageURLString;
extern NSString* const RRXMLParserPubDateString;
extern NSString* const RRXMLParserHeader;
extern NSString* const RRXMLParserDescription;
extern NSString* const RRXMLParserLink;

@class RRXMLParser;


#pragma mark - RRXMLParserDelegate

@protocol RRXMLParserDelegate <NSObject>

- (void)parser:(RRXMLParser *)parser didFinishWithResult:(NSArray<NSDictionary *> *)resultArray urlString:(NSString *)urlString;

@end


@interface RRXMLParser : NSObject

@property (weak, nonatomic) id<RRXMLParserDelegate> delegate;

- (void)parseXMLWithURLString:(NSString *)urlString;
- (void)reparseXML;


@end



