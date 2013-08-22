//
//  DCRSSParser.m
//  Dreamcode
//
//  Created by Srikanth Sombhatla on 21/06/12.
//  Copyright (c) 2012 Dreamcode. All rights reserved.
//

/*!
 /class 
 
 Example feed structure
 channel->title->link
 ... other channel elements
 ->item->title
 ->item->title
 ->item->title

 **/

#import "DCRSSParser.h"
#import "DCXMLParser.h"
#import "DCXMLElement.h"

NSString* DC_RSS_CHANNEL            =       @"channel";
NSString* DC_RSS_ITEM               =       @"item";
NSString* DC_RSS_TITLE              =       @"title";
NSString* DC_RSS_DESCRIPTION        =       @"description";

NSString* DC_RSS_MEDIA_CONTENT      =       @"media:content";

// internal //
NSString* DC_CHANNEL_INFO           =       @"channelinfo";
// internal //

@interface DCRSSParser() {
    // this is a dictionary with the item name and parsed result as key,value pairs
    // ex: "title" -> {"title1","title2"..."titlen"}
    NSMutableDictionary* _cachedResults;
    
    // Array of item objects
    NSArray* _items;
}
- (void) reset;
@end


@implementation DCRSSParser

#pragma mark pimp_start

- (void) reset {
    // TODO: Is this releasing all objects?
    [_cachedResults removeAllObjects];
    [_items release];
    _items = nil;
}

- (NSArray*)items {
    if(0 == [_items count]) {
        DCXMLElement* channelElement = [self channel];
        NSArray* channelChildrenNames = [channelElement childrenNames];
        NSMutableArray* itemarray = [[NSMutableArray alloc] init];
        for(int i=0;i<[channelChildrenNames count];++i) {
            if([[channelChildrenNames objectAtIndex:i] isEqualToString:DC_RSS_ITEM]) 
                [itemarray addObject: [[channelElement children] objectAtIndex:i]];    
        }
        _items = [itemarray retain];
        [itemarray release];
    }
    return _items;
}

#pragma mark pimp_end

- (id)init {
    self = [super init];
    if(self) {
        _cachedResults = [[NSMutableDictionary alloc] init];
        _items = [[NSArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    [self reset];
    [_cachedResults release];
    [super dealloc];
}

/*!
 Returns the items count.
 **/
- (NSInteger)count {
    return [[self items] count];
}

/*!
 Returns DCXMLElement pointing channel element.
 \sa DCXMLElement
 **/
- (DCXMLElement*)channel {
    return [[self rootElement] childWithName:DC_RSS_CHANNEL];
}

/*!
 Convinience method to return DCXMLElement pointing the first item.
 This is same as 
 \code
    [parser itemAtIndex:0];
 \endcode
 \sa DCXMLElement
 **/
- (DCXMLElement*)firstItem {
    return [self itemAtIndex:0];
}

/*!
 Convinience method to return DCXMLElement pointing the last item.
 This is same as 
 \code
    [parser itemAtIndex:([parser count]-1)];
 \endcode
 \sa DCXMLElement
 **/
- (DCXMLElement*)lastItem {
    return [self itemAtIndex:([self count]-1)];
}

/*!
 Returns DCXMLElement pointing item at \a index
 **/
- (DCXMLElement*)itemAtIndex:(NSInteger)index {
    DCXMLElement* e = nil;
    NSInteger c = [self count];
    if(c && c >= index) 
        e = [[self items] objectAtIndex:index];
    return e;
}

/*
 Returns contents of all elements with \a name with in items.
 For example to get titles of all items
 \code 
    NSArray* titles = [parser itemContentsWithName:@"title"];
 \endcode
 */
- (NSArray*)itemContentsWithName:(NSString*)name {
    if(![_cachedResults objectForKey:name]) {
        if([self count]) {
            NSMutableArray* res = [[NSMutableArray alloc] init];
            for (DCXMLElement* e in [self items]) {
                id c = [[e childWithName:name] content];
                if(c) 
                    [res addObject: c];
                 else 
                    [res addObject:[NSNull null]];
            }
            if([res count]) 
                [_cachedResults setObject:res forKey:name];
            [res release];
        }
    }
    return [_cachedResults objectForKey:name];
}

/*!
 Returns text content of the item with \a name at \a index
 **/
- (NSString*)itemContentWithName:(NSString*)name atIndex:(NSInteger)index {
    if([self count] >= index)
        return [[self itemContentsWithName:name] objectAtIndex:index];
    else
        return nil;
}

/*!
 Returns channel info as an NSDictionary. Here key is the name of channel element and value is it's text content.
 **/
- (NSDictionary*) channelInfo {
    DCXMLElement* c = [self channel];
    NSMutableDictionary* info = [_cachedResults objectForKey:DC_CHANNEL_INFO];
    if(!info) {
        info = [[NSMutableDictionary alloc] init];
        for (NSString* childname in [c childrenNames])
            [info setValue: [c contentForChildWithName:childname] forKey:childname];
        [_cachedResults setObject:info forKey:DC_CHANNEL_INFO];
        [info release];
    }
    return info;
}

/*!
 Returns titles of all items as an array. 
 **/
- (NSArray*)titles {
    return [self itemContentsWithName:DC_RSS_TITLE];
}

@end

// eof
