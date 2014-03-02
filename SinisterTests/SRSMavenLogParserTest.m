//
//  SRSMavenLogParserTest.m
//  Sinister
//
//  Created by Cameron Hotchkies on 1/18/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SRSMavenHandFileParser.h"

#import "Seat.h"
#import "Player.h"
#import "Action+Constants.h"
#import "Site.h"
#import "Hand.h"
#import "Card+Constants.h"

@interface SRSMavenLogParserTest : XCTestCase

@end

@implementation SRSMavenLogParserTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (NSDecimalNumber*)decimalFromString:(NSString*)s {
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSDecimalNumber *n = (NSDecimalNumber*)[f numberFromString:s];
    return n;
}

- (void)testUpToFlop
{
    SRSMavenHandFileParser *p = [[SRSMavenHandFileParser alloc] init];
    
    NSString *sampleHandData = @"Hand #12345679-010 - 2014-01-16 23:59:34\n\
Game: NL Hold'em (2 - 10) - Blinds 0.05/0.10\n\
Site: Seals With Clubs\n\
Table: NLHE 6max .05/.10 #7\n\
Seat 1: Villain2 (7.87)\n\
Seat 2: Villain3 (10) - waiting for big blind\n\
Seat 3: Villain4 (1.44)\n\
Seat 4: Villain5 (7.19)\n\
Seat 6: Villain6 (1.47)\n\
Villain6 has the dealer button\n\
Villain2 posts small blind 0.05\n\
Villain3 posts big blind 0.10\n\
** Hole Cards **\n\
Villain4 folds\n\
Villain5 calls 0.10\n\
Villain6 raises to 0.50\n\
Villain2 calls 0.45\n\
Villain3 folds\n\
Villain5 folds\n\
** Flop ** [4s 5s 6h]\n\
Villain2 checks\n\
Villain6 bets 0.97 (All-in)\n\
Villain2 folds\n\
Villain6 refunded 0.97\n\
Villain6 wins Pot (1.17)\n\
Rake (0.03)";
    
    NSManagedObjectContext* moc = [SRSMavenLogParserTest managedObjectContextForTests];
    [p initialize:moc];
    
    Site* site = [self findOrCreateSealsSite:moc];
    Hand *h = [p parseHandData:sampleHandData forSite:site inContext:moc];
    NSOrderedSet *ss = h.seats;
    
    NSString *handID = h.handID;
    
    XCTAssert([handID isEqualToString:@"12345679-010"], @"Match hand ID");
    
    NSDate *date = [NSDate dateWithString:@"2014-01-16 23:59:34"];
    // TODO:fix this
    //XCTAssertEqual(h.date, [date timeIntervalSince1970], @"Match hand date");
    
    NSString *gameInfo = h.game;
    XCTAssert([gameInfo isEqualToString:@"NL Hold'em (2 - 10) - Blinds 0.05/0.10"], @"Test game name parsing");
    
    NSString *tableInfo = h.table;
    XCTAssert([tableInfo isEqualToString:@"NLHE 6max .05/.10 #7"], @"Table format");
    
    Site *s = h.site;
    NSString *siteName = s.name;
    XCTAssert([@"Seals With Clubs" isEqualToString:siteName], @"Verify site name");
    
    NSUInteger ssc = ss.count;
    
    XCTAssertEqual((NSUInteger)5, ssc, @"There are five players in the hand");
    
    Seat* sbSeat = (Seat *)[h.seats objectAtIndex:0];
    NSString *sName = sbSeat.player.name;
    XCTAssert([sName isEqualToString:@"Villain2"]);

    XCTAssert(sbSeat.player.site.name == h.site.name, @"Verify player site is matched");
    
    Seat* bbSeat = (Seat *)[h.seats objectAtIndex:1];
    sName = (bbSeat).player.name;
    XCTAssert([sName isEqualToString:@"Villain3"]);
    
    sName = ((Seat *)[h.seats objectAtIndex:2]).player.name;
    XCTAssert([sName isEqualToString:@"Villain4"]);
    
    sName = ((Seat *)[h.seats objectAtIndex:3]).player.name;
    XCTAssert([sName isEqualToString:@"Villain5"]);
    
    Seat *dlrSeat = (Seat *)[h.seats objectAtIndex:4];
    sName = (dlrSeat).player.name;
    XCTAssert([sName isEqualToString:@"Villain6"]);
    
    XCTAssertTrue(dlrSeat.isDealer, @"Verify is Dealer");
    
    XCTAssertTrue(sbSeat.isSmallBlind, @"Verify is Small Blind");
    
    XCTAssertTrue(bbSeat.isBigBlind, @"Verify is Big Blind");
    
    NSOrderedSet* preflopActions = [h.actions filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"street == %d", ActionStreetPreflop]];
    
    XCTAssert(preflopActions.count == 8, @"Verify preflop actions");
    
    Action* a0 = [preflopActions objectAtIndex:0];
    XCTAssert(a0.action == ActionEventPost, @"Expecting a post");
    XCTAssert([a0.bet isEqualToNumber:[self decimalFromString:@"0.05"]], @"SB value is 0.05");
    
    Action* a1 = [preflopActions objectAtIndex:1];
    XCTAssert(a1.action == ActionEventPost, @"Expecting a post");
    XCTAssert([a1.bet isEqualToNumber:[self decimalFromString:@"0.10"]], @"Call value is 0.10");
    
    Action* a2 = [preflopActions objectAtIndex:4];
    XCTAssert(a2.action == ActionEventRaise, @"Expecting a raise");
    XCTAssert([a2.bet isEqualToNumber:[self decimalFromString:@"0.50"]], @"Raise value is 0.50");
    
    Action* a3 = [preflopActions objectAtIndex:5];
    XCTAssert(a3.action == ActionEventCall, @"Expecting a call");
    XCTAssert([a3.bet isEqualToNumber:[self decimalFromString:@"0.45"]], @"Call value is 0.45");
    
    Action* a4 = [preflopActions objectAtIndex:6];
    XCTAssert(a4.action == ActionEventFold, @"Expecting a fold");
    
    Action* a5 = [preflopActions objectAtIndex:7];
    XCTAssert(a5.action == ActionEventFold, @"Expecting a fold");
    
    NSOrderedSet* flopActions = [h.actions filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"street == %d", ActionStreetFlop]];
        XCTAssert(flopActions.count == 5, @"Verify flop actions");
    
    Action* f0 = [flopActions objectAtIndex:0];
    XCTAssert(f0.action == ActionEventCheck, @"Expecting a check");
    
    Action* f1 = [flopActions objectAtIndex:1];
    XCTAssert(f1.action == ActionEventBet, @"Expecting a bet");
    XCTAssert([f1.bet isEqualToNumber:[self decimalFromString:@"0.97"]], @"Bet value is 0.97");
    
    Action* f2 = [flopActions objectAtIndex:2];
    XCTAssert(f2.action == ActionEventFold, @"Expecting a fold");
    
    Action* f3 = [flopActions objectAtIndex:3];
    XCTAssert(f3.action == ActionEventRefunded, @"Expecting a refund");
    XCTAssert([f3.bet isEqualToNumber:[self decimalFromString:@"0.97"]], @"Refund value is 0.97");

    Action* f4 = [flopActions objectAtIndex:4];
    XCTAssert(f4.action == ActionEventWins, @"Expecting a win");
    XCTAssert([f4.bet isEqualToNumber:[self decimalFromString:@"1.17"]], @"Win value is 0.97");
    
    NSDecimalNumber* expectedRake = [self decimalFromString:@"0.03"];
    XCTAssert([expectedRake isEqualToNumber:h.rake], @"Verify Rake is correct");
}

+ (NSManagedObjectContext *)managedObjectContextForTests {
    static NSManagedObjectModel *model = nil;
    if (!model) {
        model = [NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]];
    }
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSPersistentStore *store = [psc addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:nil];
    NSAssert(store, @"Should have a store by now");
    
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    moc.persistentStoreCoordinator = psc;
    
    return moc;
}

- (Site*)findOrCreateSealsSite:(NSManagedObjectContext*)context {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Site"
                                              inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(name == %@)", @"Seals With Clubs"]];
    
    // make sure the results are sorted as well
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey: @"name"
                                                       ascending:YES];
    
    [fetchRequest setSortDescriptors: [NSArray arrayWithObject:sd]];
    // Execute the fetch
    NSError *error;
    NSArray *sites = [context executeFetchRequest:fetchRequest error:&error];
    
    // TODO: check error
    
    Site *rv = nil;
    
    if ([sites count] != 0) {
        rv = [sites objectAtIndex:0];
    } else {
        rv = [[Site alloc] initWithEntity:entity
             insertIntoManagedObjectContext:context];
        
        rv.name = @"Seals With Clubs";

    }
    
    return rv;
}

- (void)testBlindStealing {
    NSString* handData = @"Hand #12345697-021 - 2014-01-18 18:58:08\n\
Game: NL Hold'em (2 - 10) - Blinds 0.05/0.10\n\
Site: Seals With Clubs\n\
Table: NLHE 6max .05/.10 #4\n\
Seat 1: VillainA (23.55)\n\
Seat 2: VillainB (10)\n\
Seat 3: VillainC (21.99)\n\
Seat 4: VillainD (12.82)\n\
Seat 5: Hero (4.67)\n\
Seat 6: VillainE (2) - waiting for big blind\n\
VillainC has the dealer button\n\
VillainD posts small blind 0.05\n\
Hero posts big blind 0.10\n\
** Hole Cards **\n\
Dealt to Hero [9d Qh]\n\
VillainA folds\n\
VillainB folds\n\
VillainC folds\n\
VillainD raises to 0.30\n\
Hero folds\n\
VillainD refunded 0.20\n\
VillainD wins Pot (0.20)\n\
Rake (0)";
    SRSMavenHandFileParser *p = [[SRSMavenHandFileParser alloc] init];
    
    NSManagedObjectContext* moc = [SRSMavenLogParserTest managedObjectContextForTests];
    [p initialize:moc];
    
    Site* site = [self findOrCreateSealsSite:moc];
    
    Hand *h = [p parseHandData:handData forSite:site inContext:moc];
    NSOrderedSet *ss = h.seats;
    
    for (Seat* s in ss) {
        if ([s.player.name isEqualToString:@"Hero"]) {
            NSDecimalNumber* expected = [NSDecimalNumber decimalNumberWithString:@"-0.10"];
            NSDecimalNumber* actual = s.chipDelta;
            XCTAssert([expected compare:actual] == NSOrderedSame, @"Hero lost 0.10");
        } else if ([s.player.name isEqualToString:@"VillainD"]) {
            NSDecimalNumber* expected = [NSDecimalNumber decimalNumberWithString:@"0.10"];
            NSDecimalNumber* actual = s.chipDelta;
            XCTAssert([expected compare:actual] == NSOrderedSame, @"Villain won 0.10");
        }
    }
}

- (void)testSplitPots {
    SRSMavenHandFileParser *p = [[SRSMavenHandFileParser alloc] init];
    
    NSString* handData = @"Hand #12345697-020 - 2014-02-22 23:37:14\n\
Game: NL Hold'em (2 - 10) - Blinds 0.05/0.10\n\
Site: Seals With Clubs\n\
Table: NLHE 9max .05/.10 #1\n\
Seat 1: Villain1 (10.96)\n\
Seat 2: Villain7 (14.24)\n\
Seat 3: Villain8 (22.39)\n\
Seat 4: Villain9 (9.90)\n\
Seat 5: VillainA (16.38)\n\
Seat 6: VillainB (2)\n\
Seat 7: VillainC (26.69)\n\
Seat 8: VillainD (10.73)\n\
Seat 9: Hero (55.56)\n\
Villain8 has the dealer button\n\
Villain9 posts small blind 0.05\n\
VillainA posts big blind 0.10\n\
** Hole Cards **\n\
Dealt to Hero [7d 5s]\n\
VillainB calls 0.10\n\
VillainC raises to 0.40\n\
VillainD folds\n\
Hero folds\n\
Villain1 folds\n\
Villain7 folds\n\
Villain8 folds\n\
Villain9 has timed out\n\
Villain9 folds\n\
VillainA folds\n\
VillainB calls 0.30\n\
** Flop ** [3c 4c 4s]\n\
VillainB bets 0.60\n\
VillainC calls 0.60\n\
** Turn ** [Jd]\n\
VillainB bets 0.75\n\
VillainC raises to 1.50\n\
VillainB calls 0.25 (All-in)\n\
VillainC refunded 0.50\n\
** River ** [Jc]\n\
** Pot Show Down ** [3c 4c 4s Jd Jc]\n\
VillainB shows [Kc Js] (a Full House, Jacks full of Fours)\n\
VillainC shows [Kh Jh] (a Full House, Jacks full of Fours)\n\
VillainB splits Pot (2.03) with a Full House\n\
VillainC splits Pot (2.02) with a Full House\n\
Rake (0.10)";
    
    NSManagedObjectContext* moc = [SRSMavenLogParserTest managedObjectContextForTests];
    [p initialize:moc];
    
    Site* site = [self findOrCreateSealsSite:moc];
    
    Hand *h = [p parseHandData:handData forSite:site inContext:moc];
    NSString *handID = h.handID;
    
    XCTAssert([handID isEqualToString:@"12345697-020"], @"Match hand ID");
    
    XCTAssert(h.activePlayer != Nil, @"Active player exists");
    XCTAssert([h.activePlayer.name isEqualToString:@"Hero"], @"Active Player is identified");
    
    for (Seat* seat in h.seats) {
        NSDecimalNumber* delta = seat.chipDelta;
        XCTAssert(delta != Nil, @"Chip Delta exists");
        
        if ([seat.player.name isEqualToString:@"VillainB"]) {
            NSDecimalNumber* expected = [NSDecimalNumber decimalNumberWithString:@"0.03"];
            XCTAssert([expected compare:delta] == NSOrderedSame, @"Chip delta calculated correctly");
        } else if ([seat.player.name isEqualToString:@"VillainC"]) {
            NSDecimalNumber* expected = [NSDecimalNumber decimalNumberWithString:@"0.02"];
            XCTAssert([expected compare:delta] == NSOrderedSame, @"Chip delta calculated correctly");
        }
    }

}

- (void)testSidePots {
    SRSMavenHandFileParser *p = [[SRSMavenHandFileParser alloc] init];
    
    NSString* handData = @"Hand #12345678-001 - 2014-02-22 22:55:32\n\
Game: NL Hold'em (2 - 10) - Blinds 0.05/0.10\n\
Site: Seals With Clubs\n\
Table: NLHE 9max .05/.10 #1\n\
Seat 1: Villain1 (10)\n\
Seat 3: Villain8 (18.70)\n\
Seat 4: VillainE (8.76)\n\
Seat 5: VillainA (10)\n\
Seat 6: VillainF (19.61)\n\
Seat 7: VillainC (19.50)\n\
Seat 8: VillainG (4.49)\n\
Seat 9: Hero (19.35)\n\
Hero has the dealer button\n\
Villain1 posts small blind 0.05\n\
Villain8 posts big blind 0.10\n\
** Hole Cards **\n\
Dealt to Hero [6c 6s]\n\
VillainE raises to 0.20\n\
VillainA folds\n\
VillainF calls 0.20\n\
VillainC folds\n\
VillainG folds\n\
Hero calls 0.20\n\
Villain1 folds\n\
Villain1 adds 0.05 chips\n\
Villain8 calls 0.10\n\
** Flop ** [6h Kd 4h]\n\
Villain8 checks\n\
VillainE bets 0.40\n\
VillainF calls 0.40\n\
Hero raises to 0.80\n\
Villain8 folds\n\
VillainE calls 0.40\n\
VillainF calls 0.40\n\
** Turn ** [5s]\n\
VillainE bets 0.80\n\
VillainF raises to 2.80\n\
Hero raises to 6\n\
VillainE raises to 7.76 (All-in)\n\
VillainF calls 4.96\n\
Hero calls 1.76\n\
** River ** [Kh]\n\
VillainF bets 6.16\n\
Hero raises to 10.59 (All-in)\n\
VillainF calls 4.43\n\
** Side Pot 1 Show Down ** [6h Kd 4h 5s Kh]\n\
VillainF shows [4c 4s] (a Full House, Fours full of Kings)\n\
Hero shows [6c 6s] (a Full House, Sixes full of Kings)\n\
Hero wins Side Pot 1 (21.18) with a Full House\n\
Rake (0)\n\
** Main Pot Show Down ** [6h Kd 4h 5s Kh]\n\
VillainE shows [9h Ah] (a Flush, Ace high +K964)\n\
Hero wins Main Pot (26.03) with a Full House\n\
Rake (0.50)\n\
VillainF adds 9.74 chips";
    
    NSManagedObjectContext* moc = [SRSMavenLogParserTest managedObjectContextForTests];
    [p initialize:moc];
    
    Site* site = [self findOrCreateSealsSite:moc];
    
    Hand *h = [p parseHandData:handData forSite:site inContext:moc];
    NSString *handID = h.handID;
    
    XCTAssert([handID isEqualToString:@"12345678-001"], @"Match hand ID");
    
    XCTAssert(h.activePlayer != Nil, @"Active player exists");
    XCTAssert([h.activePlayer.name isEqualToString:@"Hero"], @"Active Player is identified");

    for (Seat* seat in h.seats) {
        if (seat.player == h.activePlayer) {
            NSDecimalNumber* delta = seat.chipDelta;
            
            XCTAssert(delta != Nil, @"Chip Delta exists");
            NSDecimalNumber* expected = [NSDecimalNumber decimalNumberWithString:@"27.86"];
            XCTAssert([expected compare:delta] == NSOrderedSame, @"Chip delta calculated correctly");
        }
    }
    
}

- (void)testToShowdown {
    NSString* handData = @"Hand #16693885-51 - 2014-01-17 00:04:15\n\
Game: NL Hold'em (2 - 10) - Blinds 0.05/0.10\n\
Site: Seals With Clubs\n\
Table: NLHE 6max .05/.10 #7\n\
Seat 1: Villain2 (7.07)\n\
Seat 2: Villain3 (8.71)\n\
Seat 3: Villain4 (1.29)\n\
Seat 4: Villain5 (8.25)\n\
Seat 5: Hero (5.60)\n\
Seat 6: Villain6 (2.91)\n\
Villain5 has the dealer button\n\
Hero posts small blind 0.05\n\
Villain6 posts big blind 0.10\n\
** Hole Cards **\n\
Dealt to Hero [8h 3h]\n\
Villain2 calls 0.10\n\
Villain3 calls 0.10\n\
Villain4 calls 0.10\n\
Villain5 calls 0.10\n\
Hero folds\n\
Villain6 checks\n\
** Flop ** [8c 2h 6c]\n\
Villain6 checks\n\
Villain2 checks\n\
Villain3 bets 0.30\n\
Villain4 calls 0.30\n\
Villain5 calls 0.30\n\
Villain6 calls 0.30\n\
Villain2 folds\n\
** Turn ** [5d]\n\
Villain6 checks\n\
Villain3 checks\n\
Villain4 bets 0.89 (All-in)\n\
Villain5 calls 0.89\n\
Villain6 folds\n\
Villain3 folds\n\
** River ** [8d]\n\
** Pot Show Down ** [8c 2h 6c 5d 8d]\n\
Villain4 shows [9h 7d] (a Straight, Five to Nine)\n\
Villain5 shows [4d 7s] (a Straight, Four to Eight)\n\
Villain4 wins Pot (3.45) with a Straight\n\
Rake (0.08)";
    
    SRSMavenHandFileParser *p = [[SRSMavenHandFileParser alloc] init];
    
    NSManagedObjectContext* moc = [SRSMavenLogParserTest managedObjectContextForTests];
    [p initialize:moc];
    
    Site* site = [self findOrCreateSealsSite:moc];
    
    Hand *h = [p parseHandData:handData forSite:site inContext:moc];
    NSOrderedSet *ss = h.seats;
    
    NSString *handID = h.handID;
    
    XCTAssert([handID isEqualToString:@"16693885-51"], @"Match hand ID");
    
    NSDate *date = [NSDate dateWithString:@"2014-01-17 00:04:15"];
    
    // TODO: fix this
    // XCTAssertEqual(h.date, [date timeIntervalSince1970], @"Match hand date");
    
    NSString *gameInfo = h.game;
    XCTAssert([gameInfo isEqualToString:@"NL Hold'em (2 - 10) - Blinds 0.05/0.10"], @"Test game name parsing");
    
    NSString *tableInfo = h.table;
    XCTAssert([tableInfo isEqualToString:@"NLHE 6max .05/.10 #7"], @"Table format");
    
    Site *s = h.site;
    NSString *siteName = s.name;
    XCTAssert([@"Seals With Clubs" isEqualToString:siteName], @"Verify site name");
    
    NSUInteger ssc = ss.count;
    
    XCTAssertEqual((NSUInteger)6, ssc, @"There are six players in the hand");
    
    Seat* oneSeat = (Seat *)[h.seats objectAtIndex:0];
    NSString *sName = oneSeat.player.name;
    XCTAssert([sName isEqualToString:@"Villain2"]);
    
    XCTAssert(oneSeat.player.site.name == h.site.name, @"Verify player site is matched");

    Seat* twoSeat = (Seat *)[h.seats objectAtIndex:1];
    sName = twoSeat.player.name;
    XCTAssert([sName isEqualToString:@"Villain3"]);
    
    sName = ((Seat *)[h.seats objectAtIndex:2]).player.name;
    XCTAssert([sName isEqualToString:@"Villain4"]);
    
    Seat* dlrSeat = [h.seats objectAtIndex:3];
    sName = dlrSeat.player.name;
    XCTAssert([sName isEqualToString:@"Villain5"]);
    
    Seat* sbSeat = [h.seats objectAtIndex:4];
    sName = sbSeat.player.name;
    XCTAssert([sName isEqualToString:@"Hero"]);
    
    Seat *sixSeat = (Seat *)[h.seats objectAtIndex:5];
    sName = (sixSeat).player.name;
    XCTAssert([sName isEqualToString:@"Villain6"]);
    
    XCTAssertTrue(dlrSeat.isDealer, @"Verify is Dealer");
    
    XCTAssertTrue(sbSeat.isSmallBlind, @"Verify is Small Blind");
    
    XCTAssertTrue(sixSeat.isBigBlind, @"Verify is Big Blind");
    
    NSOrderedSet* preflopActions = [h.actions filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"street == %d", ActionStreetPreflop]];
    
    NSOrderedSet* flopActions = [h.actions filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"street == %d", ActionStreetFlop]];
    
    NSOrderedSet* turnActions = [h.actions filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"street == %d", ActionStreetTurn]];
    
    NSOrderedSet* riverActions = [h.actions filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"street == %d", ActionStreetRiver]];
    
    NSOrderedSet* showdownActions = [h.actions filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"street == %d", ActionStreetShowdown]];
    
    XCTAssertEqual(preflopActions.count, (NSUInteger)8, @"Preflop count");
    XCTAssertEqual(flopActions.count, (NSUInteger)7, @"Flop count");
    XCTAssertEqual(turnActions.count, (NSUInteger)6, @"Turn Actions");
    
    XCTAssertEqual(riverActions.count, (NSUInteger)0, @"River Actions");
    
    
    Action* sd1 = [showdownActions objectAtIndex:0];
    
    
    XCTAssertEqual(showdownActions.count, (NSUInteger)3, @"Showdown Actions");
    
    XCTAssertEqual(dlrSeat.holeCards.count, (NSUInteger)2, @"Villain5 has two hole cards");
    NSArray* dlrHole = [dlrSeat.holeCards allObjects];
    
    BOOL holeCardsMatch = NO;
    
    Card* hole1 = [dlrHole objectAtIndex:0];
    Card* hole2 = [dlrHole objectAtIndex:1];
    holeCardsMatch = ((hole1.suit == CardSuitDiamonds && hole1.rank == CardRankFour
        && hole2.suit == CardSuitSpades && hole2.rank == CardRankSeven) ||
        (hole2.suit == CardSuitDiamonds && hole2.rank == CardRankFour
         && hole1.suit == CardSuitSpades && hole1.rank == CardRankSeven));
    
    XCTAssert(holeCardsMatch, @"Villain5 hole cards match");
    
    XCTAssert(h.activePlayer != Nil, @"Active player exists");
    XCTAssert([h.activePlayer.name isEqualToString:@"Hero"], @"Active Player is identified");
}

@end
