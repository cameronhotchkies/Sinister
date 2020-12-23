//
//  Card+Constants.h
//  Sinister
//
//  Created by Cameron Hotchkies on 1/26/14.
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


#import "Card.h"

typedef NS_ENUM(NSInteger, CardRankType) {
    CardRankAce = 1,
    CardRankTwo = 2,
    CardRankThree = 3,
    CardRankFour = 4,
    CardRankFive = 5,
    CardRankSix = 6,
    CardRankSeven = 7,
    CardRankEight = 8,
    CardRankNine = 9,
    CardRankTen = 10,
    CardRankJack = 11,
    CardRankQueen = 12,
    CardRankKing = 13
};

typedef NS_ENUM(NSInteger, CardSuitType) {
    CardSuitClubs = 1,
    CardSuitSpades = 2,
    CardSuitHearts = 3,
    CardSuitDiamonds = 4,
};

@interface Card (Constants)

+ (CardSuitType)suitFromChar:(char)c;
+ (CardRankType)rankFromChar:(char)c;

+ (char)rankToChar:(CardRankType)r;
+ (char)suitToChar:(CardSuitType)s;

- (NSString*)printable;

@end
