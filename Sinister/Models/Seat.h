//
//  Seat.h
//  Sinister
//
//  Created by Cameron Hotchkies on 3/1/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Action, Card, Hand, Player;

@interface Seat : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * chipDelta;
@property (nonatomic) BOOL isBigBlind;
@property (nonatomic) BOOL isDealer;
@property (nonatomic) BOOL isSmallBlind;
@property (nonatomic) int16_t position;
@property (nonatomic, retain) NSDecimalNumber * startingChips;
@property (nonatomic, retain) NSOrderedSet *actions;
@property (nonatomic, retain) Hand *hand;
@property (nonatomic, retain) NSSet *holeCards;
@property (nonatomic, retain) Player *player;
@end

@interface Seat (CoreDataGeneratedAccessors)

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
- (void)addHoleCardsObject:(Card *)value;
- (void)removeHoleCardsObject:(Card *)value;
- (void)addHoleCards:(NSSet *)values;
- (void)removeHoleCards:(NSSet *)values;

@end
