//
//  Card+Constants.h
//  Sinister
//
//  Created by Cameron Hotchkies on 1/26/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

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

@end
