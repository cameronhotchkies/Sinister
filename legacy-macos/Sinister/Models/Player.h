//
//  Player.h
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

@class Action, Hand, Seat, Site;

@interface Player : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSSet *actions;
@property (nonatomic, retain) NSSet *playedHands;
@property (nonatomic, retain) NSSet *seats;
@property (nonatomic, retain) Site *site;
@end

@interface Player (CoreDataGeneratedAccessors)

- (void)addActionsObject:(Action *)value;
- (void)removeActionsObject:(Action *)value;
- (void)addActions:(NSSet *)values;
- (void)removeActions:(NSSet *)values;

- (void)addPlayedHandsObject:(Hand *)value;
- (void)removePlayedHandsObject:(Hand *)value;
- (void)addPlayedHands:(NSSet *)values;
- (void)removePlayedHands:(NSSet *)values;

- (void)addSeatsObject:(Seat *)value;
- (void)removeSeatsObject:(Seat *)value;
- (void)addSeats:(NSSet *)values;
- (void)removeSeats:(NSSet *)values;

@end
