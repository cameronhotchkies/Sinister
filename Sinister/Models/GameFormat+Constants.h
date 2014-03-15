//
//  GameFormat+Constants.h
//  Sinister
//
//  Created by Cameron Hotchkies on 3/1/14.
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

@interface SRSGameFormat : NSObject

@property (assign) GameFormatFlavor flavor;
@property (strong) NSDecimalNumber* bigBlind;
@property (strong) NSDecimalNumber* minBuyin;
@property (strong) NSDecimalNumber* maxBuyin;
@property (assign) NSInteger maxPlayers;
@property (strong) NSString* description;

- (GameFormat*)toManagedObject:(NSManagedObjectContext*)context;

- (BOOL)equals:(GameFormat*)format;

@end