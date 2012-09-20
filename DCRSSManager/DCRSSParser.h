//
//  DCRSSParser.h
//  History
//
//  Created by Srikanth Sombhatla on 21/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

// Standard feed element names
extern NSString* DC_RSS_CHANNEL;
extern NSString* DC_RSS_ITEM;
extern NSString* DC_RSS_TITLE;
extern NSString* DC_RSS_DESCRIPTION;
extern NSString* DC_RSS_MEDIA_CONTENT;

#import "DCXMLParser.h"

@class DCXMLElement;
@interface DCRSSParser : DCXMLParser
- (NSInteger)count;
- (NSArray*)items;
- (DCXMLElement*)firstItem;
- (DCXMLElement*)lastItem;
- (DCXMLElement*)itemAtIndex:(NSInteger)index;

- (NSArray*)titles;
- (NSArray*)itemContentsWithName:(NSString*)name;
- (NSString*)itemContentWithName:(NSString*)name atIndex:(NSInteger)index;

- (DCXMLElement*)channel;
- (NSDictionary*) channelInfo;
@end
