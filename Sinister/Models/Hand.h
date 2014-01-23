//
//  Hand.h
//  Sinister
//
//  Created by Cameron Hotchkies on 1/22/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Action, Card, Player, Seat;

@interface Hand : NSManagedObject

@property (nonatomic) NSTimeInterval date;
@property (nonatomic, retain) NSString * game;
@property (nonatomic, retain) NSString * handID;
@property (nonatomic, retain) NSString * site;
@property (nonatomic, retain) NSString * table;
@property (nonatomic, retain) NSSet *flop;
@property (nonatomic, retain) NSOrderedSet *seats;
@property (nonatomic, retain) Card *river;
@property (nonatomic, retain) Card *turn;
@property (nonatomic, retain) Player *activePlayer;
@property (nonatomic, retain) NSSet *holeCards;
@property (nonatomic, retain) NSOrderedSet *actions;
@end

@interface Hand (CoreDataGeneratedAccessors)

- (void)addFlopObject:(Card *)value;
- (void)removeFlopObject:(Card *)value;
- (void)addFlop:(NSSet *)values;
- (void)removeFlop:(NSSet *)values;

- (void)insertObject:(Seat *)value inSeatsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromSeatsAtIndex:(NSUInteger)idx;
- (void)insertSeats:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeSeatsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInSeatsAtIndex:(NSUInteger)idx withObject:(Seat *)value;
- (void)replaceSeatsAtIndexes:(NSIndexSet *)indexes withSeats:(NSArray *)values;
- (void)addSeatsObject:(Seat *)value;
- (void)removeSeatsObject:(Seat *)value;
- (void)addSeats:(NSOrderedSet *)values;
- (void)removeSeats:(NSOrderedSet *)values;
- (void)addHoleCardsObject:(Card *)value;
- (void)removeHoleCardsObject:(Card *)value;
- (void)addHoleCards:(NSSet *)values;
- (void)removeHoleCards:(NSSet *)values;

- (void)insertObject:(Action *)value inActionsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromActionsAtIndex:(NSUInteger)idx;
- (void)insertActions:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeActionsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInActionsAtIndex:(NSUInteger)idx withObject:(Action *)value;
- (void)replaceActionsAtIndexes:(NSIndexSet *)indexes withActions:(NSArray *)values;
- (void)addActionsObject:(Action *)value;
- (void)removeActionsObject:(Action *)value;
- (void)addActions:(NSOrderedSet *)values;
- (void)removeActions:(NSOrderedSet *)values;
@end
