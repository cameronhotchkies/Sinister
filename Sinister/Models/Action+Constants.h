//
//  Action+Constants.h
//  Sinister
//
//  Created by Cameron Hotchkies on 1/21/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import "Action.h"

typedef NS_ENUM(NSInteger, ActionStreet) {
    ActionStreetPreflop = 0,
    ActionStreetFlop = 1,
    ActionStreetTurn = 2,
    ActionStreetRiver = 3,
    ActionStreetShowdown = 4
};

typedef NS_ENUM(NSInteger, ActionEvent) {
    ActionEventFold = 0,
    ActionEventCheck = 1,
    ActionEventPost = 2,
    ActionEventCall = 3,
    ActionEventBet = 4,
    ActionEventRaise = 5,
    ActionEventShow = 6,
    ActionEventRefunded = 7,
    ActionEventWins = 8
};

typedef NS_ENUM(NSInteger, ActionSupplement) {
    SupplementPostBigBlind = 1,
    SupplementPostSmallBlind = 2,
    SupplementPostAnte = 3
};

@interface Action (Constants)

@end
