//
//  Site.h
//  Sinister
//
//  Created by Cameron Hotchkies on 3/12/14.
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
#import <CoreData/CoreData.h>

@class Hand, ParsedFile, Player;

@interface Site : NSManagedObject

@property (nonatomic, retain) NSString * account;
@property (nonatomic, retain) NSString * handHistoryLocation;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *hands;
@property (nonatomic, retain) NSSet *parsedHandFiles;
@property (nonatomic, retain) NSSet *players;
@end

@interface Site (CoreDataGeneratedAccessors)

- (void)addHandsObject:(Hand *)value;
- (void)removeHandsObject:(Hand *)value;
- (void)addHands:(NSSet *)values;
- (void)removeHands:(NSSet *)values;

- (void)addParsedHandFilesObject:(ParsedFile *)value;
- (void)removeParsedHandFilesObject:(ParsedFile *)value;
- (void)addParsedHandFiles:(NSSet *)values;
- (void)removeParsedHandFiles:(NSSet *)values;

- (void)addPlayersObject:(Player *)value;
- (void)removePlayersObject:(Player *)value;
- (void)addPlayers:(NSSet *)values;
- (void)removePlayers:(NSSet *)values;

@end
