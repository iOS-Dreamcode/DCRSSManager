//
//  DCRSSManager.m
//  History
//
//  Created by Srikanth Sombhatla on 21/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DCRSSManager.h"
#import "DCRSSParser.h"

NSString* DCRSSManagerUpdateAvailableNotification = @"com.dc.dcrssmgr.updateavailable";
static NSString* ERR_FETCHASYNC_DATATYPE_MISMATCH = @"fetchAsync expecting NSData or NSURL as dataSource.";

@interface DCRSSManager ()
    @property (nonatomic,retain) NSData* dataToParse;
    - (void)parseData:(NSData*)data withTag:(NSString*)tag;
@end

@implementation DCRSSManager
@synthesize dataToParse;

#pragma mark pimpl starts

/*!
 Handles data from url.
 Creates a par
 **/
- (void)parseData:(NSData*)data withTag:(NSString*)tag {
    // TODO: test with autorelease
    DCRSSParser* p = [[DCRSSParser alloc] initWith:data];
    p.tag = tag;
    [p parseSync];
    [[NSNotificationCenter defaultCenter] postNotificationName:DCRSSManagerUpdateAvailableNotification
                                                        object:p];
    [p release];
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