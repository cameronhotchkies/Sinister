//
//  SRSMavenHandFileParser.h
//  Sinister
//
//  Created by Cameron Hotchkies on 1/18/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Hand.h"

@interface SRSMavenHandFileParser : NSObject

@property (strong) NSMutableDictionary* cardCache;
@property (strong) NSMutableDictionary* playerCache;
@property (strong) NSMutableDictionary* parsedHandCache;

@property (strong) NSRegularExpression* actionPattern;
@property (strong) NSRegularExpression* seatPattern;
@property (strong) NSRegularExpression* smallBlindPattern;
@property (strong) NSRegularExpression* bigBlindPattern;
@property (strong) NSRegularExpression* titlePattern;

@property (strong) NSDateFormatter* dateFormat;


- (Hand*)parseHandData:(NSString*)handData forSite:(Site*)site inContext:(NSManagedObjectContext*)fastContext;
- (void)parseHands:(NSArray*)handDatas forSiteID:(NSManagedObjectID*)siteID inContext:(NSManagedObjectContext*)importContext;

- (void)initialize;

@end
