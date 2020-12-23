//
//  Hand.h
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

@class Action, Card, GameFormat, Player, Seat, Site;

@interface Hand : NSManagedObject

@property (nonatomic) NSTimeInterval date;
@property (nonatomic, retain) NSString * game;
@property (nonatomic, retain) NSString * handID;
@property (nonatomic, retain) NSDecimalNumber * rake;
@property (nonatomic, retain) NSString * table;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSOrderedSet *actions;
@property (nonatomic, retain) Player *activePlayer;
@property (nonatomic, retain) NSSet *flop;
@property (nonatomic, retain) GameFormat *gameFormat;
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
