//
//  Seat.h
//  Sinister
//
//  Created by Cameron Hotchkies on 1/22/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Hand, Player;

@interface Seat : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * startingChips;
@property (nonatomic) int16_t position;
@property (nonatomic) BOOL isDealer;
@property (nonatomic) BOOL isBigBlind;
@property (nonatomic) BOOL isSmallBlind;
@property (nonatomic, retain) Player *player;
@property (nonatomic, retain) Hand *hand;

@end
