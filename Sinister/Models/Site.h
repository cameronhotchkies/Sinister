//
//  Site.h
//  Sinister
//
//  Created by Cameron Hotchkies on 2/10/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Hand, ParsedFile, Player;

@interface Site : NSManagedObject

@property (nonatomic, retain) NSString * account;
@property (nonatomic, retain) NSString * handHistoryLocation;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *hands;
@property (nonatomic, retain) NSSet *players;
@property (nonatomic, retain) NSSet *parsedHandFiles;
@end

@interface Site (CoreDataGeneratedAccessors)

- (void)addHandsObject:(Hand *)value;
- (void)removeHandsObject:(Hand *)value;
- (void)addHands:(NSSet *)values;
- (void)removeHands:(NSSet *)values;

- (void)addPlayersObject:(Player *)value;
- (void)removePlayersObject:(Player *)value;
- (void)addPlayers:(NSSet *)values;
- (void)removePlayers:(NSSet *)values;

- (void)addParsedHandFilesObject:(ParsedFile *)value;
- (void)removeParsedHandFilesObject:(ParsedFile *)value;
- (void)addParsedHandFiles:(NSSet *)values;
- (void)removeParsedHandFiles:(NSSet *)values;

@end
