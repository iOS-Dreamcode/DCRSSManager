//
//  DCRSSManager.m
//  History
//
//  Created by Srikanth Sombhatla on 21/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DCRSSManager.h"
#import "DCRSSParser.h"

/* Notification */
NSString* DCRSSManagerUpdateAvailableNotification   = @"com.dc.dcrssmgr.updateavailable";
NSString* DCRSSManagerErrorKey                      = @"com.dc.dcrssmgr.key.error";
NSString* DCRSSManagerParserKey                     = @"com.dc.dcrssmgr.key.parser";
NSString* DCRSSManagerTagKey                        = @"com.dc.dcrssmgr.key.tag";
/* Notification */

static NSString* ERR_FETCHASYNC_DATATYPE_MISMATCH = @"fetchAsync expecting NSData or NSURL as dataSource.";

@interface DCRSSManager ()
    @property (nonatomic,retain) NSData* dataToParse;
    - (void)parseData:(NSData*)data withTag:(NSString*)tag;
    - (void)handleError:(NSError*)error withTag:(NSString*)tag;
@end

@implementation DCRSSManager
@synthesize dataToParse;

#pragma mark pimpl starts

/*!
 Handles data from url.
 Creates a par
 **/
- (void)parseData:(NSData*)data withTag:(NSString*)tag {
    DCRSSParser* p = [[[DCRSSParser alloc] initWith:data] autorelease];
    p.tag = tag;
    [p parse];
    if([p error]) {
        [self handleError:[p error] withTag:tag];
    } else {
        NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:tag,DCRSSManagerTagKey,
                                                                            p,DCRSSManagerParserKey,
                                                                            nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:DCRSSManagerUpdateAvailableNotification
                                                            object:nil userInfo:userInfo];
    }
}

- (void)handleError:(NSError*)error withTag:(NSString*)tag {
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:tag,DCRSSManagerTagKey,
                                                                        error,DCRSSManagerErrorKey,
                                                                        nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:DCRSSManagerUpdateAvailableNotification
                                                        object:nil userInfo:userInfo];
}

#pragma mark pimpl ends

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DC_NOTIF_PARSING_COMPLETED object:nil];
    self.dataToParse = nil;
    [super dealloc];
}

/*!
 Fetches contents of the specified \a dataSource asynchronously.
 dataSource is expected to be NSData or NSURL.
 Response for request is identified with \a tag.
 After completion it notifies with DCRSSManagerUpdateAvailableNotification notification.
 The observer of this notification is supplied with a DCRSSParser as the notification object.
 This parser object is deleted after notification handling is completed.
 Hence caller has to retain this parser object if intented to use it beyond notification handler.
 **/
- (void)fetchAsync:(id)dataSource withTag:(NSString*)tag {
    // TODO: Move this to feedprofile
    NSLog(@"%s",__PRETTY_FUNCTION__);
    if([dataSource isKindOfClass:[NSURL class]]) {
        NSURLRequest* urlReq = [[NSURLRequest alloc] initWithURL: dataSource];
        [NSURLConnection
         sendAsynchronousRequest:urlReq
         queue:[[NSOperationQueue alloc] init]
         completionHandler:^(NSURLResponse* response,
                             NSData* data,
                             NSError* error) {
             if(error) {
                 NSLog(@"Error %d",[error code]);
                 [self handleError:error withTag:tag];
             } else {
                 NSString* dstr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                 NSLog(@"data reveived %@",dstr);
                 NSLog(@"Got content with lenght:%d",[data length]);
                 [self parseData:data withTag:tag];
             }
         }];
    } else if([dataSource isKindOfClass:[NSData class]]) {
        self.dataToParse = [dataSource copy];
        [self parseData:dataToParse withTag:tag];
    } else {
        // TODO: raise error notification
        NSLog(@"%@",ERR_FETCHASYNC_DATATYPE_MISMATCH);
    }
}

@end

// eof