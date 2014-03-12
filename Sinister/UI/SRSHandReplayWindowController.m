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
}

- (Hand*)hand {
    return _hand;
}

- (void)setHand:(Hand*)hand {
    _hand = hand;
    
    self.window.title = hand.handID;
    
    for (Seat* s in hand.seats) {
        NSInteger position = s.position;
        
        switch (position) {
            case 1:
                self.seat1ViewController.seat = s;
                break;
            case 2:
                self.seat2ViewController.seat = s;
                break;
            case 3:
                self.seat3ViewController.seat = s;
                break;
            case 4:
                self.seat4ViewController.seat = s;
                break;
            case 5:
                self.seat5ViewController.seat = s;
                break;
            case 6:
                self.seat6ViewController.seat = s;
                break;
            case 7:
                self.seat7ViewController.seat = s;
                break;
            case 8:
                self.seat8ViewController.seat = s;
                break;
            case 9:
                self.seat9ViewController.seat = s;
                break;
            default:
                break;
        }
    }
}

- (NSString*)readablePost:(NSString*)betAmount forAction:(Action*)action {
    NSString* blindType = @"";
    
    if (action.supplement == SupplementPostBigBlind) {
        blindType = @"big";
    } else if (action.supplement == SupplementPostSmallBlind) {
        blindType = @"small";
    } else {
        blindType = @"";
    }
    
    return [NSString stringWithFormat:@"%@ posts %@ blind of %@\n", action.player.name, blindType, betAmount];
}

- (NSString*)readableRaise:(NSString*)betAmount forAction:(Action*)action {
    return [NSString stringWithFormat:@"%@ raises to %@\n", action.player.name, betAmount];
}

- (NSString*)readableAction:(Action*)action {
    Player *p;
    
    p = action.player;
    
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    NSString* betAmount = [formatter stringFromNumber:action.bet];
    
    switch (action.action) {
        case ActionEventFold:
            return [NSString stringWithFormat:@"%@ folds\n", p.name];
            break;
        case ActionEventCheck:
            return [NSString stringWithFormat:@"%@ checks\n", p.name];
        case ActionEventPost:
            return [self readablePost:betAmount forAction:action];
        case ActionEventCall:
            return [NSString stringWithFormat:@"%@ calls %@\n", p.name, betAmount];
        case ActionEventBet:
            return [NSString stringWithFormat:@"%@ bets %@\n", p.name, betAmount];
        case ActionEventRaise:
            return [self readableRaise:betAmount forAction:action];
        case ActionEventShow:
            // TODO: add cards
            return [NSString stringWithFormat:@"%@ shows %@\n", p.name, @"cards"];
        default:
            NSLog(@"Unhandled Action: %d", action.action);
            return @"";
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

- (IBAction)nextAction:(id)sender {
    if (self.currentAction < self.hand.actions.count) {
        
        Action* newAction = [self.hand.actions objectAtIndex:self.currentAction];
        
        NSString* newActionText = [self readableAction:newAction];
        
        if (newAction.street != self.street) {
            
            NSString* streetText = [self streetToText:newAction.street];
            self.actionText.string = [self.actionText.string stringByAppendingString:streetText];
            
            self.street = newAction.street;
        }
        
        self.actionText.string = [self.actionText.string stringByAppendingString:newActionText];
        [self.actionText scrollRangeToVisible: NSMakeRange(self.actionText.string.length, 0)];
        
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
