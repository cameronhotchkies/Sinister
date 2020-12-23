//
//  Seat.h
//  Sinister
//
//  Created by Cameron Hotchkies on 3/12/14.
//  Copyright (c) 2014 Srs Biznas. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


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
