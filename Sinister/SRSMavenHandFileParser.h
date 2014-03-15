//
//  SRSMavenHandFileParser.h
//  Sinister
//
//  Created by Cameron Hotchkies on 1/18/14.
//  Copyright (c) 2014 Srs Biznas. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


#import <Foundation/Foundation.h>

#import "Hand.h"

@interface SRSMavenHandFileParser : NSObject

@property (strong) NSMutableDictionary* cardCache;
@property (strong) NSMutableDictionary* playerCache;
@property (strong) NSMutableDictionary* parsedHandCache;
@property (strong) NSMutableArray* gameFormats;

@property (strong) NSRegularExpression* actionPattern;
@property (strong) NSRegularExpression* seatPattern;
@property (strong) NSRegularExpression* smallBlindPattern;
@property (strong) NSRegularExpression* bigBlindPattern;
@property (strong) NSRegularExpression* titlePattern;

@property (strong) NSDateFormatter* dateFormat;


- (Hand*)parseHandData:(NSString*)handData forSite:(Site*)site inContext:(NSManagedObjectContext*)fastContext;
- (void)parseHands:(NSArray*)handDatas forSiteID:(NSManagedObjectID*)siteID inContext:(NSManagedObjectContext*)importContext;

- (void)initialize:(NSManagedObjectContext*)context;

@end
