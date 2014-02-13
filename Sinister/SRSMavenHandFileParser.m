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
            seat.player = [self findOrCreatePlayerWithName:playerName forSite:hand.site];
            seat.hand = hand;
            //[hand addSeatsObject:seat];
        }
        
    }
}

// Don't create
- (Site*)findSiteWithName:(NSString*)name {
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    NSManagedObjectContext *aMOC = d.managedObjectContext;
    
    // create the fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Site"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(name == %@)", name]];
    
    // make sure the results are sorted as well
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey: @"name"
                                                       ascending:YES];
    
    [fetchRequest setSortDescriptors: [NSArray arrayWithObject:sd]];
    // Execute the fetch
    NSError *error;
    NSArray *sites = [aMOC executeFetchRequest:fetchRequest error:&error];
    
    // TODO: check error
    
    Site *rv = nil;
    
    if ([sites count] != 0) {
        rv = [sites objectAtIndex:0];
    }
    
    return rv;
}



- (Card*)findOrCreateCardWithSuit:(CardSuitType)s andRank:(CardRankType)r {
    
    NSInteger cardKey = s << 4 | r;
    
    Card* cached = [self.cardCache objectForKey:[NSNumber numberWithInteger:cardKey]];
    if (cached != nil) {
        return cached;
    }
    
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    NSManagedObjectContext *aMOC = d.managedObjectContext;
    
    // create the fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(rank == %d and suit == %d)", r, s]];
    
    // make sure the results are sorted as well
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey: @"rank"
                                                       ascending:YES];
    
    [fetchRequest setSortDescriptors: [NSArray arrayWithObject:sd]];
    // Execute the fetch
    NSError *error;
    NSArray *cards = [aMOC executeFetchRequest:fetchRequest error:&error];
    
    // TODO: check error
    
    Card *rv;
    
    if ([cards count] == 0) {
        rv = [[Card alloc] initWithEntity:entity
             insertIntoManagedObjectContext:d.managedObjectContext];
        rv.rank = r;
        rv.suit = s;
        
    } else {
        rv = [cards objectAtIndex:0];
    }
    
    [self.cardCache setObject:rv forKey:[NSNumber numberWithInteger:cardKey]];
    
    return rv;
}

- (Player*)findOrCreatePlayerWithName:(NSString*)name forSite:(Site*)site {
    Player* cached = [self.playerCache objectForKey:name];
    
    if (cached != nil) {
        return cached;
    }
    
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    NSManagedObjectContext *aMOC = d.managedObjectContext;
    
    // create the fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Player"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(name == %@ and site.name == %@)", name, site.name]];
    
    // make sure the results are sorted as well
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey: @"name"
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

- (void) parseSmallBlindLine:(NSString*)smallBlindLine forHand:(Hand*)hand {
    NSRegularExpression *sbExp = [NSRegularExpression
                                      regularExpressionWithPattern:@"(.*) posts small blind (\\d+(\\.\\d\\d)?)"
                                      options:NSRegularExpressionCaseInsensitive
                                      error:nil];
    
    NSTextCheckingResult *match = [sbExp firstMatchInString:smallBlindLine
                                                        options:0
                                                          range:NSMakeRange(0, [smallBlindLine length])];
    
    if (match != nil) {
        SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
        NSManagedObjectContext *aMOC = d.managedObjectContext;
        
        NSString* sbName = [smallBlindLine substringWithRange:[match rangeAtIndex:1]];
        NSString* ante = [smallBlindLine substringWithRange:[match rangeAtIndex:2]];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Action"
                                                  inManagedObjectContext:aMOC];
        
        for (Seat* s in hand.seats) {
            if ([s.player.name isEqualToString:sbName]) {
                s.isSmallBlind = YES;
                Action* sbAction = [[Action alloc] initWithEntity:entity
                                   insertIntoManagedObjectContext:aMOC];
                
                sbAction.action = ActionEventPost;
                NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                [f setNumberStyle:NSNumberFormatterDecimalStyle];
                sbAction.bet =  (NSDecimalNumber*)[f numberFromString:ante];
                
                sbAction.hand = hand;
                sbAction.seat = s;
                sbAction.player = s.player;
                
                
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
        SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
        NSManagedObjectContext *aMOC = d.managedObjectContext;
        
        NSString* bbName = [bigBlindLine substringWithRange:[match rangeAtIndex:1]];
        
        NSString* ante = [bigBlindLine substringWithRange:[match rangeAtIndex:2]];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Action"
                                                  inManagedObjectContext:aMOC];

        
        for (Seat* s in hand.seats) {
            if ([s.player.name isEqualToString:bbName]) {
                s.isBigBlind = YES;
                Action* bbAction = [[Action alloc] initWithEntity:entity
                                   insertIntoManagedObjectContext:aMOC];
                
                bbAction.action = ActionEventPost;
                NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                [f setNumberStyle:NSNumberFormatterDecimalStyle];
                bbAction.bet =  (NSDecimalNumber*)[f numberFromString:ante];
                
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

- (void)parseActionLine:(NSString*)actionLine forStage:(NSInteger)stage inHand:(Hand*)hand {
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    NSManagedObjectContext *aMOC = d.managedObjectContext;

    
    NSRegularExpression *axnExp = [NSRegularExpression
                                  regularExpressionWithPattern:@"(.*) (folds|calls (\\d+(\\.\\d\\d)?)|raises to (\\d+(\\.\\d\\d)?)|checks|bets (\\d+(\\.\\d\\d)?)|refunded (\\d+(\\.\\d\\d)?)|wins Pot \\((\\d+(\\.\\d\\d)?)\\)|shows \\[[\\dTJQKA][cdhs] [\\dTJQKA][cdhs]\\] \\(.*\\))"
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
                a.seat = s;
                
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
                        
                        Card *c = [self findOrCreateCardWithSuit:suit andRank:r];
                        [s addHoleCardsObject:c];
                    }
                } else if ([actionS hasPrefix:@"refunded"]) {
                    a.action = ActionEventRefunded;
                    a.bet = (NSDecimalNumber*)[f numberFromString:[actionS substringFromIndex:9]];
                } else if ([actionS hasPrefix:@"wins Pot ("]) {
                    a.action = ActionEventWins;
                    NSString* betPart = [actionS substringFromIndex:10];
                    a.bet = (NSDecimalNumber*)[f numberFromString:[betPart substringToIndex:betPart.length - 1]];
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
            stop = [fullHand rangeOfString:@"** Pot Show Down **"].location;
            break;
        case ActionStageShowdown:
            start = [fullHand rangeOfString:@"** Pot Show Down **"].location;
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
        
        Card *c1 = [self findOrCreateCardWithSuit:suit andRank:r];
        r = [self charToRank:[h2 characterAtIndex:0]];
        suit = [self charToSuit:[h2 characterAtIndex:1]];
        Card *c2 = [self findOrCreateCardWithSuit:suit andRank:r];
        
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
        [self parseActionLine:actionLine forStage:ActionStagePreflop inHand:hand];
    }

}

- (void)parseHandData:(NSString*)handData forFlopWithRange:(NSRange)flopRange withHand:(Hand*)hand {
    NSString* flopData = [handData substringWithRange:flopRange];
    NSArray* flopAction = [flopData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    // parse flop cards
    flopAction = [flopAction subarrayWithRange:NSMakeRange(1, flopAction.count - 1)];
    
    for (NSString* actionLine in flopAction) {
        [self parseActionLine:actionLine forStage:ActionStageFlop inHand:hand];
    }
}

- (void)parseHandData:(NSString*)handData forTurnWithRange:(NSRange)turnRange withHand:(Hand*)hand {
    NSString* turnData = [handData substringWithRange:turnRange];
    NSArray* turnAction = [turnData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    // parse turn cards
    turnAction = [turnAction subarrayWithRange:NSMakeRange(1, turnAction.count - 1)];
    
    for (NSString* actionLine in turnAction) {
        [self parseActionLine:actionLine forStage:ActionStageTurn inHand:hand];
    }
}

- (void)parseHandData:(NSString*)handData forRiverWithRange:(NSRange)riverRange withHand:(Hand*)hand {
    NSString* riverData = [handData substringWithRange:riverRange];
    NSArray* riverAction = [riverData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    // parse river cards
    riverAction = [riverAction subarrayWithRange:NSMakeRange(1, riverAction.count - 1)];
    
    for (NSString* actionLine in riverAction) {
        [self parseActionLine:actionLine forStage:ActionStageRiver inHand:hand];
    }
}

- (void)parseHandData:(NSString*)handData forShowdownWithRange:(NSRange)showdownRange withHand:(Hand*)hand {
    NSString* sdData = [handData substringWithRange:showdownRange];
    NSArray* sdAction = [sdData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    // parse showdown cards
    sdAction = [sdAction subarrayWithRange:NSMakeRange(1, sdAction.count - 1)];
    
    for (NSString* actionLine in sdAction) {
        [self parseActionLine:actionLine forStage:ActionStageShowdown inHand:hand];
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

- (Hand*)handWithId:(NSString*)handID forSiteName:(NSString*)siteName {
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    NSManagedObjectContext *aMOC = d.managedObjectContext;
    
    // create the fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Hand"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    //and site.name == %@
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(handID == %@ and site.name == %@)", handID, siteName]];
    
    // make sure the results are sorted as well
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey:@"handID"
                                                       ascending:YES];
    
    [fetchRequest setSortDescriptors: [NSArray arrayWithObject:sd]];
    // Execute the fetch
    NSError *error;
    NSArray *hands = [aMOC executeFetchRequest:fetchRequest error:&error];
    
    if ([hands count] > 0) {
        return [hands objectAtIndex:0];
    } else {
        return nil;
    }
}

- (void)parseHands:(NSArray*)handDatas {
    self.cardCache = [NSMutableDictionary dictionary];
    self.playerCache = [NSMutableDictionary dictionary];
    
    for (NSString* handData in handDatas) {
        [self parseHandData:handData];
    }
    
    self.cardCache = nil;
}

- (Hand*) parseHandData:(NSString*)handData {
    handData = [handData stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Hand"
                                              inManagedObjectContext:d.managedObjectContext];
    
    NSArray* hdLines = [handData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSString *titleLine = [hdLines objectAtIndex:0];
    
    SRSTitleData* title = [self parseTitleLine:titleLine];
    
    // Line 2 is the Site name
    NSString* siteName = [self parseSiteLine:[hdLines objectAtIndex:2]];
    Hand *rv;
    
    // check for existence
    Hand* exist = [self handWithId:title.handID forSiteName:siteName];
    if (exist != nil) {
        // Already parsed, don't bother
        return exist;
    } else {
        rv = [[Hand alloc] initWithEntity:entity
                 insertIntoManagedObjectContext:d.managedObjectContext];
        rv.handID = title.handID;
        rv.date = title.date;
        Site* s = [self findSiteWithName:siteName];
        rv.site = s;
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
        [self parseSeatLines:seatsLines forHand:rv];
        
        NSString* dealerLine = [hdLines objectAtIndex:seatsEndRange + 1];
        [self parseDealerLine:dealerLine forHand:rv];
        
        NSInteger bbIndex = 2;
        while ([[hdLines objectAtIndex:seatsEndRange + bbIndex] rangeOfString:@"posts"].location != NSNotFound) {
            
            NSString* blindLine = [hdLines objectAtIndex:seatsEndRange + bbIndex];
            
            if ([blindLine rangeOfString:@"small blind"].location != NSNotFound) {
                [self parseSmallBlindLine:blindLine forHand:rv];
            } else if ([blindLine rangeOfString:@"big blind"].location != NSNotFound) {
                [self parseBigBlindLine:blindLine forHand:rv];
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
    
    NSRange showdownRange = [self rangeForStage:ActionStageShowdown inHand:handData];
    if (showdownRange.location != NSNotFound) {
        [self parseHandData:handData forShowdownWithRange:showdownRange withHand:rv];
    }
    
    for (NSString* rakeOpt in [hdLines reverseObjectEnumerator]) {
        if ([rakeOpt hasPrefix:@"Rake ("]) {
            NSString* rakePart = [rakeOpt substringFromIndex:6];
            NSString* rakeValue = [rakePart substringToIndex:rakePart.length - 1];
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            rv.rake = (NSDecimalNumber*)[f numberFromString:rakeValue];
            break;
        }
    }
    
    [self calculatePerSeatIncome:rv];
    
    return rv;
}

- (void)calculatePerSeatIncome:(Hand*)hand {
    
    for (Seat* s in hand.seats) {
        NSDecimalNumber *sum = [NSDecimalNumber zero];
        
        for (Action* a in s.actions) {
            if (a.action == ActionEventRefunded || a.action == ActionEventWins) {
                sum = [sum decimalNumberByAdding:a.bet];
            } else {
                sum = [sum decimalNumberBySubtracting:a.bet];
            }
        }
        
        s.chipDelta = sum;
    }
}

@end
