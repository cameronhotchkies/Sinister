//
//  Player+Stats.h
//  Sinister
//
//  Created by Cameron Hotchkies on 1/27/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import "Player.h"

@interface Player (Stats)

- (NSInteger)handsPlayed;

- (NSDate*)mostRecentlySeen;

- (NSInteger)vpip;
- (NSInteger)pfr;

@end
