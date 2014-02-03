//
//  Seat.h
//  Sinister
//
//  Created by Cameron Hotchkies on 1/31/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Action, Card, Hand, Player;

@interface Seat : NSManagedObject

@property (nonatomic) BOOL isBigBlind;
@property (nonatomic) BOOL isDealer;
@property (nonatomic) BOOL isSmallBlind;
@property (nonatomic) int16_t position;
@property (nonatomic, retain) NSDecimalNumber * startingChips;
@property (nonatomic, retain) NSDecimalNumber * chipDelta;
@property (nonatomic, retain) Hand *hand;
@property (nonatomic, retain) NSSet *holeCards;
@property (nonatomic, retain) Player *player;
@property (nonatomic, retain) NSSet *actions;
@end

@interface Seat (CoreDataGeneratedAccessors)

- (void)addHoleCardsObject:(Card *)value;
- (void)removeHoleCardsObject:(Card *)value;
- (void)addHoleCards:(NSSet *)values;
- (void)removeHoleCards:(NSSet *)values;

- (void)addActionsObject:(Action *)value;
- (void)removeActionsObject:(Action *)value;
- (void)addActions:(NSSet *)values;
- (void)removeActions:(NSSet *)values;

@end
