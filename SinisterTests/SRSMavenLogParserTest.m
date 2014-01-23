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

- (void)testExample
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
    
    NSUInteger ssc = ss.count;
    
    XCTAssertEqual((NSUInteger)5, ssc, @"There are five players in the hand");
    
    Seat* sbSeat = (Seat *)[h.seats objectAtIndex:0];
    NSString *sName = sbSeat.player.name;
    XCTAssert([sName isEqualToString:@"Villain2"]);
    
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
    
//    for (Action* a in h.actions) {
//        [h.actions filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"stage == %d", ActionStagePreflop]];
//    }
}

@end
