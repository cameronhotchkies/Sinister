//
//  SRSHandReplayWindowController.m
//  Sinister
//
//  Created by Cameron Hotchkies on 3/2/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import "SRSHandReplayWindowController.h"
#import "Seat+Stats.h"
#import "Action+Constants.h"
#import "Player+Stats.h"

@interface SRSHandReplayWindowController ()

@end

@implementation SRSHandReplayWindowController

@synthesize hand = _hand;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        self.street = ActionStreetPreflop;
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    [self.seat1View addSubview:self.seat1ViewController.view];
    [self.seat2View addSubview:self.seat2ViewController.view];
    [self.seat3View addSubview:self.seat3ViewController.view];
    [self.seat4View addSubview:self.seat4ViewController.view];
    [self.seat5View addSubview:self.seat5ViewController.view];
    [self.seat6View addSubview:self.seat6ViewController.view];
    [self.seat7View addSubview:self.seat7ViewController.view];
    [self.seat8View addSubview:self.seat8ViewController.view];
    [self.seat9View addSubview:self.seat9ViewController.view];
    
    NSMutableArray* sv = [NSMutableArray array];
    
    [sv addObject:self.seat1ViewController];
    [sv addObject:self.seat2ViewController];
    [sv addObject:self.seat3ViewController];
    [sv addObject:self.seat4ViewController];
    [sv addObject:self.seat5ViewController];
    [sv addObject:self.seat6ViewController];
    [sv addObject:self.seat7ViewController];
    [sv addObject:self.seat8ViewController];
    [sv addObject:self.seat9ViewController];
    
    self.seatViews = sv;
    
}

- (Hand*)hand {
    return _hand;
}

- (void)setHand:(Hand*)hand {
    _hand = hand;
    
    self.window.title = hand.handID;
    
    for (Seat* s in hand.seats) {
        NSInteger position = s.position;
        
        ((SRSSeatViewController*)[self.seatViews objectAtIndex:(position-1)]).seat = s;
        
    }
}

- (void)performFoldAction:(Action*)action {
    Player *p = action.player;

    NSString* playerName = p.name;
    [self addTextToActionLog:[NSString stringWithFormat:@"%@ folds", playerName]];
    
    for (SRSSeatViewController* svc in self.seatViews) {
        if ([svc.playerName isEqualToString:playerName]) {
            [svc fold];
        }
    }
}

- (void)performCheckAction:(Action*)action {
    Player *p = action.player;
    NSString* playerName = p.name;
    [self addTextToActionLog:[NSString stringWithFormat:@"%@ checks", playerName]];
}

- (void)performPostAction:(Action*)action {
    Player *p = action.player;
    NSString* playerName = p.name;
    
    // Bet amount
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    NSString* betAmount = [formatter stringFromNumber:action.bet];
    
    // Blind type
    NSString* blindType = @"";
    
    if (action.supplement == SupplementPostBigBlind) {
        blindType = @"big";
    } else if (action.supplement == SupplementPostSmallBlind) {
        blindType = @"small";
    } else {
        blindType = @"";
    }
    
    [self addTextToActionLog:[NSString stringWithFormat:@"%@ posts %@ blind of %@", playerName, blindType, betAmount]];
}

- (void)performCallAction:(Action*)action {
    Player *p = action.player;
    NSString* playerName = p.name;
    
    // Bet Amount
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    NSString* betAmount = [formatter stringFromNumber:action.bet];
    
    [self addTextToActionLog:[NSString stringWithFormat:@"%@ calls %@", playerName, betAmount]];
}

- (void)performBetAction:(Action*)action {
    Player *p = action.player;
    NSString* playerName = p.name;
    
    // Bet Amount
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    NSString* betAmount = [formatter stringFromNumber:action.bet];
    
    [self addTextToActionLog:[NSString stringWithFormat:@"%@ bets %@", playerName, betAmount]];
}

- (void)performRaiseAction:(Action*)action {
    Player *p = action.player;
    NSString* playerName = p.name;
    
    // Bet Amount
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    NSString* betAmount = [formatter stringFromNumber:action.bet];
    
    [self addTextToActionLog:[NSString stringWithFormat:@"%@ raises to %@", playerName, betAmount]];
}

- (void)performShowAction:(Action*)action {
    Player *p = action.player;
    NSString* playerName = p.name;
    
    // TODO: add cards
    [self addTextToActionLog:[NSString stringWithFormat:@"%@ shows %@", playerName, @"cards"]];
}

- (void)performWinAction:(Action*)action {
    Player *p = action.player;
    NSString* playerName = p.name;
    
    // Bet Amount
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    NSString* betAmount = [formatter stringFromNumber:action.bet];
    
    [self addTextToActionLog:[NSString stringWithFormat:@"%@ wins %@", playerName, betAmount]];
}

- (void)performRefundAction:(Action*)action {
    Player *p = action.player;
    NSString* playerName = p.name;
    
    // Bet Amount
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    NSString* betAmount = [formatter stringFromNumber:action.bet];
    
    [self addTextToActionLog:[NSString stringWithFormat:@"%@ refunded %@", playerName, betAmount]];
}

- (void)performAction:(Action*)action {
    
    switch (action.action) {
        case ActionEventFold:
            [self performFoldAction:action];
            break;
        case ActionEventCheck:
            [self performCheckAction:action];
            break;
        case ActionEventPost:
            [self performPostAction:action];
            break;
        case ActionEventCall:
            [self performCallAction:action];
            break;
        case ActionEventBet:
            [self performBetAction:action];
            break;
        case ActionEventRaise:
            [self performRaiseAction:action];
            break;
        case ActionEventShow:
            [self performShowAction:action];
            break;
        case ActionEventRefunded:
            [self performRefundAction:action];
            break;
        case ActionEventWins:
            [self performWinAction:action];
            break;
        default:
            NSLog(@"Unhandled Action: %d", action.action);
            break;
    }
}

- (NSString*)streetToText:(ActionStreet)street {
    // TODO: include cards dealt
    switch (street) {
        case ActionStreetPreflop:
            return @"*** PREFLOP ***\n";
            break;
        case ActionStreetFlop:
            return @"*** FLOP ***\n";
        case ActionStreetTurn:
            return @"*** TURN ***\n";
        case ActionStreetRiver:
            return @"*** RIVER ***\n";
        case ActionStreetShowdown:
            return @"*** SHOWDOWN ***\n";
        default:
            return @"";
            break;
    }
}

- (void)addTextToActionLog:(NSString*)newText {
    self.actionText.string = [self.actionText.string stringByAppendingFormat:@"%@\n", newText];
    [self.actionText scrollRangeToVisible: NSMakeRange(self.actionText.string.length, 0)];
}

- (IBAction)nextAction:(id)sender {
    if (self.currentAction < self.hand.actions.count) {
        
        Action* newAction = [self.hand.actions objectAtIndex:self.currentAction];
        
        if (newAction.street != self.street) {
            NSString* streetText = [self streetToText:newAction.street];
            self.actionText.string = [self.actionText.string stringByAppendingString:streetText];
            
            self.street = newAction.street;
        }
        
        [self performAction:newAction];
        
        self.currentAction += 1;
    }
}

- (IBAction)prevAction:(id)sender {
    if (self.currentAction > 0) {
        NSLog(@"Go back");
        self.currentAction -= 1;
    }
}

- (void)dealloc {
    self.notes = nil;
}

@end
