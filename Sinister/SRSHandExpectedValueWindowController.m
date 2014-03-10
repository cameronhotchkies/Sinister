//
//  SRSHandExpectedValueWindowController.m
//  Sinister
//
//  Created by Cameron Hotchkies on 1/31/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import "SRSHandExpectedValueWindowController.h"
#import "SRSAppDelegate.h"
#import "Card+Constants.h"
#import "Seat.h"
#import "SRSHandExpectedValue.h"

@interface SRSHandExpectedValueWindowController ()

@end

@implementation SRSHandExpectedValueWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    self.aMOC = d.managedObjectContext;
    [self generateEVforHands];
}

- (void)generateEVforHands {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Seat"
                                              inManagedObjectContext:self.aMOC];
    
    [fetchRequest setEntity:entity];
    // TODO: in the case of shared logs the ev will be combined
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(player == hand.activePlayer)"]];
    
    NSError *error;
    NSArray *seats = [self.aMOC executeFetchRequest:fetchRequest error:&error];
    
    NSInteger seatCount = seats.count;
    
    NSMutableDictionary* cardPayouts = [NSMutableDictionary dictionary];
    
    for (Seat* a in seats) {
        NSArray* holeCards = [a.holeCards allObjects];
        
        if (holeCards != nil && holeCards.count > 0) {
            char suit = ' ';
            
            Card* c1 = [holeCards objectAtIndex:0];
            Card* c2 = [holeCards objectAtIndex:1];
            
            
            if (c1.rank != c2.rank) {
                if (c1.suit == c2.suit) {
                    suit = 's';
                } else {
                    suit = 'o';
                }
            }   

            
            NSString* holeString;
            if (c1.rank != c2.rank && ((c1.rank > c2.rank && c2.rank != CardRankAce) || c1.rank == CardRankAce)) {
                holeString = [NSString stringWithFormat:@"%c%c%c", [Card rankToChar:c1.rank],  [Card rankToChar:c2.rank], suit];
            } else if (c1.rank != c2.rank && ((c2.rank > c1.rank && c1.rank != CardRankAce) || c2.rank == CardRankAce)) {
                holeString = [NSString stringWithFormat:@"%c%c%c", [Card rankToChar:c2.rank],  [Card rankToChar:c1.rank], suit];
            } else {
                holeString = [NSString stringWithFormat:@"%c%c", [Card rankToChar:c1.rank],  [Card rankToChar:c2.rank]];
            }
            
            SRSHandExpectedValue* payouts = [cardPayouts objectForKey:holeString];
            
            if (payouts == nil) {
                payouts = [[SRSHandExpectedValue alloc] init];
                payouts.hand = holeString;
            }
            
            [payouts addPayout:a.chipDelta];
            payouts.handCount = seatCount;
     
            [cardPayouts setObject:payouts forKey:holeString];
        }
    }
    
    [self.evArray addObjects:[cardPayouts allValues]];
    
    double expected=0, actual=0;
    
    for (SRSHandExpectedValue* ev in [cardPayouts allValues]) {
        expected += ev.expectedFrequency;
        actual += ev.seen;
    }
    
    NSComparator comparisonBlock = ^(id first,id second) {
        NSString* h1 = (NSString*)first;
        NSString* h2 = (NSString*)second;
        
        char c11 = [h1 characterAtIndex:0];
        char c21 = [h2 characterAtIndex:0];
        
        CardRankType r11 = [Card rankFromChar:c11];
        CardRankType r21 = [Card rankFromChar:c21];
    
        
        
        if (r11 != r21) {
            if (r11 == CardRankAce) {
                return NSOrderedDescending;
            } else if (r21 == CardRankAce) {
                return NSOrderedAscending;
            } else if (r11 > r21) {
                return NSOrderedDescending;
            } else {
                return NSOrderedAscending;
            }
        } else {
            char c12 = [h1 characterAtIndex:1];
            char c22 = [h2 characterAtIndex:1];
            
            CardRankType r12 = [Card rankFromChar:c12];
            CardRankType r22 = [Card rankFromChar:c22];
            if (r12 != r22) {
                if (r12 == CardRankAce) {
                    return NSOrderedDescending;
                } else if (r22 == CardRankAce) {
                    return NSOrderedAscending;
                } else if (r12 > r22) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedAscending;
                }
            } else if (h1.length == 3 && h2.length == 3) {
                char suit1 = [h1 characterAtIndex:2];
                
                if (suit1 == 's') {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedAscending;
                }
            }
        }
        
        return NSOrderedAscending;
    };
    
    NSSortDescriptor* sd = [NSSortDescriptor sortDescriptorWithKey:@"hand"
                                                         ascending:NO
                                                        comparator:comparisonBlock];
    [self.evArray setSortDescriptors:[NSArray arrayWithObject:sd]];
}


- (double)getFrequency:(id)sender {
//    NSLog(@"OK");
    return 0;
}

@end
