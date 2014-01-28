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
    
    Hand *h = [p parseHandData:sampleHandData];
    
    NSOrderedSet *ss = h.seats;
    
    NSString *handID = h.handID;
    
    XCTAssert([handID isEqualToString:@"12345679-010"], @"Match hand ID");
    
    NSDate *date = [NSDate dateWithString:@"2014-01-16 23:59:34"];
    XCTAssertEqual(h.date, [date timeIntervalSince1970], @"Match hand date");
    
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
    
    NSOrderedSet* preflopActions = [h.actions filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"stage == %d", ActionStagePreflop]];
    
    XCTAssert(preflopActions.count == 6, @"Verify preflop actions");
    
    Action* a0 = [preflopActions objectAtIndex:0];
    XCTAssert(a0.action == ActionEventFold, @"Expecting a fold");
    
    Action* a1 = [preflopActions objectAtIndex:1];
    XCTAssert(a1.action == ActionEventCall, @"Expecting a call");
    XCTAssert([a1.bet isEqualToNumber:[self decimalFromString:@"0.10"]], @"Call value is 0.10");
    
    Action* a2 = [preflopActions objectAtIndex:2];
    XCTAssert(a2.action == ActionEventRaise, @"Expecting a raise");
    XCTAssert([a2.bet isEqualToNumber:[self decimalFromString:@"0.50"]], @"Raise value is 0.50");
    
    Action* a3 = [preflopActions objectAtIndex:3];
    XCTAssert(a3.action == ActionEventCall, @"Expecting a call");
    XCTAssert([a3.bet isEqualToNumber:[self decimalFromString:@"0.45"]], @"Call value is 0.45");
    
    Action* a4 = [preflopActions objectAtIndex:4];
    XCTAssert(a4.action == ActionEventFold, @"Expecting a fold");
    
    Action* a5 = [preflopActions objectAtIndex:5];
    XCTAssert(a5.action == ActionEventFold, @"Expecting a fold");
    
    NSOrderedSet* flopActions = [h.actions filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"stage == %d", ActionStageFlop]];
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
    
    Hand *h = [p parseHandData:handData];
    
    NSOrderedSet *ss = h.seats;
    
    NSString *handID = h.handID;
    
    XCTAssert([handID isEqualToString:@"16693885-51"], @"Match hand ID");
    
    NSDate *date = [NSDate dateWithString:@"2014-01-17 00:04:15"];
    XCTAssertEqual(h.date, [date timeIntervalSince1970], @"Match hand date");
    
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
    
    NSOrderedSet* preflopActions = [h.actions filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"stage == %d", ActionStagePreflop]];
    
    NSOrderedSet* flopActions = [h.actions filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"stage == %d", ActionStageFlop]];
    
    NSOrderedSet* turnActions = [h.actions filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"stage == %d", ActionStageTurn]];
    
    NSOrderedSet* riverActions = [h.actions filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"stage == %d", ActionStageRiver]];
    
    NSOrderedSet* showdownActions = [h.actions filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"stage == %d", ActionStageShowdown]];
    
    XCTAssertEqual(preflopActions.count, (NSUInteger)6, @"Preflop count");
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
