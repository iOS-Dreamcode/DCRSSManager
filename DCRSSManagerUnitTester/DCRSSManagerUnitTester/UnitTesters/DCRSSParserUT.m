//
//  DCRSSParserUT.m
//  DCRSSManagerUnitTester
//
//  Created by Srikanth Sombhatla on 22/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// Control switches //

// Control switches //

// Log messages //
NSString* LOGMSG_TESTFAILED_PRETEXT = @"***test failed:";
// Log messages //

#import "DCRSSParserUT.h"
#import "DCRSSParser.h"
#import "DCRSSManager.h"

NSString* OFFLINE_TEST = @"rssofflinetest";
NSString* ONLINE_TEST  = @"rssonlinetest";
NSString* RSS_URL = @"http://www.google.com/doodles/doodles.xml";
//NSString* RSS_URL =@"http://feeds.feedburner.com/EngineerguycomPodcast?format=xml";

@interface DCRSSParserUT() {
    BOOL _isPrepared;
    DCRSSParser* _rssParser;
    DCRSSManager* _rssMgr;
}

- (void)UTLog:(NSString*)format,...;
- (void)UTLogTestFailed:(NSString*)format,...;
- (void)prepare;
- (void)validateOfflineTestForParser:(DCRSSParser*)parser;
- (void)handleParsingFinished:(NSNotification*)notification;

@end

@implementation DCRSSParserUT

#pragma mark pimpl_start

- (void)UTLog:(NSString*)format,... {
    va_list args;
    va_start(args, format);
    NSString* logMsg = [[NSString alloc] initWithFormat:format arguments:args];
    NSLog(@"%@",logMsg);
    [logMsg release];
    va_end(args);   
}

- (void)UTLogTestFailed:(NSString*)format,... {
    va_list args;
    va_start(args, format);
    NSString* newFormat = [NSString stringWithFormat:@"%@%@",LOGMSG_TESTFAILED_PRETEXT,format];
    [self UTLog:newFormat,args];    
    va_end(args);   
}

- (void)prepare {
    if(!_isPrepared) {
        _rssParser = [[DCRSSParser alloc] init];
        _rssMgr = [[DCRSSManager alloc] init];
        
        // RSS Parser notifications
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(handleParsingFinished:) name:DC_NOTIF_PARSING_COMPLETED object:nil];
        
        // RSS Manager notifications
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(handleParsingFinished:) name:DC_NOTIF_RSSMGR_UPDATE_AVAILABLE object:nil];
        _isPrepared = YES;
    }
}

- (void)validateOfflineTestForParser:(DCRSSParser*)parser {
    DCRSSParser* p = parser;
    
    NSDictionary* cinfo = [p channelInfo];
    NSLog(@"channel info:%@",cinfo);
    
    NSInteger c = [p count];
    [self UTLog:@"Total items:%d",c];
    
    DCXMLElement* item = [p firstItem];
    NSLog(@"first item's children \n%@",[item childrenNames]);
    
    NSArray* titles = [p titles];
    NSLog(@"all titles:\n%@",titles);
    
    // first item test
    NSString* f = [[[p firstItem] childWithName:@"title"] content];
    if([f isEqualToString: [titles objectAtIndex:0]]) {
        //[self UTLog:@"First item title is %@",f];
    } else {
        //[self UTLogTestFailed:@"First item title \n%@ \nnot matching \n%@",f,[titles objectAtIndex:0]];
    }
    NSLog(@"%s end",__PRETTY_FUNCTION__);
}

- (void)handleParsingFinished:(NSNotification*)notification {
    DCRSSParser* p = notification.object;
    if([p isKindOfClass:[DCRSSParser class]]) {
        if([[p identity] isEqualToString:OFFLINE_TEST]) {
            [self validateOfflineTestForParser:p];
        } else if([[p identity] isEqualToString:RSS_URL]) {
            [self validateOfflineTestForParser:p];
        }
    } else {
        [self UTLogTestFailed:@"expected obj is not a DCRSSParser kind of class"];
    }
}

#pragma mark pimpl_end

- (void)dealloc {
    [_rssParser release];
    [_rssMgr release];
    [super dealloc];
}

- (void)startOfflineParserTests {
    [self UTLog:@"%s",__PRETTY_FUNCTION__];
    [self prepare];
    NSString* xmlPath = [[NSBundle mainBundle] pathForResource:@"rss" ofType:@"xml"];
    NSData* xmlData = [[NSData alloc] initWithContentsOfFile:xmlPath];
    [_rssParser setXMLData:xmlData];
    [_rssParser setIdentity:OFFLINE_TEST];
    [_rssParser parseAsync];
}

- (void)startOnlineParserTests {
    [self UTLog:@"%s",__PRETTY_FUNCTION__];
    [self prepare];
    [_rssMgr fetchAsync:[NSURL URLWithString:RSS_URL]];
}

@end
