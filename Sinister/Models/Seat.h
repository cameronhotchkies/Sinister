//
//  Seat.h
//  Sinister
//
//  Created by Cameron Hotchkies on 2/10/14.
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
@property (nonatomic, retain) NSSet *actions;
@property (nonatomic, retain) Hand *hand;
@property (nonatomic, retain) NSSet *holeCards;
@property (nonatomic, retain) Player *player;
@end

@interface Seat (CoreDataGeneratedAccessors)

- (void)addActionsObject:(Action *)value;
- (void)removeActionsObject:(Action *)value;
- (void)addActions:(NSSet *)values;
- (void)removeActions:(NSSet *)values;

- (void)addHoleCardsObject:(Card *)value;
- (void)removeHoleCardsObject:(Card *)value;
- (void)addHoleCards:(NSSet *)values;
- (void)removeHoleCards:(NSSet *)values;

@end
