//
//  Card+Constants.m
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


#import "Card+Constants.h"

@implementation Card (Constants)

+ (CardSuitType)suitFromChar:(char)c {
    CardSuitType s;
    switch (c) {
        case 'd':
            s = CardSuitDiamonds;
            break;
        case 'c':
            s = CardSuitClubs;
            break;
        case 'h':
            s = CardSuitHearts;
            break;
        case 's':
            s = CardSuitSpades;
            break;
    }
    return s;
}

+ (char)suitToChar:(CardSuitType)s {
    char c = '\0';
    switch (s) {
        case CardSuitDiamonds:
            c = 'd';
            break;
        case CardSuitClubs:
            c = 'c';
            break;
        case CardSuitHearts:
            c = 'h';
            break;
        case CardSuitSpades:
            c = 's';
            break;
    }
    
    return c;
}

+ (CardRankType)rankFromChar:(char)c {
    CardRankType r;
    
    switch (c) {
        case 'T':
            r = CardRankTen;
            break;
        case 'J':
            r = CardRankJack;
            break;
        case 'Q':
            r = CardRankQueen;
            break;
        case 'K':
            r = CardRankKing;
            break;
        case 'A':
            r = CardRankAce;
            break;
        default:
            r = [[NSString stringWithFormat:@"%c", c] intValue];;
            break;
    }
    
    return r;
}

+ (char)rankToChar:(CardRankType)r {
    switch (r) {
        case CardRankAce:
            return 'A';
        case CardRankKing:
            return 'K';
        case CardRankQueen:
            return 'Q';
        case CardRankJack:
            return 'J';
        case CardRankTen:
            return 'T';
        default:
            return '1' - 1 + r;
            
    }
}

- (NSString*)printable {
    return [NSString stringWithFormat:@"%c%c", [Card rankToChar:self.rank], [Card suitToChar:self.suit]];
}


@end
