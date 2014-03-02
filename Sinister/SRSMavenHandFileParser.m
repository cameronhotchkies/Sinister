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
#import "Site.h"
#import "Card+Constants.h"

@interface SRSTitleData : NSObject

@property (strong) NSString* handID;
@property (assign) NSTimeInterval date;

@end
@implementation SRSTitleData
@end

@implementation SRSMavenHandFileParser

- (SRSTitleData*)parseTitleLine:(NSString *)titleLine {
    NSRegularExpression *titleExp = [NSRegularExpression
                                     regularExpressionWithPattern:@"Hand #(\\d+-\\d+) - (\\d\\d\\d\\d-\\d\\d-\\d\\d \\d\\d:\\d\\d:\\d\\d)"
                                     options:NSRegularExpressionCaseInsensitive
                                     error:nil];
    
    NSTextCheckingResult *match = [titleExp firstMatchInString:titleLine
                                                       options:0
                                                         range:NSMakeRange(0, [titleLine length])];
    
    if (match != nil) {
        SRSTitleData* title = [[SRSTitleData alloc] init];
        
        title.handID = [titleLine substringWithRange:[match rangeAtIndex:1]];
        NSString* dateChunk = [titleLine substringWithRange:[match rangeAtIndex:2]];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        NSDate* d = [dateFormat dateFromString:dateChunk];
        title.date = [d timeIntervalSince1970];
        
        return title;
    }
    
    return nil;
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

- (void) parseSeatLines:(NSArray*)seatLines
                forHand:(Hand *)hand
              inContext:(NSManagedObjectContext*)fastContext {
    
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
                                                      inManagedObjectContext:fastContext];
            Seat* seat = [[Seat alloc] initWithEntity:entity
                       insertIntoManagedObjectContext:fastContext];
            
            seat.position = [seatNum integerValue];
            
            seat.startingChips = (NSDecimalNumber*) [self.moneyFormatter numberFromString:startingAmount];
            seat.player = [self findOrCreatePlayerWithName:playerName forSite:hand.site inContext:fastContext];
            seat.hand = hand;
            //[hand addSeatsObject:seat];
        }
        
    }
}

// Don't create
- (Site*)findSiteWithName:(NSString*)name
                inContext:(NSManagedObjectContext*)fastContext {
    
    // create the fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Site"
                                              inManagedObjectContext:fastContext];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(name == %@)", name]];
    
    // make sure the results are sorted as well
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey: @"name"
                                                       ascending:YES];
    
    [fetchRequest setSortDescriptors: [NSArray arrayWithObject:sd]];
    // Execute the fetch
    NSError *error;
    NSArray *sites = [fastContext executeFetchRequest:fetchRequest error:&error];
    
    // TODO: check error
    
    Site *rv = nil;
    
    if ([sites count] != 0) {
        rv = [sites objectAtIndex:0];
    }
    
    return rv;
}



- (Card*)findOrCreateCardWithSuit:(CardSuitType)s
                          andRank:(CardRankType)r
                        inContext:(NSManagedObjectContext*)fastContext {
    
    NSInteger cardKey = s << 4 | r;
    
    Card* cached = [self.cardCache objectForKey:[NSNumber numberWithInteger:cardKey]];
    if (cached != nil) {
        return cached;
    }
    
    // create the fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card"
                                              inManagedObjectContext:fastContext];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(rank == %d and suit == %d)", r, s]];
    
    // make sure the results are sorted as well
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey: @"rank"
                                                       ascending:YES];
    
    [fetchRequest setSortDescriptors: [NSArray arrayWithObject:sd]];
    // Execute the fetch
    NSError *error;
    NSArray *cards = [fastContext executeFetchRequest:fetchRequest error:&error];
    
    // TODO: check error
    
    Card *rv;
    
    if ([cards count] == 0) {
        rv = [[Card alloc] initWithEntity:entity
             insertIntoManagedObjectContext:fastContext];
        rv.rank = r;
        rv.suit = s;
        
    } else {
        rv = [cards objectAtIndex:0];
    }
    
    [self.cardCache setObject:rv forKey:[NSNumber numberWithInteger:cardKey]];
    
    return rv;
}

- (Player*)findOrCreatePlayerWithName:(NSString*)name
                              forSite:(Site*)site
                            inContext:(NSManagedObjectContext*)fastContext {
    Player* cached = [self.playerCache objectForKey:name];
    
    if (cached != nil) {
        return cached;
    }
    
    // create the fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Player"
                                              inManagedObjectContext:fastContext];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(name == %@ and site.name == %@)", name, site.name]];
    
    // make sure the results are sorted as well
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey: @"name"
                                                       ascending:YES];
    
    [fetchRequest setSortDescriptors: [NSArray arrayWithObject:sd]];
    // Execute the fetch
    NSError *error;
    NSArray *players = [fastContext executeFetchRequest:fetchRequest error:&error];
    
    // TODO: check error
    
    Player *rv;
    
    if ([players count] == 0) {
        rv = [[Player alloc] initWithEntity:entity
             insertIntoManagedObjectContext:fastContext];
        rv.name = name;
        rv.site = site;
    
    } else {
        rv = [players objectAtIndex:0];
    }
    
    [self.playerCache setObject:rv forKey:name];
    
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

- (void) parseSmallBlindLine:(NSString*)smallBlindLine
                     forHand:(Hand*)hand
                   inContext:(NSManagedObjectContext*)fastContext {
    NSRegularExpression *sbExp = [NSRegularExpression
                                      regularExpressionWithPattern:@"(.*) posts small blind (\\d+(\\.\\d\\d)?)"
                                      options:NSRegularExpressionCaseInsensitive
                                      error:nil];
    
    NSTextCheckingResult *match = [sbExp firstMatchInString:smallBlindLine
                                                        options:0
                                                          range:NSMakeRange(0, [smallBlindLine length])];
    
    if (match != nil) {
        
        NSString* sbName = [smallBlindLine substringWithRange:[match rangeAtIndex:1]];
        NSString* ante = [smallBlindLine substringWithRange:[match rangeAtIndex:2]];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Action"
                                                  inManagedObjectContext:fastContext];
        
        for (Seat* s in hand.seats) {
            if ([s.player.name isEqualToString:sbName]) {
                s.isSmallBlind = YES;
                Action* sbAction = [[Action alloc] initWithEntity:entity
                                   insertIntoManagedObjectContext:fastContext];
                
                sbAction.action = ActionEventPost;
                NSDecimalNumber* dn = [NSDecimalNumber decimalNumberWithString:ante];
                sbAction.bet = dn;
                
                sbAction.hand = hand;
                sbAction.seat = s;
                sbAction.player = s.player;
                
                
                break;
            }
        }
    }
}

- (void) parseBigBlindLine:(NSString*)bigBlindLine
                   forHand:(Hand*)hand
                 inContext:(NSManagedObjectContext*)fastContext {
    NSRegularExpression *bbExp = [NSRegularExpression
                                  regularExpressionWithPattern:@"(.*) posts big blind (\\d+(\\.\\d\\d)?)"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:nil];
    
    NSTextCheckingResult *match = [bbExp firstMatchInString:bigBlindLine
                                                    options:0
                                                      range:NSMakeRange(0, [bigBlindLine length])];
    
    if (match != nil) {
       
        NSString* bbName = [bigBlindLine substringWithRange:[match rangeAtIndex:1]];
        
        NSString* ante = [bigBlindLine substringWithRange:[match rangeAtIndex:2]];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Action"
                                                  inManagedObjectContext:fastContext];

        
        for (Seat* s in hand.seats) {
            if ([s.player.name isEqualToString:bbName]) {
                s.isBigBlind = YES;
                Action* bbAction = [[Action alloc] initWithEntity:entity
                                   insertIntoManagedObjectContext:fastContext];
                
                bbAction.action = ActionEventPost;
                bbAction.bet = [NSDecimalNumber decimalNumberWithString:ante];
                
                bbAction.hand = hand;
                bbAction.seat = s;
                bbAction.player = s.player;
                break;
            }
        }
    }
}

- (CardSuitType)charToSuit:(char) c {
    CardSuitType s;
    switch (c) {
        case 'd':
            s = CardSuitDiamonds;
            break;
        case 'c':
            s = CardSuitClubs;
            break;
        case 'h':
            s = CardSuitHearts;
            break;
        case 's':
            s = CardSuitSpades;
            break;
    }
    return s;
}

- (CardRankType)charToRank:(char) c {
    CardRankType r;
    
    switch (c) {
        case 'T':
            r = CardRankTen;
            break;
        case 'J':
            r = CardRankJack;
            break;
        case 'Q':
            r = CardRankQueen;
            break;
        case 'K':
            r = CardRankKing;
            break;
        case 'A':
            r = CardRankAce;
            break;
        default:
            r = [[NSString stringWithFormat:@"%c", c] intValue];;
            break;
    }
    
    return r;
}

- (void)parseActionLine:(NSString*)actionLine
               forStage:(NSInteger)stage
                 inHand:(Hand*)hand
              inContext:(NSManagedObjectContext*)fastContext {
   
    NSRegularExpression *axnExp = self.actionPattern;
    
    NSTextCheckingResult *match = [axnExp firstMatchInString:actionLine
                                                    options:0
                                                      range:NSMakeRange(0, [actionLine length])];
    
    if (match != nil) {
        NSString* playerName = [actionLine substringWithRange:[match rangeAtIndex:1]];

        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Action"
                                                  inManagedObjectContext:fastContext];
        
        Action* a = [[Action alloc] initWithEntity:entity
                    insertIntoManagedObjectContext:fastContext];

        for (Seat* s in hand.seats) {
            if ([s.player.name isEqualToString:playerName]) {
                
                
                Player* p = s.player;
                a.player = p;
                a.seat = s;
                
                NSString* actionS = [actionLine substringWithRange:[match rangeAtIndex:2]];
                
                if ([actionS isEqualToString:@"folds"]) {
                    a.action = ActionEventFold;
                    a.bet = [NSDecimalNumber zero];
                    
                } else if ([actionS hasPrefix:@"calls "]) {
                    a.action = ActionEventCall;                    
                    a.bet = (NSDecimalNumber*)[self.moneyFormatter numberFromString:[actionS substringFromIndex:6]];
                } else if ([actionS hasPrefix:@"raises to "]) {
                    a.action = ActionEventRaise;
                    a.bet = (NSDecimalNumber*)[self.moneyFormatter numberFromString:[actionS substringFromIndex:10]];
                } else if ([actionS hasPrefix:@"checks"]) {
                    a.action = ActionEventCheck;
                    a.bet = [NSDecimalNumber zero];
                } else if ([actionS hasPrefix:@"bets"]) {
                    a.action = ActionEventBet;
                    a.bet = (NSDecimalNumber*)[self.moneyFormatter numberFromString:[actionS substringFromIndex:5]];
                } else if ([actionS hasPrefix:@"shows"]) {
                    a.action = ActionEventShow;
                    a.bet = [NSDecimalNumber zero];
                    // Set hole cards
                    NSRange holeRange = NSMakeRange(7, 5);
                    NSString* cardPart = [actionS substringWithRange:holeRange];
                    NSArray* holeCardsStr = [cardPart componentsSeparatedByString:@" "];
                    for (NSString* c in holeCardsStr) {
                        CardRankType r;
                        CardSuitType suit;
                        
                        r = [self charToRank:[c characterAtIndex:0]];
                        suit = [self charToSuit:[c characterAtIndex:1]];
                        
                        Card *c = [self findOrCreateCardWithSuit:suit andRank:r inContext:fastContext];
                        [s addHoleCardsObject:c];
                    }
                } else if ([actionS hasPrefix:@"refunded"]) {
                    a.action = ActionEventRefunded;
                    a.bet = (NSDecimalNumber*)[self.moneyFormatter numberFromString:[actionS substringFromIndex:9]];
                } else if ([actionS hasPrefix:@"wins Pot ("]) {
                    a.action = ActionEventWins;
                    NSRange betRange = NSMakeRange(10, actionS.length - 11);
                    NSString* betPart = [actionS substringWithRange:betRange];
                    a.bet = [NSDecimalNumber decimalNumberWithString:betPart];
                    //(NSDecimalNumber*)[self.moneyFormatter numberFromString:];
                } else if ([actionS hasPrefix:@"splits Pot ("]) {
                    a.action = ActionEventWins;
                    NSRange betRange = NSMakeRange(12, actionS.length - 13);
                    NSString* betPart = [actionS substringWithRange:betRange];
                    a.bet = [NSDecimalNumber decimalNumberWithString:betPart];
                    //(NSDecimalNumber*)[self.moneyFormatter numberFromString:];
                } else if ([actionS hasPrefix:@"wins Side Pot"] || [actionS hasPrefix:@"wins Main Pot"]) {
                    a.action = ActionEventWins;
                    NSRange betRange1 = [actionS rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"("]
                                                                 options:NSCaseInsensitiveSearch];
                    NSRange betRange2 = [actionS rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@")"]
                                                                 options:NSCaseInsensitiveSearch];
                    NSRange betRange = NSMakeRange(betRange1.location + 1, betRange2.location - betRange1.location - 1);
                    
                    NSString* betString = [actionS substringWithRange:betRange];
                    a.bet = [NSDecimalNumber decimalNumberWithString:betString];
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

- (NSArray*)rangesForShowdownInHand:(NSString*)fullHand {
    NSRange showdownStart = [fullHand rangeOfString:@"Show Down **"
                                            options:NSCaseInsensitiveSearch];
    
    NSMutableArray* showdowns = [NSMutableArray array];
    
    NSInteger handLength = fullHand.length;
    
    while (showdownStart.location != NSNotFound) {
        NSRange remainder = NSMakeRange(showdownStart.location, handLength - showdownStart.location);
        NSRange eol = [fullHand rangeOfString:@"\n" options:NSCaseInsensitiveSearch range:remainder];
        NSRange sol = [fullHand rangeOfString:@"\n" options:NSBackwardsSearch range:NSMakeRange(0, remainder.location)];
        NSString* sdToEnd = [fullHand substringWithRange:NSMakeRange(eol.location + 1, handLength - eol.location - 1)];
        
        
        // Showdowns always end with a rake
        NSRange rakeRange = [sdToEnd rangeOfString:@"Rake ("];
//        NSString* sdText = [sdToEnd substringToIndex:rakeRange.location];
        
        NSRange sdRange = NSMakeRange(sol.location + 1, rakeRange.location + (eol.location - sol.location));
        
        [showdowns addObject:[NSValue valueWithRange:sdRange]];
        
        showdownStart = [fullHand rangeOfString:@"Show Down **"
                                        options:NSCaseInsensitiveSearch
                                          range:NSMakeRange(eol.location, handLength - eol.location)];
    }
//    if (splitByShowdowns.count == 1) {
//        // Just return an empty array, there are no showdowns
//        return [NSArray array];
//    } else {
//        NSString* compOne = [splitByShowdowns objectAtIndex:0];
//        NSRange sdEnd = [compOne rangeOfString:@"**" options:NSBackwardsSearch];
//        stop = sdEnd.location;
//    }

    return showdowns;
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
        {
            start = [fullHand rangeOfString:@"** River **"].location;
            NSArray* splitByShowdowns = [fullHand componentsSeparatedByString:@"Show Down **"];
            if (splitByShowdowns.count == 1) {
                stop = NSNotFound;
            } else {
                NSString* compOne = [splitByShowdowns objectAtIndex:0];
                NSRange sdEnd = [compOne rangeOfString:@"**" options:NSBackwardsSearch];
                stop = sdEnd.location;
            }
            break;
        }
        case ActionStageShowdown:
            // This shouldn't be called anymore
            // There's a separate function that handles multiple showdowns
//            assert(NO);
            start = [fullHand rangeOfString:@"** Pot Show Down **"].location;
            stop = rakeLoc;
            break;
    }
    
    stop = MIN(rakeLoc, stop);
    return NSMakeRange(start, stop - start);
}

- (void)parseHandData:(NSString*)handData
  forPreflopWithRange:(NSRange)preflopRange
             withHand:(Hand*)hand
            inContext:(NSManagedObjectContext*)fastContext {
    
    NSString* preflopData = [handData substringWithRange:preflopRange];
    NSArray* preflopAction = [preflopData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    if ([[preflopAction objectAtIndex:1] hasPrefix:@"Dealt to "]) {
        NSString* dealtCandidate = [preflopAction objectAtIndex:1];
        
        preflopAction = [preflopAction subarrayWithRange:NSMakeRange(2, preflopAction.count - 2)];
        // extract active player
        
        
        NSString* dealtPart = [dealtCandidate substringFromIndex:9];
        NSString* activeName = [dealtPart substringToIndex:dealtPart.length - 8];
        NSString* holeString = [dealtPart substringFromIndex:dealtPart.length - 7];
        NSRange hole1R = NSMakeRange(1, 2);
        NSRange hole2R = NSMakeRange(4, 2);

        NSString* h1 = [holeString substringWithRange:hole1R];
        NSString* h2 = [holeString substringWithRange:hole2R];
        
        CardRankType r;
        CardSuitType suit;
        
        r = [self charToRank:[h1 characterAtIndex:0]];
        suit = [self charToSuit:[h1 characterAtIndex:1]];
        
        Card *c1 = [self findOrCreateCardWithSuit:suit andRank:r inContext:fastContext];
        r = [self charToRank:[h2 characterAtIndex:0]];
        suit = [self charToSuit:[h2 characterAtIndex:1]];
        Card *c2 = [self findOrCreateCardWithSuit:suit andRank:r inContext:fastContext];
        
        for (Seat* s in hand.seats) {
            if ([s.player.name isEqualToString:activeName]) {
                [s addHoleCardsObject:c1];
                [s addHoleCardsObject:c2];
                hand.activePlayer = s.player;
                break;
            }
        }
        
    } else {
        preflopAction = [preflopAction subarrayWithRange:NSMakeRange(1, preflopAction.count - 1)];
    }
    
    for (NSString* actionLine in preflopAction) {
        [self parseActionLine:actionLine forStage:ActionStagePreflop inHand:hand inContext:fastContext];
    }

}

- (void)parseHandData:(NSString*)handData forFlopWithRange:(NSRange)flopRange withHand:(Hand*)hand inContext:(NSManagedObjectContext*)fastContext {
    NSString* flopData = [handData substringWithRange:flopRange];
    NSArray* flopAction = [flopData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    // parse flop cards
    flopAction = [flopAction subarrayWithRange:NSMakeRange(1, flopAction.count - 1)];
    
    for (NSString* actionLine in flopAction) {
        [self parseActionLine:actionLine forStage:ActionStageFlop inHand:hand inContext:fastContext];
    }
}

- (void)parseHandData:(NSString*)handData forTurnWithRange:(NSRange)turnRange withHand:(Hand*)hand inContext:(NSManagedObjectContext*)fastContext {
    NSString* turnData = [handData substringWithRange:turnRange];
    NSArray* turnAction = [turnData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    // parse turn cards
    turnAction = [turnAction subarrayWithRange:NSMakeRange(1, turnAction.count - 1)];
    
    for (NSString* actionLine in turnAction) {
        [self parseActionLine:actionLine forStage:ActionStageTurn inHand:hand inContext:fastContext];
    }
}

- (void)parseHandData:(NSString*)handData forRiverWithRange:(NSRange)riverRange withHand:(Hand*)hand inContext:(NSManagedObjectContext*)fastContext {
    NSString* riverData = [handData substringWithRange:riverRange];
    NSArray* riverAction = [riverData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    // parse river cards
    riverAction = [riverAction subarrayWithRange:NSMakeRange(1, riverAction.count - 1)];
    
    for (NSString* actionLine in riverAction) {
        [self parseActionLine:actionLine forStage:ActionStageRiver inHand:hand inContext:fastContext];
    }
}

- (void)parseHandData:(NSString*)handData
 forShowdownWithRange:(NSRange)showdownRange
             withHand:(Hand*)hand
            inContext:(NSManagedObjectContext*)fastContext {
    NSString* sdData = [handData substringWithRange:showdownRange];
    NSArray* sdAction = [sdData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    // parse showdown cards
    sdAction = [sdAction subarrayWithRange:NSMakeRange(1, sdAction.count - 1)];
    
    for (NSString* actionLine in sdAction) {
        [self parseActionLine:actionLine forStage:ActionStageShowdown inHand:hand inContext:fastContext];
    }
}

- (NSString*)parseSiteLine:(NSString*)siteLine {
    NSRegularExpression *siteExp = [NSRegularExpression
                                    regularExpressionWithPattern:@"Site: (.*)"
                                    options:NSRegularExpressionCaseInsensitive
                                    error:nil];
    
    NSTextCheckingResult *match = [siteExp firstMatchInString:siteLine
                                                      options:0
                                                        range:NSMakeRange(0, [siteLine length])];
    
    if (match != nil) {
        NSString* siteName = [siteLine substringWithRange:[match rangeAtIndex:1]];
        return siteName;
    }
    
    return nil;
}

- (Hand*)handWithId:(NSString*)handID
            forSite:(Site*)site
          inContext:(NSManagedObjectContext*)fastContext {
    
    // create the fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Hand"
                                              inManagedObjectContext:fastContext];
    
    [fetchRequest setEntity:entity];
    //and site.name == %@
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(handID == %@ and site == %@)", handID, site]];
    
    // make sure the results are sorted as well
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey:@"handID"
                                                       ascending:YES];
    
    [fetchRequest setSortDescriptors: [NSArray arrayWithObject:sd]];
    // Execute the fetch
    NSError *error;
    NSArray *hands = [fastContext executeFetchRequest:fetchRequest error:&error];
    
    if ([hands count] > 0) {
        return [hands objectAtIndex:0];
    } else {
        return nil;
    }
}

- (void)loadHandCache:(NSManagedObjectContext*)fastContext {
    // create the fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Hand"
                                              inManagedObjectContext:fastContext];
    
    [fetchRequest setEntity:entity];
    //and site.name == %@
    [fetchRequest setPredicate:nil];
    
    // make sure the results are sorted as well
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey:@"handID"
                                                       ascending:YES];
    
    [fetchRequest setSortDescriptors: [NSArray arrayWithObject:sd]];
    // Execute the fetch
    NSError *error;
    NSArray *hands = [fastContext executeFetchRequest:fetchRequest error:&error];
    
    for (Hand* h in hands) {
        [self.parsedHandCache setObject:[NSNumber numberWithBool:YES] forKey:h.handID];
    }
}

- (void)initialize {
    self.cardCache = [NSMutableDictionary dictionary];
    self.playerCache = [NSMutableDictionary dictionary];
    self.parsedHandCache = [NSMutableDictionary dictionary];
    self.moneyFormatter = [[NSNumberFormatter alloc] init];
    [self.moneyFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    // Only generate the regex once
    self.actionPattern = [NSRegularExpression
                          regularExpressionWithPattern:@"(.*) (folds|calls (\\d+(\\.\\d\\d)?)|raises to (\\d+(\\.\\d\\d)?)|checks|bets (\\d+(\\.\\d\\d)?)|refunded (\\d+(\\.\\d\\d)?)|splits .*\\((\\d+(\\.\\d\\d)?)\\)|wins .*\\((\\d+(\\.\\d\\d)?)\\)|shows \\[[\\dTJQKA][cdhs] [\\dTJQKA][cdhs]\\] \\(.*\\))"
                          options:NSRegularExpressionCaseInsensitive
                          error:nil];
}

- (void)parseHands:(NSArray*)handDatas
           forSiteID:(NSManagedObjectID*)siteID
         inContext:(NSManagedObjectContext*)importContext {
    
    [self initialize];
    [self loadHandCache:importContext];
    
    // Can't cross pollinate data from different contexts
    Site* fastSite = (Site*)[importContext objectWithID:siteID];
    //[self findSiteWithName:site.name inContext:importContext];
    
    for (NSString* handData in handDatas) {
        [self parseHandData:handData forSite:fastSite inContext:importContext];
    }
//    
//    NSError *error = nil;
//    [importContext save:&error];
    
    self.cardCache = nil;
}

- (Hand*)parseHandData:(NSString*)handData forSite:(Site*)site inContext:(NSManagedObjectContext*)fastContext {
    handData = [handData stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Hand"
                                              inManagedObjectContext:fastContext];
    
    NSArray* hdLines = [handData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSString *titleLine = [hdLines objectAtIndex:0];
    
    SRSTitleData* title = [self parseTitleLine:titleLine];
    
    // Line 2 is the Site name
    NSString* siteName = [self parseSiteLine:[hdLines objectAtIndex:2]];
    
    if ([siteName compare:site.name] != NSOrderedSame) {
        // Site mismatch
        return nil;
    }
    
    Hand *rv;
    
    // check for existence
    if (self.parsedHandCache == nil) {
        NSLog(@"NILS");
    }
    
    Hand* exist = [self.parsedHandCache objectForKey:title.handID];
    if (exist != nil) {
        // Already parsed, don't bother
        return [self handWithId:title.handID forSite:site inContext:fastContext];
    } else {
        rv = [[Hand alloc] initWithEntity:entity
                 insertIntoManagedObjectContext:fastContext];
        rv.handID = title.handID;
        rv.date = title.date;
        rv.site = site;
    }
    
    [self parseGameDescriptionLine:[hdLines objectAtIndex:1] forHand:rv];

    
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
        [self parseSeatLines:seatsLines forHand:rv inContext:fastContext];
        
        NSString* dealerLine = [hdLines objectAtIndex:seatsEndRange + 1];
        [self parseDealerLine:dealerLine forHand:rv];
        
        NSInteger bbIndex = 2;
        while ([[hdLines objectAtIndex:seatsEndRange + bbIndex] rangeOfString:@"posts"].location != NSNotFound) {
            
            NSString* blindLine = [hdLines objectAtIndex:seatsEndRange + bbIndex];
            
            if ([blindLine rangeOfString:@"small blind"].location != NSNotFound) {
                [self parseSmallBlindLine:blindLine forHand:rv inContext:fastContext];
            } else if ([blindLine rangeOfString:@"big blind"].location != NSNotFound) {
                [self parseBigBlindLine:blindLine forHand:rv inContext:fastContext];
            } else {
                assert(NO);
            }
            
            bbIndex += 1;
        }
        
        NSString* hs = [hdLines objectAtIndex:seatsEndRange + bbIndex];
        if (![hs isEqualToString:@"** Hole Cards **"]) {
           
        }
    }
    
    NSRange preflopRange = [self rangeForStage:ActionStagePreflop inHand:handData];
    [self parseHandData:handData forPreflopWithRange:preflopRange withHand:rv inContext:fastContext];
    
    NSRange flopRange = [self rangeForStage:ActionStageFlop inHand:handData];
    
    if (flopRange.location != NSNotFound) {
        [self parseHandData:handData forFlopWithRange:flopRange withHand:rv inContext:fastContext];
    }
    
    NSRange turnRange = [self rangeForStage:ActionStageTurn inHand:handData];
    if (turnRange.location != NSNotFound) {
        [self parseHandData:handData forTurnWithRange:turnRange withHand:rv inContext:fastContext];
    }
    
    NSRange riverRange = [self rangeForStage:ActionStageRiver inHand:handData];
    if (riverRange.location != NSNotFound) {
        [self parseHandData:handData forRiverWithRange:riverRange withHand:rv inContext:fastContext];
    }
    
    NSArray* showdownRanges = [self rangesForShowdownInHand:handData];
    
    for (NSValue* sdrv in showdownRanges) {
        NSRange sdr = [sdrv rangeValue];
        [self parseHandData:handData forShowdownWithRange:sdr withHand:rv
                  inContext:fastContext];
    }
//    
//    NSRange showdownRange = [self rangeForStage:ActionStageShowdown inHand:handData];
//    if (showdownRange.location != NSNotFound) {
//        [self parseHandData:handData forShowdownWithRange:showdownRange withHand:rv inContext:fastContext];
//    }
//    
    for (NSString* rakeOpt in [hdLines reverseObjectEnumerator]) {
        if ([rakeOpt hasPrefix:@"Rake ("]) {
            NSString* rakePart = [rakeOpt substringFromIndex:6];
            NSString* rakeValue = [rakePart substringToIndex:rakePart.length - 1];
            
            rv.rake = (NSDecimalNumber*)[self.moneyFormatter numberFromString:rakeValue];
            break;
        }
    }
    
    [self calculatePerSeatIncome:rv];
    
    return rv;
}

- (void)calculatePerSeatIncome:(Hand*)hand {
    for (Seat* s in hand.seats) {
        NSDecimalNumber *sum = [NSDecimalNumber zero];
        
        NSDecimalNumber* bets[10];
        
        Player* p = s.player;
        NSString* pname = p.name;
        
        bets[ActionStagePreflop] = [NSDecimalNumber zero];
        bets[ActionStageFlop] = [NSDecimalNumber zero];
        bets[ActionStageTurn] = [NSDecimalNumber zero];
        bets[ActionStageRiver] = [NSDecimalNumber zero];
        
        for (Action* a in s.actions) {
            if (a.action == ActionEventRefunded || a.action == ActionEventWins) {
                sum = [sum decimalNumberByAdding:a.bet];
            } else if (a.action == ActionEventRaise) {
                bets[a.stage] = a.bet;
            } else if (a.action != ActionEventFold && a.action != ActionEventCheck) {
                // Folds have a zero, which overwrites the last bet
                //bets[a.stage] = a.bet;
                // calls are additive
                bets[a.stage] = [bets[a.stage] decimalNumberByAdding:a.bet];
            }
        }
        
        sum = [sum decimalNumberBySubtracting:bets[ActionStagePreflop]];
        sum = [sum decimalNumberBySubtracting:bets[ActionStageFlop]];
        sum = [sum decimalNumberBySubtracting:bets[ActionStageTurn]];
        sum = [sum decimalNumberBySubtracting:bets[ActionStageRiver]];
        
        s.chipDelta = sum;
    }
}

@end
