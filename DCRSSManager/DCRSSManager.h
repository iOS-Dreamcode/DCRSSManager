//
//  DCRSSManager.h
//  History
//
//  Created by Srikanth Sombhatla on 21/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
extern NSString* DCRSSManagerUpdateAvailableNotification;
extern NSString* DCRSSManagerErrorKey;
extern NSString* DCRSSManagerParserKey;
extern NSString* DCRSSManagerTagKey;

@interface DCRSSManager : NSObject
- (void)fetchAsync:(id)dataSource withTag:(NSString*)tag;
@end
