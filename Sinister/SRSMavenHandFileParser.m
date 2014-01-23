//
//  SRSMavenHandFileParser.m
//  Sinister
//
//  Created by Cameron Hotchkies on 1/18/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import "SRSMavenHandFileParser.h"
#import "SRSAppDelegate.h"
#import "Seat.h"
#import "Player.h"
#import "Action+Constants.h"

@implementation SRSMavenHandFileParser

- (void) parseTitleLine:(NSString *)titleLine forHand:(Hand *)hand {
    NSRegularExpression *titleExp = [NSRegularExpression
                                     regularExpressionWithPattern:@"Hand #(\\d+-\\d+) - (\\d\\d\\d\\d-\\d\\d-\\d\\d \\d\\d:\\d\\d:\\d\\d)"
                                     options:NSRegularExpressionCaseInsensitive
                                     error:nil];
    
    NSTextCheckingResult *match = [titleExp firstMatchInString:titleLine
                                                       options:0
                                                         range:NSMakeRange(0, [titleLine length])];
    
    if (match != nil) {
        hand.handID = [titleLine substringWithRange:[match rangeAtIndex:1]];
        NSString* dateChunk = [titleLine substringWithRange:[match rangeAtIndex:2]];
        hand.date = [[NSDate dateWithString:dateChunk] timeInterval];
    }
}

- (void) parseGameDescriptionLine:(NSString *)descLine forHand:(Hand *)hand  {
    NSRegularExpression *descExp = [NSRegularExpression
                                     regularExpressionWithPattern:@"Game: (.*)"
                                     options:NSRegularExpressionCaseInsensitive
                                     error:nil];
    
    NSTextCheckingResult *match = [descExp firstMatchInString:descLine
                                                       options:0
                                                         range:NSMakeRange(0, [descLine length])];
    
    if (match != nil) {
        hand.game = [descLine substringWithRange:[match rangeAtIndex:1]];
    }
}

- (void) parseTableDescriptionLine:(NSString *)tableLine forHand:(Hand *)hand  {
    NSRegularExpression *tableExp = [NSRegularExpression
                                    regularExpressionWithPattern:@"Table: (.*)"
                                    options:NSRegularExpressionCaseInsensitive
                                    error:nil];
    
    NSTextCheckingResult *match = [tableExp firstMatchInString:tableLine
                                                      options:0
                                                        range:NSMakeRange(0, [tableLine length])];
    
    if (match != nil) {
        hand.table = [tableLine substringWithRange:[match rangeAtIndex:1]];
    }

}

- (void) parseSeatLines:(NSArray*)seatLines forHand:(Hand *)hand {
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    
    for (NSString* sl in seatLines) {
        NSRegularExpression *seatExp = [NSRegularExpression
                                         regularExpressionWithPattern:@"Seat (\\d): (.*) \\((\\d+(\\.\\d\\d)?)\\).*"
                                         options:NSRegularExpressionCaseInsensitive
                                         error:nil];

        NSTextCheckingResult *match = [seatExp firstMatchInString:sl
                                                          options:0
                                                            range:NSMakeRange(0, [sl length])];
        
        
        if (match != nil) {
            NSString* seatNum = [sl substringWithRange:[match rangeAtIndex:1]];
            NSString* playerName = [sl substringWithRange:[match rangeAtIndex:2]];
            NSString* startingAmount = [sl substringWithRange:[match rangeAtIndex:3]];
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Seat"
                                                      inManagedObjectContext:d.managedObjectContext];
            Seat* seat = [[Seat alloc] initWithEntity:entity
                       insertIntoManagedObjectContext:d.managedObjectContext];
            
            seat.position = [seatNum integerValue];
            
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            
            seat.startingChips = (NSDecimalNumber*) [f numberFromString:startingAmount];
            seat.player = [self findOrCreatePlayerWithName:playerName];
            seat.hand = hand;
            //[hand addSeatsObject:seat];
        }
        
    }
}

- (Player*)findOrCreatePlayerWithName:(NSString*)name {
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    NSManagedObjectContext *aMOC = d.managedObjectContext;
    
    // create the fetch request to get all Employees matching the IDs
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Player"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(name == %@)", name]];
    
    // make sure the results are sorted as well
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey: @"employeeID"
                                                       ascending:YES];
    
    [fetchRequest setSortDescriptors: [NSArray arrayWithObject:sd]];
    // Execute the fetch
    NSError *error;
    NSArray *players = [aMOC executeFetchRequest:fetchRequest error:&error];
    
    // TODO: check error
    
    Player *rv;
    
    if ([players count] == 0) {
        rv = [[Player alloc] initWithEntity:entity
             insertIntoManagedObjectContext:d.managedObjectContext];
        rv.name = name;
    } else {
        rv = [players objectAtIndex:0];
    }
    
    return rv;
}

- (void) parseDealerLine:(NSString*)dealerLine forHand:(Hand*)hand {
    NSRegularExpression *dealerExp = [NSRegularExpression
                                     regularExpressionWithPattern:@"(.*) has the dealer button"
                                     options:NSRegularExpressionCaseInsensitive
                                     error:nil];
    
    NSTextCheckingResult *match = [dealerExp firstMatchInString:dealerLine
                                                       options:0
                                                         range:NSMakeRange(0, [dealerLine length])];
    
    if (match != nil) {
        NSString* dealerName = [dealerLine substringWithRange:[match rangeAtIndex:1]];
        
        for (Seat* s in hand.seats) {
            if ([s.player.name isEqualToString:dealerName]) {
                s.isDealer = YES;
                break;
            }
        }
    }
}

- (void) parseSmallBlindLine:(NSString*)smallBlindLine forHand:(Hand*)hand {
    NSRegularExpression *sbExp = [NSRegularExpression
                                      regularExpressionWithPattern:@"(.*) posts small blind (\\d+(\\.\\d\\d)?)"
                                      options:NSRegularExpressionCaseInsensitive
                                      error:nil];
    
    NSTextCheckingResult *match = [sbExp firstMatchInString:smallBlindLine
                                                        options:0
                                                          range:NSMakeRange(0, [smallBlindLine length])];
    
    if (match != nil) {
        NSString* sbName = [smallBlindLine substringWithRange:[match rangeAtIndex:1]];
        
        for (Seat* s in hand.seats) {
            if ([s.player.name isEqualToString:sbName]) {
                s.isSmallBlind = YES;
                break;
            }
        }
    }
}

- (void) parseBigBlindLine:(NSString*)bigBlindLine forHand:(Hand*)hand {
    NSRegularExpression *bbExp = [NSRegularExpression
                                  regularExpressionWithPattern:@"(.*) posts big blind (\\d+(\\.\\d\\d)?)"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:nil];
    
    NSTextCheckingResult *match = [bbExp firstMatchInString:bigBlindLine
                                                    options:0
                                                      range:NSMakeRange(0, [bigBlindLine length])];
    
    if (match != nil) {
        NSString* bbName = [bigBlindLine substringWithRange:[match rangeAtIndex:1]];
        
        for (Seat* s in hand.seats) {
            if ([s.player.name isEqualToString:bbName]) {
                s.isBigBlind = YES;
                break;
            }
        }
    }
}

- (void)parseActionLine:(NSString*)actionLine forStage:(NSInteger)stage inHand:(Hand*)hand {
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    NSManagedObjectContext *aMOC = d.managedObjectContext;

    
    NSRegularExpression *axnExp = [NSRegularExpression
                                  regularExpressionWithPattern:@"(.*) (folds|calls (\\d+(\\.\\d\\d)?)|raises to (\\d+(\\.\\d\\d)?)|checks|bets (\\d+(\\.\\d\\d)?)|refunded (\\d+(\\.\\d\\d)?))"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:nil];
    
    NSTextCheckingResult *match = [axnExp firstMatchInString:actionLine
                                                    options:0
                                                      range:NSMakeRange(0, [actionLine length])];
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];

    if (match != nil) {
        NSString* playerName = [actionLine substringWithRange:[match rangeAtIndex:1]];

        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Action"
                                                  inManagedObjectContext:aMOC];
        
        Action* a = [[Action alloc] initWithEntity:entity
                    insertIntoManagedObjectContext:aMOC];

        for (Seat* s in hand.seats) {
            if ([s.player.name isEqualToString:playerName]) {
                
                
                Player* p = s.player;
                a.player = p;
                
                NSString* actionS = [actionLine substringWithRange:[match rangeAtIndex:2]];
                
                if ([actionS isEqualToString:@"folds"]) {
                    a.action = ActionEventFold;
                    a.bet = [NSDecimalNumber zero];
                    
                } else if ([actionS hasPrefix:@"calls "]) {
                    a.action = ActionEventCall;                    
                    a.bet = (NSDecimalNumber*)[f numberFromString:[actionS substringFromIndex:6]];
                } else if ([actionS hasPrefix:@"raises to "]) {
                    a.action = ActionEventRaise;
                    a.bet = (NSDecimalNumber*)[f numberFromString:[actionS substringFromIndex:10]];
                } else if ([actionS hasPrefix:@"checks"]) {
                    a.action = ActionEventCheck;
                    a.bet = [NSDecimalNumber zero];
                } else if ([actionS hasPrefix:@"bets"]) {
                    a.action = ActionEventBet;
                    a.bet = (NSDecimalNumber*)[f numberFromString:[actionS substringFromIndex:5]];
                } else if ([actionS hasPrefix:@"refunded"]) {
                    a.action = ActionEventRefunded;
                    a.bet = (NSDecimalNumber*)[f numberFromString:[actionS substringFromIndex:9]];
                } else {
                    assert(NO);
                }
                
                break;
            }
        }
        
        a.stage = stage;
        a.hand = hand;
        
    }
}

- (NSRange)rangeForStage:(ActionStageType)s inHand:(NSString*)fullHand {
    NSUInteger start = NSNotFound;
    NSUInteger stop = NSNotFound;
    
    NSUInteger rakeLoc = [fullHand rangeOfString:@"\nRake ("].location;
    assert(rakeLoc != NSNotFound);
    
    switch (s) {
        case ActionStagePreflop:
            start = [fullHand rangeOfString:@"** Hole Cards **"].location;
            stop = [fullHand rangeOfString:@"** Flop **"].location;
            stop = MIN(rakeLoc, stop);
            break;
        case ActionStageFlop:
            start = [fullHand rangeOfString:@"** Flop **"].location;
            stop = [fullHand rangeOfString:@"** Turn **"].location;
            break;
        case ActionStageTurn:
            start = [fullHand rangeOfString:@"** Turn **"].location;
            stop = [fullHand rangeOfString:@"** River **"].location;
            break;
        case ActionStageRiver:
            start = [fullHand rangeOfString:@"** River **"].location;
            stop = rakeLoc;
            break;
    }
    
    stop = MIN(rakeLoc, stop);
    return NSMakeRange(start, stop - start);
}

- (void)parseHandData:(NSString*)handData forPreflopWithRange:(NSRange)preflopRange withHand:(Hand*)hand {
    NSString* preflopData = [handData substringWithRange:preflopRange];
    NSArray* preflopAction = [preflopData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    if ([[preflopAction objectAtIndex:1] hasPrefix:@"Dealt to "]) {
        preflopAction = [preflopAction subarrayWithRange:NSMakeRange(2, preflopAction.count - 2)];
        // TODO: extract active player
    } else {
        preflopAction = [preflopAction subarrayWithRange:NSMakeRange(1, preflopAction.count - 1)];
    }
    
    for (NSString* actionLine in preflopAction) {
        [self parseActionLine:actionLine forStage:ActionStagePreflop inHand:hand];
    }

}

- (void)parseHandData:(NSString*)handData forFlopWithRange:(NSRange)flopRange withHand:(Hand*)hand {
    NSString* flopData = [handData substringWithRange:flopRange];
    NSArray* flopAction = [flopData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    // TODO: parse flop cards
    flopAction = [flopAction subarrayWithRange:NSMakeRange(1, flopAction.count - 1)];
    
    for (NSString* actionLine in flopAction) {
        [self parseActionLine:actionLine forStage:ActionStageFlop inHand:hand];
    }
}

- (void)parseHandData:(NSString*)handData forTurnWithRange:(NSRange)turnRange withHand:(Hand*)hand {
    NSString* turnData = [handData substringWithRange:turnRange];
    NSArray* turnAction = [turnData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    // TODO: parse turn cards
    turnAction = [turnAction subarrayWithRange:NSMakeRange(1, turnAction.count - 1)];
    
    for (NSString* actionLine in turnAction) {
        [self parseActionLine:actionLine forStage:ActionStageTurn inHand:hand];
    }
}

- (void)parseHandData:(NSString*)handData forRiverWithRange:(NSRange)riverRange withHand:(Hand*)hand {
    NSString* riverData = [handData substringWithRange:riverRange];
    NSArray* riverAction = [riverData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    // TODO: parse river cards
    riverAction = [riverAction subarrayWithRange:NSMakeRange(1, riverAction.count - 1)];
    
    for (NSString* actionLine in riverAction) {
        [self parseActionLine:actionLine forStage:ActionStageRiver inHand:hand];
    }
}

- (Hand*) parseHandData:(NSString*)handData {
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Hand"
                                              inManagedObjectContext:d.managedObjectContext];
    Hand *rv = [[Hand alloc] initWithEntity:entity
         insertIntoManagedObjectContext:d.managedObjectContext];
    
    NSArray* hdLines = [handData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSString *titleLine = [hdLines objectAtIndex:0];
    
    [self parseTitleLine:titleLine forHand:rv];
    [self parseGameDescriptionLine:[hdLines objectAtIndex:1] forHand:rv];
    // Line 2 is the Site name
    [self parseTableDescriptionLine:[hdLines objectAtIndex:3] forHand:rv];
    
    int seatsEndRange = 4;
    for (int i = 4; i < hdLines.count; i ++) {
        NSString* hdl = [hdLines objectAtIndex:i];
        if ([hdl hasPrefix:@"Seat "]) {
            seatsEndRange = i;
        } else {
            break;
        }
    }
    
    {
    NSArray *seatsLines = [hdLines subarrayWithRange:NSMakeRange(4, seatsEndRange - 3)];
    [self parseSeatLines:seatsLines forHand:rv];
    
    NSString* dealerLine = [hdLines objectAtIndex:seatsEndRange + 1];
    [self parseDealerLine:dealerLine forHand:rv];
    
    NSString* smallBlindLine = [hdLines objectAtIndex:seatsEndRange + 2];
    [self parseSmallBlindLine:smallBlindLine forHand:rv];
    
    NSString* bigBlindLine = [hdLines objectAtIndex:seatsEndRange + 3];
    [self parseBigBlindLine:bigBlindLine forHand:rv];
    }
    
    NSString* hs = [hdLines objectAtIndex:seatsEndRange + 4];
    if (![hs isEqualToString:@"** Hole Cards **"]) {
        assert(NO);
    }
    
    NSRange preflopRange = [self rangeForStage:ActionStagePreflop inHand:handData];
    [self parseHandData:handData forPreflopWithRange:preflopRange withHand:rv];
    
    NSRange flopRange = [self rangeForStage:ActionStageFlop inHand:handData];
    
    if (flopRange.location != NSNotFound) {
        [self parseHandData:handData forFlopWithRange:flopRange withHand:rv];
    }
    
    NSRange turnRange = [self rangeForStage:ActionStageTurn inHand:handData];
    
    if (turnRange.location != NSNotFound) {
        [self parseHandData:handData forTurnWithRange:turnRange withHand:rv];
    }
    
    NSRange riverRange = [self rangeForStage:ActionStageRiver inHand:handData];
    if (riverRange.location != NSNotFound) {
        [self parseHandData:handData forRiverWithRange:riverRange withHand:rv];
    }
    
    for (NSString* rakeOpt in [hdLines reverseObjectEnumerator]) {
        if ([rakeOpt hasPrefix:@"Rake ("]) {
            NSString* rakeValue = [rakeOpt substringFromIndex:6];
            break;
        }
    }
    
    return rv;
}

@end
