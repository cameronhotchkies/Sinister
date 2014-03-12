//
//  Action.h
//  Sinister
//
//  Created by Cameron Hotchkies on 3/11/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Hand, Player, Seat;

@interface Action : NSManagedObject

@property (nonatomic) int16_t action;
@property (nonatomic, retain) NSDecimalNumber * bet;
@property (nonatomic) int16_t street;
@property (nonatomic, retain) Hand *hand;
@property (nonatomic, retain) Player *player;
@property (nonatomic, retain) Seat *seat;

@end
