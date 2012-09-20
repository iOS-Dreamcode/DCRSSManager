//
//  DCXMLParser.h
//  Daily Horoscope
//
//  Created by Srikanth Sombhatla on 19/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCXMLElement.h"

extern NSString* DC_NOTIF_PARSING_COMPLETED;
@interface DCXMLParser : NSObject
    @property (nonatomic,retain) NSString* tag;

    - (id)initWith: (NSData*) xmlData;
    - (void) setXMLData:(NSData*)xmlData;
    - (void)parseAsync;
    - (void)parseSync;
    - (NSError*)error;
    - (DCXMLElement*)rootElement;
    - (void)dumpAllItems;
@end
