//
//  XMLParser.m
//  RSSReader
//
//  Created by Timofey Taran on 30.05.17.
//  Copyright © 2017 Timofey Taran. All rights reserved.
//
//

#import "RRXMLParser.h"


NSString* const RRXMLParserImageURLString = @"imageUrl";
NSString* const RRXMLParserPubDateString = @"pubDate";
NSString* const RRXMLParserHeader = @"title";
NSString* const RRXMLParserDescription = @"description";
NSString* const RRXMLParserLink = @"link";

static NSString *currentURLString;

@interface RRXMLParser () <NSXMLParserDelegate>


@property (nonatomic) NSMutableArray<NSMutableDictionary *> *xmlData;
@property (nonatomic) NSMutableDictionary *xmlItem;
@property (nonatomic) NSMutableString *xmlElement;
@property (nonatomic) NSXMLParser *xmlParser;
@property (nonatomic) dispatch_queue_t queueXML;


@end


@implementation RRXMLParser


- (id)init
{
    self = [super init];
    
    if (self)
    {
        _queueXML = dispatch_queue_create("com.rssreaderxmlparser.queue", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}


#pragma mark - CulculationMethods

- (void)parseXMLWithURLString:(NSString *)urlString;
{
    currentURLString = urlString;
    
    [self parsingXMLWithURLString:urlString];
}


- (void)reparseXML
{
    NSString *urlString = currentURLString;
    
    [self parsingXMLWithURLString:urlString];
}


- (void)parsingXMLWithURLString:(NSString *)urlString
{
    __weak RRXMLParser *weakSelf = self;
    dispatch_async(self.queueXML, ^{
        weakSelf.xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:urlString]];
        
        if ([currentURLString isEqualToString:urlString])
        {
            [weakSelf startParsing];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([currentURLString isEqualToString:urlString])
            {
                if (weakSelf.delegate)
                    [weakSelf.delegate parser:weakSelf didFinishWithResult:weakSelf.xmlData urlString:urlString];
                [weakSelf clearXMLData];
            }
        });
    });
}

- (void)startParsing
{
    [self clearXMLData];
    self.xmlParser.delegate = self;
    [self.xmlParser parse];
}


- (NSString *)formattedDateStringWithString:(NSString *)stringDate
{
    static NSDateFormatter *inputDateFormatter = nil;
    static NSDateFormatter *outputDateFormatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        inputDateFormatter = [[NSDateFormatter alloc] init];
        inputDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_POSIX"];
        inputDateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss zzz";
        outputDateFormatter = [[NSDateFormatter alloc] init];
        outputDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"];
        outputDateFormatter.dateFormat = @"dd MMMM yyyy' г.' HH:mm";
    });
    
    NSDate *dateOldFormat = [inputDateFormatter dateFromString:stringDate];
    NSString *formattedDate = [outputDateFormatter stringFromDate:dateOldFormat];
    
    return formattedDate ? formattedDate : @"";
}


- (void)clearXMLData
{
    self.xmlData = nil;
    self.xmlItem = nil;
    self.xmlElement = nil;
}


#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([elementName isEqualToString:@"rss"])
    {
        self.xmlData = [[NSMutableArray alloc] init];
    }
    
    if ([elementName isEqualToString:@"enclosure"])
    {
        self.xmlItem[RRXMLParserImageURLString] = attributeDict[@"url"];
    }
    
    if ([elementName isEqualToString:@"item"])
    {
        self.xmlItem = [[NSMutableDictionary alloc] init];
    }
    
    self.xmlElement = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
{
    NSString *appendString = [[NSString alloc] initWithCString:[string UTF8String] encoding:NSUTF8StringEncoding];
    
    if (!self.xmlElement)
    {
        self.xmlElement = [[NSMutableString alloc] initWithString:appendString];
    }
    else
    {
        [self.xmlElement appendString:appendString];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    if ([elementName isEqualToString:RRXMLParserHeader] || [elementName isEqualToString:RRXMLParserLink] || [elementName isEqualToString:@"url"])
    {
        self.xmlItem[elementName] = self.xmlElement;
    }
    
    if ([elementName isEqualToString:RRXMLParserPubDateString])
    {
        NSString *pubDate = self.xmlElement;
        pubDate = [self formattedDateStringWithString:pubDate];
        self.xmlItem[elementName] = pubDate;
    }
    
    if ([elementName isEqualToString:RRXMLParserDescription])
    {
        NSString *description = [self.xmlElement stringByTrimmingCharactersInSet:
                                 [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.xmlItem[elementName] = description;
    }
    
    if ([elementName isEqualToString:@"item"])
    {
        [self.xmlData addObject:self.xmlItem];
    }
    
    self.xmlElement = nil;
}

@end
