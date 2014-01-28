//
//  Site.h
//  Sinister
//
//  Created by Cameron Hotchkies on 1/27/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Hand, Player;

@interface Site : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *hands;
@property (nonatomic, retain) NSSet *players;
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

@end
