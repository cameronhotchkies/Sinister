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
#import "GameFormat+Constants.h"

@interface SRSTitleData : NSObject

@property (strong) NSString* handID;
@property (assign) NSTimeInterval date;

@end
@implementation SRSTitleData
@end

@implementation SRSMavenHandFileParser

- (SRSTitleData*)parseTitleLine:(NSString *)titleLine {
    NSTextCheckingResult *match = [self.titlePattern firstMatchInString:titleLine
                                                                options:0
                                                                  range:NSMakeRange(0, [titleLine length])];
    
    if (match != nil) {
        SRSTitleData* title = [[SRSTitleData alloc] init];
        
        title.handID = [titleLine substringWithRange:[match rangeAtIndex:1]];
        NSString* dateChunk = [titleLine substringWithRange:[match rangeAtIndex:2]];
        
        NSDate* d = [self.dateFormat dateFromString:dateChunk];
        title.date = [d timeIntervalSinceReferenceDate];
        
        return title;
    }
    
    return nil;
}

- (SRSGameFormat*) parseGameDescriptionLine:(NSString *)gameLine withTable:(NSString*)tableLine  {
    SRSGameFormat* gameFormat = [[SRSGameFormat alloc] init];
    
    NSString* description = [gameLine substringFromIndex:6];

    gameFormat.description = description;
    
    NSString* postFlavor;
    
    if ([description hasPrefix:@"NL Hold'em"]) {
        gameFormat.flavor = NLHE;
        postFlavor = [description substringFromIndex:12];
    } else if ([description hasPrefix:@"PL Omaha"]) {
        gameFormat.flavor = PLO;
        postFlavor = [description substringFromIndex:10];
    } else {
        return nil;
    }
    
    NSRange buyinRange = [postFlavor rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@")"]];
    NSString* buyinFormat = [postFlavor substringToIndex:buyinRange.location];
    
    NSArray* cashBlinds = [buyinFormat componentsSeparatedByString:@" - "];
    
    if (cashBlinds.count == 2) {
        // It's a cash game
        gameFormat.minBuyin = [NSDecimalNumber decimalNumberWithString:[cashBlinds objectAtIndex:0]];
        gameFormat.maxBuyin = [NSDecimalNumber decimalNumberWithString:[cashBlinds objectAtIndex:1]];
        
        NSRange blindRange = [postFlavor rangeOfString:@") - Blinds "];
        NSString* blindString = [postFlavor substringFromIndex:blindRange.location + blindRange.length];
        
        NSArray* blinds = [blindString componentsSeparatedByString:@"/"];
        gameFormat.bigBlind = [NSDecimalNumber decimalNumberWithString:[blinds objectAtIndex:1]];
        
        if ([tableLine rangeOfString:@"6max"].location != NSNotFound) {
            gameFormat.maxPlayers = 6;
        } else if ([tableLine rangeOfString:@"9max"].location != NSNotFound) {
            gameFormat.maxPlayers = 9;
        } else {
            NSLog(@"Unknown seat count.. skipping");
            return nil;
        }
    } else {
        // SNG, but not supported yet
        // TODO: finish out
        return nil;
    }
    
    return gameFormat;
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
        NSTextCheckingResult *match = [self.seatPattern firstMatchInString:sl
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
            
            seat.startingChips = [NSDecimalNumber decimalNumberWithString:startingAmount];
            seat.player = [self findOrCreatePlayerWithName:playerName forSite:hand.site inContext:fastContext];
            seat.hand = hand;
        }
        
    }
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
    if ([dealerLine hasSuffix:@" has the dealer button"]) {
        NSString* dealerName = [dealerLine substringToIndex:dealerLine.length - 22];
        
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
    
    NSTextCheckingResult *match = [self.smallBlindPattern firstMatchInString:smallBlindLine
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
    
    NSTextCheckingResult *match = [self.bigBlindPattern firstMatchInString:bigBlindLine
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

- (void)parseActionLine:(NSString*)actionLine
              forStreet:(NSInteger)street
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
            @autoreleasepool {
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
                        a.bet = [NSDecimalNumber decimalNumberWithString:[actionS substringFromIndex:6]];
                    } else if ([actionS hasPrefix:@"raises to "]) {
                        a.action = ActionEventRaise;
                        a.bet = [NSDecimalNumber decimalNumberWithString:[actionS substringFromIndex:10]];
                    } else if ([actionS hasPrefix:@"checks"]) {
                        a.action = ActionEventCheck;
                        a.bet = [NSDecimalNumber zero];
                    } else if ([actionS hasPrefix:@"bets"]) {
                        a.action = ActionEventBet;
                        a.bet = [NSDecimalNumber decimalNumberWithString:[actionS substringFromIndex:5]];
                    } else if ([actionS hasPrefix:@"shows"]) {
                        a.action = ActionEventShow;
                        a.bet = [NSDecimalNumber zero];
                        // Set hole cards
                        NSRange holeRange = NSMakeRange(7, 5);
                        NSString* cardPart = [actionS substringWithRange:holeRange];
                        NSArray* holeCardsStr = [cardPart componentsSeparatedByString:@" "];
                        for (NSString* c in holeCardsStr) {
                            Card *card = [self.cardCache objectForKey:c];
                            [s addHoleCardsObject:card];
                        }
                    } else if ([actionS hasPrefix:@"refunded"]) {
                        a.action = ActionEventRefunded;
                        a.bet = [NSDecimalNumber decimalNumberWithString:[actionS substringFromIndex:9]];
                    } else if ([actionS hasPrefix:@"wins Pot ("]) {
                        a.action = ActionEventWins;
                        NSRange betRange = NSMakeRange(10, actionS.length - 11);
                        NSString* betPart = [actionS substringWithRange:betRange];
                        a.bet = [NSDecimalNumber decimalNumberWithString:betPart];
                    } else if ([actionS hasPrefix:@"splits Pot ("]) {
                        a.action = ActionEventWins;
                        NSRange betRange = NSMakeRange(12, actionS.length - 13);
                        NSString* betPart = [actionS substringWithRange:betRange];
                        a.bet = [NSDecimalNumber decimalNumberWithString:betPart];
                    } else if ([actionS hasPrefix:@"wins Side Pot"]
                               || [actionS hasPrefix:@"wins Main Pot"]
                               || [actionS hasPrefix:@"splits Side Pot"]) {
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
        }
        
        a.street = street;
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
    
    return showdowns;
}

- (NSRange)rangeForStreet:(ActionStreet)s inHand:(NSString*)fullHand {
    NSUInteger start = NSNotFound;
    NSUInteger stop = NSNotFound;
    
    NSUInteger rakeLoc = [fullHand rangeOfString:@"\nRake ("].location;
    assert(rakeLoc != NSNotFound);
    
    switch (s) {
        case ActionStreetPreflop:
            start = [fullHand rangeOfString:@"** Hole Cards **"].location;
            stop = [fullHand rangeOfString:@"** Flop **"].location;
            stop = MIN(rakeLoc, stop);
            break;
        case ActionStreetFlop:
            start = [fullHand rangeOfString:@"** Flop **"].location;
            stop = [fullHand rangeOfString:@"** Turn **"].location;
            break;
        case ActionStreetTurn:
            start = [fullHand rangeOfString:@"** Turn **"].location;
            stop = [fullHand rangeOfString:@"** River **"].location;
            break;
        case ActionStreetRiver:
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
        case ActionStreetShowdown:
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
        
        Card *c1 = [self.cardCache objectForKey:h1];    
        Card *c2 = [self.cardCache objectForKey:h2];
        
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
        [self parseActionLine:actionLine forStreet:ActionStreetPreflop inHand:hand inContext:fastContext];
    }
    
}

- (void)parseStreet:(ActionStreet)street
           fromText:(NSString*)handText
          withRange:(NSRange)streetRange
            forHand:(Hand*)hand
          inContext:(NSManagedObjectContext*)context {
    NSString* streetText = [handText substringWithRange:streetRange];
    NSArray* actionText = [streetText componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    actionText = [actionText subarrayWithRange:NSMakeRange(1, actionText.count - 1)];
    
    for (NSString* actionLine in actionText) {
        [self parseActionLine:actionLine
                    forStreet:street
                       inHand:hand
                    inContext:context];
    }
}

- (NSString*)parseSiteLine:(NSString*)siteLine {
    if ([siteLine hasPrefix:@"Site: "]) {
        NSString* siteName = [siteLine substringFromIndex:6];
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

- (void)initializeCardCache:(NSManagedObjectContext*)context {
    self.cardCache = [NSMutableDictionary dictionary];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card"
                                              inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:nil];
   
    // Execute the fetch
    NSError *error;
    NSArray *cards = [context executeFetchRequest:fetchRequest error:&error];
    
    if (cards.count == 52) {
        // save them to the cache
        for (Card* c in cards) {
            [self.cardCache setObject:c forKey:[c printable]];
        }
        
    } else if (cards.count == 0) {
        // generate cards, then cache
        for (NSInteger s = 1; s <= 4; s++) {
            for (NSInteger r = 1; r <= 13; r++) {
                Card* newCard = [[Card alloc] initWithEntity:entity
                              insertIntoManagedObjectContext:context];
                newCard.rank = r;
                newCard.suit = s;
                
                NSString* key = [newCard printable];
                
                [self.cardCache setObject:newCard forKey:key];
            }
        }
        
    } else {
        // This shouldn't happen
        assert(NO);
    }
}

- (void)initializeGameFormats:(NSManagedObjectContext*)context {
    self.gameFormats = [NSMutableArray array];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GameFormat"
                                              inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:nil];

    // Execute the fetch
    NSError *error;
    NSArray *formats = [context executeFetchRequest:fetchRequest error:&error];
    
    for (GameFormat* fmt in formats) {
        [self.gameFormats addObject:fmt];
    }
}

- (void)initialize:(NSManagedObjectContext*)context {
    [self initializeCardCache:context];
    self.playerCache = [NSMutableDictionary dictionary];
    self.parsedHandCache = [NSMutableDictionary dictionary];
    
    self.dateFormat = [[NSDateFormatter alloc] init];
    [self.dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    // Only generate the regexes once
    self.seatPattern =  [NSRegularExpression regularExpressionWithPattern:@"Seat (\\d): (.*) \\((\\d+(\\.\\d\\d)?)\\).*"
                                                                  options:NSRegularExpressionCaseInsensitive
                                                                    error:nil];
    
    
    self.actionPattern = [NSRegularExpression
                          regularExpressionWithPattern:@"(.*) (folds|calls (\\d+(\\.\\d\\d)?)|raises to (\\d+(\\.\\d\\d)?)|checks|bets (\\d+(\\.\\d\\d)?)|refunded (\\d+(\\.\\d\\d)?)|splits .*\\((\\d+(\\.\\d\\d)?)\\)|wins .*\\((\\d+(\\.\\d\\d)?)\\)|shows \\[[\\dTJQKA][cdhs] [\\dTJQKA][cdhs]\\] \\(.*\\))"
                          options:NSRegularExpressionCaseInsensitive
                          error:nil];
    
    self.smallBlindPattern = [NSRegularExpression
                              regularExpressionWithPattern:@"(.*) posts small blind (\\d+(\\.\\d\\d)?)"
                              options:NSRegularExpressionCaseInsensitive
                              error:nil];
    
    self.bigBlindPattern = [NSRegularExpression
                            regularExpressionWithPattern:@"(.*) posts big blind (\\d+(\\.\\d\\d)?)"
                            options:NSRegularExpressionCaseInsensitive
                            error:nil];
    
    self.titlePattern = [NSRegularExpression regularExpressionWithPattern:@"Hand #(\\d+-\\d+) - (\\d\\d\\d\\d-\\d\\d-\\d\\d \\d\\d:\\d\\d:\\d\\d)"
                                                                  options:NSRegularExpressionCaseInsensitive
                                                                    error:nil];
}

- (void)parseHands:(NSArray*)handDatas
         forSiteID:(NSManagedObjectID*)siteID
         inContext:(NSManagedObjectContext*)importContext {
    
    [self initialize:importContext];
    [self loadHandCache:importContext];
    
    // Can't cross pollinate data from different contexts
    Site* fastSite = (Site*)[importContext objectWithID:siteID];
    
    for (NSString* handData in handDatas) {
        [self parseHandData:handData forSite:fastSite inContext:importContext];
    }
    
    self.cardCache = nil;
}

- (GameFormat*)findGameFormat:(SRSGameFormat*)f
                    inContext:(NSManagedObjectContext*)context {
    
    for (GameFormat* gf in self.gameFormats) {
        if ([f equals:gf]) {
            return gf;
        }
    }
    
    // Didn't find one, create one
    GameFormat* newFormat = [f toManagedObject:context];
    [self.gameFormats addObject:newFormat];
    return newFormat;
}

- (Hand*)parseHandData:(NSString*)handData forSite:(Site*)site inContext:(NSManagedObjectContext*)fastContext {
    handData = [handData stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Hand"
                                              inManagedObjectContext:fastContext];
    
    NSArray* hdLines = [handData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSString *titleLine = [hdLines objectAtIndex:0];
    
    SRSTitleData* title = [self parseTitleLine:titleLine];
    SRSGameFormat* gameFormat = [self parseGameDescriptionLine:[hdLines objectAtIndex:1]
                                                     withTable:[hdLines objectAtIndex:3]];
    
    if (gameFormat == nil) {
        return nil;
    }
    
    // Line 2 is the Site name
    NSString* siteName = [self parseSiteLine:[hdLines objectAtIndex:2]];
    
    if ([siteName compare:site.name] != NSOrderedSame) {
        // Site mismatch
        return nil;
    }
    
    Hand *rv;
    
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
    
    GameFormat* format = [self findGameFormat:gameFormat
                                    inContext:fastContext];
    
    rv.gameFormat = format;
    
    NSString* gameDescription = [[hdLines objectAtIndex:1] substringFromIndex:6];
    rv.game = gameDescription;

    
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
    
    NSRange preflopRange = [self rangeForStreet:ActionStreetPreflop inHand:handData];
    [self parseHandData:handData forPreflopWithRange:preflopRange withHand:rv inContext:fastContext];
    
    NSRange flopRange = [self rangeForStreet:ActionStreetFlop inHand:handData];
    
    if (flopRange.location != NSNotFound) {
        [self parseStreet:ActionStreetFlop
                 fromText:handData
                withRange:flopRange
                  forHand:rv
                inContext:fastContext];
    }
    
    NSRange turnRange = [self rangeForStreet:ActionStreetTurn inHand:handData];
    if (turnRange.location != NSNotFound) {
        [self parseStreet:ActionStreetTurn
                 fromText:handData
                withRange:turnRange
                  forHand:rv
                inContext:fastContext];
    }
    
    NSRange riverRange = [self rangeForStreet:ActionStreetRiver inHand:handData];
    if (riverRange.location != NSNotFound) {
        [self parseStreet:ActionStreetRiver
                 fromText:handData
                withRange:riverRange
                  forHand:rv
                inContext:fastContext];
    }
    
    NSArray* showdownRanges = [self rangesForShowdownInHand:handData];
    
    for (NSValue* sdrv in showdownRanges) {
        NSRange sdr = [sdrv rangeValue];
        [self parseStreet:ActionStreetShowdown
                 fromText:handData
                withRange:sdr
                  forHand:rv
                inContext:fastContext];
    }
    
    rv.rake = [NSDecimalNumber zero];
    
    for (NSString* rakeOpt in [hdLines reverseObjectEnumerator]) {
        if ([rakeOpt hasPrefix:@"Rake ("]) {
            NSInteger rakeLen = rakeOpt.length;
            NSRange rakeRange = NSMakeRange(6, rakeLen - 7);
            NSString* rakeValue = [rakeOpt substringWithRange:rakeRange];
            
            rv.rake = [rv.rake decimalNumberByAdding:[NSDecimalNumber decimalNumberWithString:rakeValue]];
        }
    }
    
    [self calculatePerSeatIncome:rv];
    
    return rv;
}

- (void)calculatePerSeatIncome:(Hand*)hand {
    for (Seat* s in hand.seats) {
        NSDecimalNumber *sum = [NSDecimalNumber zero];
        
        NSDecimalNumber* bets[10];
        
        //        Player* p = s.player;
        //        NSString* pname = p.name;
        
        bets[ActionStreetPreflop] = [NSDecimalNumber zero];
        bets[ActionStreetFlop] = [NSDecimalNumber zero];
        bets[ActionStreetTurn] = [NSDecimalNumber zero];
        bets[ActionStreetRiver] = [NSDecimalNumber zero];
        
        for (Action* a in s.actions) {
            if (a.action == ActionEventRefunded || a.action == ActionEventWins) {
                sum = [sum decimalNumberByAdding:a.bet];
            } else if (a.action == ActionEventRaise) {
                bets[a.street] = a.bet;
            } else if (a.action != ActionEventFold && a.action != ActionEventCheck) {
                // Folds have a zero, which overwrites the last bet
                // calls are additive
                bets[a.street] = [bets[a.street] decimalNumberByAdding:a.bet];
            }
        }
        
        sum = [sum decimalNumberBySubtracting:bets[ActionStreetPreflop]];
        sum = [sum decimalNumberBySubtracting:bets[ActionStreetFlop]];
        sum = [sum decimalNumberBySubtracting:bets[ActionStreetTurn]];
        sum = [sum decimalNumberBySubtracting:bets[ActionStreetRiver]];
        
        s.chipDelta = sum;
    }
}

@end
