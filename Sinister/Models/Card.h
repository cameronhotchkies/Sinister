//
//  Card.h
//  Sinister
//
//  Created by Cameron Hotchkies on 3/11/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Hand, Seat;

@interface Card : NSManagedObject

@property (nonatomic) int16_t rank;
@property (nonatomic) int16_t suit;
@property (nonatomic, retain) NSSet *inHole;
@property (nonatomic, retain) Hand *onFlop;
@property (nonatomic, retain) NSSet *onRiver;
@property (nonatomic, retain) NSSet *onTurn;
@end

@interface Card (CoreDataGeneratedAccessors)

- (void)addInHoleObject:(Seat *)value;
- (void)removeInHoleObject:(Seat *)value;
- (void)addInHole:(NSSet *)values;
- (void)removeInHole:(NSSet *)values;

- (void)addOnRiverObject:(Hand *)value;
- (void)removeOnRiverObject:(Hand *)value;
- (void)addOnRiver:(NSSet *)values;
- (void)removeOnRiver:(NSSet *)values;

- (void)addOnTurnObject:(Hand *)value;
- (void)removeOnTurnObject:(Hand *)value;
- (void)addOnTurn:(NSSet *)values;
- (void)removeOnTurn:(NSSet *)values;

@end
