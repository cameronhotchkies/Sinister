//
//  Hand+Stats.m
//  Sinister
//
//  Created by Cameron Hotchkies on 1/28/14.
//  Copyright (c) 2014 Srs Biznas. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


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
