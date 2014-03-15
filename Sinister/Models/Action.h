//
//  Action.h
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

@class Hand, Player, Seat;

@interface Action : NSManagedObject

@property (nonatomic) int16_t action;
@property (nonatomic, retain) NSDecimalNumber * bet;
@property (nonatomic) int16_t street;
@property (nonatomic) int16_t supplement;
@property (nonatomic, retain) Hand *hand;
@property (nonatomic, retain) Player *player;
@property (nonatomic, retain) Seat *seat;

@end
