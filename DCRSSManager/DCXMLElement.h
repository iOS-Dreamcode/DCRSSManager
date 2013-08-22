//
//  Element.h
//  RSSParser
//
//  Created by Srikanth Sombhatla on 13/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCXMLElement : NSObject <NSXMLParserDelegate>

- (id) initAsRootElement;

- (id) intWithName: (NSString*)elementName 
      namespaceURI:(NSString *)namespaceURI
     qualifiedName:(NSString *)qualifiedName 
        attributes:(NSDictionary *)attributeDict
            parent:(DCXMLElement*)parentElement;

- (BOOL) isRootElement;

- (NSString*) name;
- (NSString*) content;
- (NSString*) decodedContent;
- (NSArray*) children;
- (NSInteger) childrenCount;
- (NSArray*) childrenNames;
- (DCXMLElement*) childWithName:(NSString*)childName;
- (NSString*) contentForChildWithName:(NSString*)childName;
- (NSDictionary*)attributes;
- (id)attributeValueForKey:(NSString*)key;
@end
