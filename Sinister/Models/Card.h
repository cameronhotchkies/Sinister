//
//  Card.h
//  Sinister
//
//  Created by Cameron Hotchkies on 1/22/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Hand;

@interface Card : NSManagedObject

@property (nonatomic) int16_t rank;
@property (nonatomic) int16_t suit;
@property (nonatomic, retain) Hand *onFlop;
@property (nonatomic, retain) NSSet *onRiver;
@property (nonatomic, retain) NSSet *onTurn;
@property (nonatomic, retain) Hand *inHole;
@end

@interface Card (CoreDataGeneratedAccessors)

- (void)addOnRiverObject:(Hand *)value;
- (void)removeOnRiverObject:(Hand *)value;
- (void)addOnRiver:(NSSet *)values;
- (void)removeOnRiver:(NSSet *)values;

- (void)addOnTurnObject:(Hand *)value;
- (void)removeOnTurnObject:(Hand *)value;
- (void)addOnTurn:(NSSet *)values;
- (void)removeOnTurn:(NSSet *)values;

@end
