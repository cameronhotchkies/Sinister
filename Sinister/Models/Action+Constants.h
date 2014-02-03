//
//  Action+Constants.h
//  Sinister
//
//  Created by Cameron Hotchkies on 1/21/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import "Action.h"

typedef NS_ENUM(NSInteger, ActionStageType) {
    ActionStagePreflop = 0,
    ActionStageFlop = 1,
    ActionStageTurn = 2,
    ActionStageRiver = 3,
    ActionStageShowdown = 4
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

@interface Action (Constants)

@end
