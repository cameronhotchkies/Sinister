//
//  GameFormat+Constants.h
//  Sinister
//
//  Created by Cameron Hotchkies on 3/1/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import "GameFormat.h"


typedef NS_ENUM(NSInteger, GameFormatFlavor) {
    NLHE = 0,   // No Limit Hold'em
    LHE = 1,    // Limit Hold'em
    PLO = 2,    // Pot Limit Omaha
    LO = 3,     // Limit Omaha
    PLOHL = 4,  // Pot Limit Omaha Hi-Lo
    LOHL = 5    // Limit Omaha Hi-Lo
};

@interface GameFormat (Constants)

@end