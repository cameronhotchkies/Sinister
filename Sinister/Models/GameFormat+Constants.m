//
//  GameFormat+Constants.m
//  Sinister
//
//  Created by Cameron Hotchkies on 3/1/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

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
