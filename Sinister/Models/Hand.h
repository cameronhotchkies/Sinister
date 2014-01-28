//
//  Hand.h
//  Sinister
//
//  Created by Cameron Hotchkies on 1/27/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Action, Card, Player, Seat, Site;

@interface Hand : NSManagedObject

@property (nonatomic) NSTimeInterval date;
@property (nonatomic, retain) NSString * game;
@property (nonatomic, retain) NSString * handID;
@property (nonatomic, retain) NSDecimalNumber * rake;
@property (nonatomic, retain) NSString * table;
@property (nonatomic, retain) NSOrderedSet *actions;
@property (nonatomic, retain) Player *activePlayer;
@property (nonatomic, retain) NSSet *flop;
@property (nonatomic, retain) Card *river;
@property (nonatomic, retain) NSOrderedSet *seats;
@property (nonatomic, retain) Site *site;
@property (nonatomic, retain) Card *turn;
@end

@interface Hand (CoreDataGeneratedAccessors)

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
@end
