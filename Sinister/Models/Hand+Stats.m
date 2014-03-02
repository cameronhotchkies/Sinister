//
//  Hand+Stats.m
//  Sinister
//
//  Created by Cameron Hotchkies on 1/28/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import "Hand+Stats.h"
#import "Action+Constants.h"
#import "SRSAppDelegate.h"
#import "Seat+Stats.h"

@implementation Hand (Stats)

- (double)amountSpentByPlayer:(Player*)player {
    double sum = 0;
    for (Action* a in self.actions) {
        if (a.player == player && a.action < ActionEventShow && [a.bet compare:[NSDecimalNumber zero]] == NSOrderedDescending) {
            sum += [a.bet doubleValue];
        }
        
    }
    
//    return sum;
    
    for (Seat* s in self.seats) {
        if (s.player == player) {
            double ret = [s.chipDelta doubleValue];
            return ret;
        }
    }
    
    return 0;
}

@end
