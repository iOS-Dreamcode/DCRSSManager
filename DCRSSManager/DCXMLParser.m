//
//  DCXMLParser.m
//  Daily Horoscope
//
//  Created by Srikanth Sombhatla on 19/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCXMLParser.h"

NSString* DC_NOTIF_PARSING_COMPLETED = @"com.dc.dcxmlparser.parsingcompleted";

// private
@interface DCXMLParser () {
    NSXMLParser* xmlParser;
    DCXMLElement* rootElement;
}
- (void)initResourcesWithXMLData:(NSData*)xmlData;
- (void)clearState;
- (void)notifyParsingCompleted;
@end

@implementation DCXMLParser

@synthesize tag;

// pimpl starts
- (void)initResourcesWithXMLData:(NSData*)xmlData {
    xmlParser = [[NSXMLParser alloc] initWithData:xmlData];
}

- (void)clearState {
    [xmlParser release];
    xmlParser = nil;
    [rootElement release];
    rootElement = nil;
}

- (void)notifyParsingCompleted {
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:DC_NOTIF_PARSING_COMPLETED object:self];    
    });
}

// pimpl ends

- (id)init {
    self = [super init];
    if(self) { 
        // do resource initialization here.
        rootElement = nil;
    }
    return self;
}

- (void)dealloc {
    [self clearState];
    [super dealloc];
}

- (id)initWith: (NSData*) xmlData {
    self = [self init];
    if(self) {
        [self initResourcesWithXMLData:xmlData];
    }
    return self;
}

- (void)parseAsync {
    dispatch_queue_t parser_queue = dispatch_queue_create("com.dc.dcxmlparser.parser",nil);  
    dispatch_async(parser_queue, ^{
        [self parseSync];
        [self notifyParsingCompleted];
    });
}

- (void)parseSync {
    rootElement = [[DCXMLElement alloc] initAsRootElement];
    [xmlParser setDelegate:rootElement];
    [xmlParser parse]; 
}

- (NSError*)error {
    return [xmlParser parserError];
}

- (DCXMLElement*)rootElement {
    return rootElement;
}

- (void)setXMLData:(NSData*)xmlData {
    [self clearState];
    [self initResourcesWithXMLData:xmlData];
}

// Debug utilities //
- (void)dumpAllItems {

}

@end