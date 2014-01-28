//
//  Seat.h
//  Sinister
//
//  Created by Cameron Hotchkies on 1/27/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Card, Hand, Player;

@interface Seat : NSManagedObject

@property (nonatomic) BOOL isBigBlind;
@property (nonatomic) BOOL isDealer;
@property (nonatomic) BOOL isSmallBlind;
@property (nonatomic) int16_t position;
@property (nonatomic, retain) NSDecimalNumber * startingChips;
@property (nonatomic, retain) Hand *hand;
@property (nonatomic, retain) Player *player;
@property (nonatomic, retain) NSSet *holeCards;
@end

@interface Seat (CoreDataGeneratedAccessors)

- (void)addHoleCardsObject:(Card *)value;
- (void)removeHoleCardsObject:(Card *)value;
- (void)addHoleCards:(NSSet *)values;
- (void)removeHoleCards:(NSSet *)values;

@end
