//
//  GameFormat+Constants.m
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


#import "GameFormat+Constants.h"

@implementation GameFormat (Constants)

@end

@implementation SRSGameFormat

- (GameFormat*)toManagedObject:(NSManagedObjectContext*)context {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GameFormat"
                                              inManagedObjectContext:context];
    
    GameFormat* format = [[GameFormat alloc] initWithEntity:entity
                             insertIntoManagedObjectContext:context];
    
    format.bigBlind = self.bigBlind;
    format.maxPlayers = self.maxPlayers;
    format.flavor = self.flavor;
    format.minBuyin = self.minBuyin;
    format.maxBuyin = self.maxBuyin;
    
    return format;
}

- (BOOL)equals:(GameFormat*)gameFormat {
    if (self.flavor == gameFormat.flavor
        && self.maxPlayers == gameFormat.maxPlayers
        && [self.bigBlind compare:gameFormat.bigBlind] == NSOrderedSame
        && [self.maxBuyin compare:gameFormat.maxBuyin] == NSOrderedSame
        && [self.minBuyin compare:gameFormat.minBuyin] == NSOrderedSame) {
        return YES;
    }
    
    return NO;
}

//- (BOOL)equals:(SRSGameFormat*)gameFormat {
//    if (self.flavor == gameFormat.flavor
//        && self.maxPlayers == gameFormat.maxPlayers
//        && [self.bigBlind compare:gameFormat.bigBlind] == NSOrderedSame
//        && [self.maxBuyin compare:gameFormat.maxBuyin] == NSOrderedSame
//        && [self.minBuyin compare:gameFormat.minBuyin] == NSOrderedSame) {
//        return YES;
//    }
//    
//    return NO;
//}


@end
