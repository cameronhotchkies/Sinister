//
//  Player.h
//  Sinister
//
//  Created by Cameron Hotchkies on 3/11/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Action, Hand, Seat, Site;

@interface Player : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSSet *actions;
@property (nonatomic, retain) NSSet *playedHands;
@property (nonatomic, retain) NSSet *seats;
@property (nonatomic, retain) Site *site;
@end

@interface Player (CoreDataGeneratedAccessors)

- (void)addActionsObject:(Action *)value;
- (void)removeActionsObject:(Action *)value;
- (void)addActions:(NSSet *)values;
- (void)removeActions:(NSSet *)values;

- (void)addPlayedHandsObject:(Hand *)value;
- (void)removePlayedHandsObject:(Hand *)value;
- (void)addPlayedHands:(NSSet *)values;
- (void)removePlayedHands:(NSSet *)values;

- (void)addSeatsObject:(Seat *)value;
- (void)removeSeatsObject:(Seat *)value;
- (void)addSeats:(NSSet *)values;
- (void)removeSeats:(NSSet *)values;

@end
