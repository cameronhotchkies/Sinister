//
//  GameFormat.h
//  Sinister
//
//  Created by Cameron Hotchkies on 3/12/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Hand;

@interface GameFormat : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * bigBlind;
@property (nonatomic) int16_t flavor;
@property (nonatomic, retain) NSDecimalNumber * maxBuyin;
@property (nonatomic) int16_t maxPlayers;
@property (nonatomic, retain) NSDecimalNumber * minBuyin;
@property (nonatomic, retain) NSSet *hands;
@end

@interface GameFormat (CoreDataGeneratedAccessors)

- (void)addHandsObject:(Hand *)value;
- (void)removeHandsObject:(Hand *)value;
- (void)addHands:(NSSet *)values;
- (void)removeHands:(NSSet *)values;

@end
