//
//  Hand.m
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


#import "Hand.h"
#import "Action.h"
#import "Card.h"
#import "GameFormat.h"
#import "Player.h"
#import "Seat.h"
#import "Site.h"


@implementation Hand

@dynamic date;
@dynamic game;
@dynamic handID;
@dynamic rake;
@dynamic table;
@dynamic notes;
@dynamic actions;
@dynamic activePlayer;
@dynamic flop;
@dynamic gameFormat;
@dynamic river;
@dynamic seats;
@dynamic site;
@dynamic turn;

@end
