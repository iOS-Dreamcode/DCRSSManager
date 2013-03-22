//
//  Element.m
//  RSSParser
//
//  Created by Srikanth Sombhatla on 13/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DCXMLElement.h"

@interface DCXMLElement () {
    DCXMLElement* parent;
    NSMutableArray* childrenNames; // stores names as array supporting repeated names like RSS feeds
    NSMutableArray* children;  // stores child object at index which represents the name in childrenNames
    NSString* name;
    NSDictionary* attributes;
    NSMutableString* contentString;
    NSDictionary* htmlEncodingDict;
}

- (void) initResources;

- (void) addChild:(DCXMLElement*) child;
- (int) childrenCount;
- (void) appendToContent:(NSString*)characters;

@end

@implementation DCXMLElement

- (id) initAsRootElement {
    self = [super init]; 
    parent = nil; // no parent for root
    [self initResources];
    return self;
}

- (id) intWithName: (NSString*)elementName 
          namespaceURI:(NSString *)namespaceURI
         qualifiedName:(NSString *)qualifiedName 
            attributes:(NSDictionary *)attributeDict
                parent:(DCXMLElement*)parentElement {
    
    self = [super init];
    if(self) {
        [self initResources];
        name = [[NSString stringWithString:elementName] retain];
        NSLog(@"name:%@",name);
        parent = parentElement;
        attributes = [[NSDictionary dictionaryWithDictionary:attributeDict] retain];
        NSLog(@"attributes:%@",attributes);
    }
    return self;
}

- (void) initResources {
    childrenNames = [[NSMutableArray alloc] init];
    children = [[NSMutableArray alloc] init];
    contentString = [[NSMutableString alloc] init];
    
    htmlEncodingDict = [NSDictionary dictionaryWithObjectsAndKeys:
                        @"&",@"&amp;",
                        @"'", @"&apos;",
                        @"\"",@"&quot;",
                        @"<",@"&lt;",
                        @">",@"&gt;",
                        nil];
}

- (void) addChild:(DCXMLElement*) child {
    [childrenNames addObject:[child name]];
    [children addObject:child];
}

- (void) appendToContent:(NSString*)characters {
    [contentString appendString: characters];
}

- (BOOL) isRootElement {
    return (parent == nil);
}

- (NSString*) name {
    return name;
}

- (NSString*) content {
    return contentString;
}

- (NSString*) decodedContent {
    NSMutableString* c = [NSMutableString stringWithString:[self content]];
    NSRange range = NSMakeRange(0,0);
    for(NSString* key in [htmlEncodingDict allKeys]) {
        range.length = c.length;
        NSString* replaceString = [htmlEncodingDict objectForKey:key];
        [c replaceOccurrencesOfString:key withString:replaceString options: NSLiteralSearch range:range];
    }
    NSLog(@"html decoded:%@",c);
    return c;
}

/*!
 \brief returns children of this element.
 **/
- (NSArray*) children {
    return children;
}

- (NSInteger) childrenCount {
    return [childrenNames count];
}

- (NSArray*) childrenNames {
    return childrenNames;
}

- (DCXMLElement*) childWithName:(NSString*)childName {
    DCXMLElement* c = nil;
    NSInteger i = [childrenNames indexOfObject:childName];
    if(i != NSNotFound && i <= [children count]-1) {
        c = [children objectAtIndex:i];
    }
    return c;
}

- (NSString*) contentForChildWithName:(NSString*)childName {
    return [[self childWithName:childName] content];
}

- (NSDictionary*)attributes {
    return attributes;
}

- (id)attributeValueForKey:(NSString*)key {
    return [attributes objectForKey:key];
}

/* Parser call backs */
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    parent = nil; // setting as root element
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"%s",__PRETTY_FUNCTION__);  
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict { 
    NSLog(@"%s %@",__PRETTY_FUNCTION__,elementName);
    
    if([self isRootElement] && 0 == [name length]) {
        NSLog(@"This is root element:%@",name);
        name = elementName;
        attributes = [attributeDict retain];
        parent = nil;
        
    } else {
        // Create child element
        //NSLog(@"This is child element %@ for parent element %@",elementName, name);
        DCXMLElement* child = [[DCXMLElement alloc] intWithName:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict parent:self];
        [self addChild:child];
        [parser setDelegate:child];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    NSLog(@"%s %@",__PRETTY_FUNCTION__,name);
    if(![self isRootElement]) 
        [parser setDelegate:parent]; 
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self appendToContent:string];
}

@end

// eof
