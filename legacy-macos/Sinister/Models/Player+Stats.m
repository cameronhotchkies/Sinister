//
//  Player+Stats.m
//  Sinister
//
//  Created by Cameron Hotchkies on 1/27/14.
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


#import "Player+Stats.h"
#import "SRSAppDelegate.h"
#import "Seat.h"
#import "Hand+Stats.h"
#import "Action+Constants.h"
#import "Site.h"
#import "NSDecimalNumber+Abs.h"
#import "GameFormat+Constants.h"

@implementation Player (Stats)

- (NSInteger)handsPlayed {
    NSSet* ph = self.seats;
    return ph.count;
}

- (NSDate*)mostRecentlySeen {
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    NSManagedObjectContext *aMOC = d.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Seat"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(player == %@)", self]];
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey:@"hand.date"
                                                       ascending:NO];
    
    [fetchRequest setSortDescriptors: [NSArray arrayWithObject:sd]];

    
    fetchRequest.resultType = NSDictionaryResultType;
    
    NSExpressionDescription* lastSeenDescription = [[NSExpressionDescription alloc] init];
    [lastSeenDescription setName:@"lastSeen"];
    
    NSExpression* dateExpression = [NSExpression expressionForKeyPath:@"hand.date"];
    
    [lastSeenDescription setExpression:dateExpression];
    
    [lastSeenDescription setExpressionResultType:NSDateAttributeType];
    
    fetchRequest.fetchLimit = 1;
    fetchRequest.propertiesToFetch = @[lastSeenDescription];
    
    
    // Execute the fetch
    NSError *error;
    NSArray *seats = [aMOC executeFetchRequest:fetchRequest error:&error];
    
    if ([seats count] > 0) {
        NSDictionary* d = [seats objectAtIndex:0];
        
        return [d objectForKey:@"lastSeen"];//[NSDate dateWithTimeIntervalSince1970:dt];;
    } else {
        return nil;
    }
    
}

- (NSInteger)pfr {
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    NSManagedObjectContext *aMOC = d.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Action"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    
    // Show (6) or above could give false positives as it doesn't reflect real bet action
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(player == %@ and street == %d and action < 6)", self, ActionStreetPreflop]];
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey:@"hand.handID"
                                                       ascending:NO];
    
    [fetchRequest setSortDescriptors: [NSArray arrayWithObject:sd]];
    // Execute the fetch
    NSError *error;
    NSArray *actions = [aMOC executeFetchRequest:fetchRequest error:&error];
    
    NSMutableDictionary* compressed = [[NSMutableDictionary alloc] init];
    
    for (Action* a in actions) {
        if ([compressed objectForKey:a.hand.handID] != nil) {
            ActionEvent old = [[compressed objectForKey:a.hand.handID] integerValue];
            ActionEvent max = MAX(old, a.action);
            [compressed setObject:[NSNumber numberWithInt:max] forKey:a.hand.handID];
        } else {
            [compressed setObject:[NSNumber numberWithInt:a.action] forKey:a.hand.handID];
        }
    }
    
    NSPredicate* p = [NSPredicate predicateWithFormat:@"self == %d", ActionEventRaise];
    
    NSArray* pfrActions = [[compressed allValues] filteredArrayUsingPredicate:p];
    
    NSInteger numerator = pfrActions.count;
    NSInteger denominator = compressed.count;
    double rv = (double)numerator / (double)denominator;
    
    return rv * 100;
}

// Voluntarily put $ in pot
- (NSInteger)vpip {
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    NSManagedObjectContext *aMOC = d.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Action"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    //and site.name == %@
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(player == %@ and street == %d)", self, ActionStreetPreflop]];
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey:@"hand.handID"
                                                       ascending:NO];
    
    [fetchRequest setSortDescriptors: [NSArray arrayWithObject:sd]];
    // Execute the fetch
    NSError *error;
    NSArray *actions = [aMOC executeFetchRequest:fetchRequest error:&error];
    
    NSMutableDictionary* compressed = [[NSMutableDictionary alloc] init];
    
    for (Action* a in actions) {
        // Show could give false positives as it doesn't reflect real bet action
        if (a.action < ActionEventShow) {
            if ([compressed objectForKey:a.hand.handID] != nil) {
                ActionEvent old = [[compressed objectForKey:a.hand.handID] integerValue];
                ActionEvent max = MAX(old, a.action);
                [compressed setObject:[NSNumber numberWithInt:max] forKey:a.hand.handID];
            } else {
                [compressed setObject:[NSNumber numberWithInt:a.action] forKey:a.hand.handID];
            }
        }
    }
    
    NSPredicate* p = [NSPredicate predicateWithFormat:@"self > %d", ActionEventPost];
    
    NSArray* vpipActions = [[compressed allValues] filteredArrayUsingPredicate:p];
    
    NSInteger numerator = vpipActions.count;
    NSInteger denominator = compressed.count;
    double rv = (double)numerator / (double)denominator;
    
    return rv * 100;
}


- (double)aggressionFactor {
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    NSManagedObjectContext *aMOC = d.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Action"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(player == %@ and street != %d)", self, ActionStreetPreflop]];
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey:@"hand.handID"
                                                       ascending:NO];
    
    [fetchRequest setSortDescriptors: [NSArray arrayWithObject:sd]];

    NSError *error;
    NSArray *actions = [aMOC executeFetchRequest:fetchRequest error:&error];
    
    NSInteger numerator = 0;
    NSInteger denominator = 0;
    
    for (Action* a in actions) {
        // Show could give false positives as it doesn't reflect real bet action
        if (a.action == ActionEventRaise || a.action == ActionEventBet) {
            numerator += 1;
        } else if (a.action == ActionEventCall) {
            denominator += 1;
        }
    }
    
    // This is an unlikely situation, but div by zero is bad
    if (denominator == 0) {
        denominator = 1;
    }
    
    double rv = (double)numerator / (double)denominator;
    
    return rv;
}

- (double)aggressionFactorFlop {
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    NSManagedObjectContext *aMOC = d.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Action"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(player == %@ and street == %d)", self, ActionStreetFlop]];
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey:@"hand.handID"
                                                       ascending:NO];
    
    [fetchRequest setSortDescriptors: [NSArray arrayWithObject:sd]];
    // Execute the fetch
    NSError *error;
    NSArray *actions = [aMOC executeFetchRequest:fetchRequest error:&error];
    
    NSInteger numerator = 0;
    NSInteger denominator = 0;
    
    for (Action* a in actions) {
        // Show could give false positives as it doesn't reflect real bet action
        if (a.action == ActionEventRaise || a.action == ActionEventBet) {
            numerator += 1;
        } else if (a.action == ActionEventCall) {
            denominator += 1;
        }
    }
    
    // This is an unlikely situation, but div by zero is bad
    if (denominator == 0) {
        denominator = 1;
    }
    
    double rv = (double)numerator / (double)denominator;
    
    return rv;
}

- (double)aggressionFactorTurn {
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    NSManagedObjectContext *aMOC = d.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Action"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    //and site.name == %@
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(player == %@ and street == %d)", self, ActionStreetTurn]];
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey:@"hand.handID"
                                                       ascending:NO];
    
    [fetchRequest setSortDescriptors: [NSArray arrayWithObject:sd]];
    // Execute the fetch
    NSError *error;
    NSArray *actions = [aMOC executeFetchRequest:fetchRequest error:&error];
    
    NSInteger numerator = 0;
    NSInteger denominator = 0;
    
    for (Action* a in actions) {
        // Show could give false positives as it doesn't reflect real bet action
        if (a.action == ActionEventRaise || a.action == ActionEventBet) {
            numerator += 1;
        } else if (a.action == ActionEventCall) {
            denominator += 1;
        }
    }
    
    // This is an unlikely situation, but div by zero is bad
    if (denominator == 0) {
        denominator = 1;
    }
    
    double rv = (double)numerator / (double)denominator;
    
    return rv;
}

- (double)aggressionFactorRiver {
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    NSManagedObjectContext *aMOC = d.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Action"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(player == %@ and street == %d)", self, ActionStreetRiver]];
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey:@"hand.handID"
                                                       ascending:NO];
    
    [fetchRequest setSortDescriptors: [NSArray arrayWithObject:sd]];
    // Execute the fetch
    NSError *error;
    NSArray *actions = [aMOC executeFetchRequest:fetchRequest error:&error];
    
    NSInteger numerator = 0;
    NSInteger denominator = 0;
    
    for (Action* a in actions) {
        // Show could give false positives as it doesn't reflect real bet action
        if (a.action == ActionEventRaise || a.action == ActionEventBet) {
            numerator += 1;
        } else if (a.action == ActionEventCall) {
            denominator += 1;
        }
    }
    
    // This is an unlikely situation, but div by zero is bad
    if (denominator == 0) {
        denominator = 1;
    }
    
    double rv = (double)numerator / (double)denominator;
    
    return rv;
}

- (NSInteger)wentToShowdown {
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    NSManagedObjectContext *aMOC = d.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Action"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    //and site.name == %@
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(player == %@ and street == %d)", self, ActionStreetFlop]];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setReturnsDistinctResults:YES];
    [fetchRequest setPropertiesToFetch:@[@"hand.handID"]];
    
    // Execute the fetch
    NSError *error;
    NSArray *flopHands = [aMOC executeFetchRequest:fetchRequest error:&error];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(player == %@ and street == %d)", self, ActionStreetShowdown]];
    NSArray *sdHands = [aMOC executeFetchRequest:fetchRequest error:&error];
    
    NSInteger numerator = sdHands.count;
    NSInteger denominator = flopHands.count;
    
    // This is an unlikely situation, but div by zero is bad
    if (denominator == 0) {
        denominator = 1;
    }
    
    double rv = (double)numerator / (double)denominator;
    
    return (rv * 100);
}

- (NSInteger)wonMoneyAtShowdown {
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    NSManagedObjectContext *aMOC = d.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Action"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    //and site.name == %@
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(player == %@ and street == %d)", self, ActionStreetShowdown]];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setReturnsDistinctResults:YES];
    [fetchRequest setPropertiesToFetch:@[@"hand.handID"]];
    
    // Execute the fetch
    NSError *error;
    NSArray *sdHands = [aMOC executeFetchRequest:fetchRequest error:&error];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(player == %@ and street == %d and action == %d)", self, ActionStreetShowdown, ActionEventWins]];
    NSArray *winHands = [aMOC executeFetchRequest:fetchRequest error:&error];
    
    NSInteger numerator = winHands.count;
    NSInteger denominator = sdHands.count;
    
    // This is an unlikely situation, but div by zero is bad
    if (denominator == 0) {
        denominator = 1;
    }
    
    double rv = (double)numerator / (double)denominator;
    
    return (rv * 100);
}

- (Player*)findPlayerWithName:(NSString*)name forSite:(Site*)site {
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    NSManagedObjectContext *aMOC = d.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Player"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(name == %@ and site.name == %@)", name, site.name]];
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey: @"name"
                                                       ascending:YES];
    
    [fetchRequest setSortDescriptors: [NSArray arrayWithObject:sd]];
    // Execute the fetch
    NSError *error;
    NSArray *players = [aMOC executeFetchRequest:fetchRequest error:&error];
    
    // TODO: check error
    
    Player *rv;
    
    if ([players count] == 0) {
        rv = nil;
    } else {
        rv = [players objectAtIndex:0];
    }
    
    return rv;
}

- (NSDecimalNumber*)bigBlindsPerHundredOverall {
    
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    NSManagedObjectContext *aMOC = d.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Seat"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(player == %@ and actions.@count > 0)", self]];
    
    fetchRequest.resultType = NSDictionaryResultType;
    
    NSExpressionDescription* deltaSumDescription = [[NSExpressionDescription alloc] init];
    [deltaSumDescription setName:@"deltaSum"];
    
    [deltaSumDescription setExpression:[NSExpression expressionForFunction:@"divide:by:"
                                                                                                      arguments:[NSArray arrayWithObjects:[NSExpression expressionForKeyPath:@"chipDelta"],
                                                                                                                 [NSExpression expressionForKeyPath:@"hand.gameFormat.bigBlind"], nil]]
                                                                            ];
    
    [deltaSumDescription setExpressionResultType:NSDecimalAttributeType];
    
    fetchRequest.propertiesToFetch = [NSArray arrayWithObjects:deltaSumDescription, nil];
    NSArray* results = [aMOC executeFetchRequest:fetchRequest error:nil];
    
    NSInteger denominator = results.count / 100;
    //[[fetchResultsDictionary objectForKey:@"deltaCount"] integerValue];
    
    NSDecimalNumber* sum = [NSDecimalNumber zero];
    
    for (NSDictionary* d in results) {
        sum = [sum decimalNumberByAdding:[d objectForKey:@"deltaSum"]];
    }
    
    NSDecimalNumber* numerator = sum;
    
    if (denominator == 0) {
        return [NSDecimalNumber zero];
    } else {
        NSDecimalNumber* denom = [NSDecimalNumber decimalNumberWithMantissa:denominator
                                                                   exponent:0
                                                                 isNegative:NO];
        NSDecimalNumber* result = [numerator decimalNumberByDividingBy:denom];
        return result;
    }
}


- (double)chipsLostToActivePlayer {
    // TODO: this doesn't account for split pots
    Player* hero = [self findPlayerWithName:self.site.account forSite:self.site];
    
    // Shortcut, as this will be the most common
    if (self == hero) {
        return 0;
    }
    
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    NSManagedObjectContext *aMOC = d.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Seat"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(player == %@ and chipDelta != 0)", self]];
    NSError *error;
    
    NSArray* villainPlays = [aMOC executeFetchRequest:fetchRequest error:&error];
    
    double sum = 0;
    
    for (Seat* s in villainPlays) {
        
        NSDecimalNumber* villainDelta = s.chipDelta;
        
        if ([villainDelta compare:[NSDecimalNumber zero]] != NSOrderedSame) {
            Seat* heroSeat = nil;
            for (Seat* os in s.hand.seats) {
                if (os.player == hero) {
                    heroSeat = os;
                }
            }
            
            NSDecimalNumber* heroDelta = heroSeat.chipDelta;
            //            Hand* h = s.hand;
            //            NSString* handID = h.handID;
            
            if ([heroDelta compare:[NSDecimalNumber zero]] == NSOrderedSame) {
                // skip this round
                // Hero didn't participate
            } else if ([heroDelta compare:[NSDecimalNumber zero]] == NSOrderedAscending
                       && [villainDelta compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
                // In the event of a split pot this gets complex
                // TODO: scrub the actions to see if either actually won anything
                // Otherwise don't adjust sum
//                for (Action* a in s.actions) {
//                    if (a.action == ActionEventWins) {
//                        // This appears to be due to the rake
//                        NSLog(@"Both players lost, but villain won");
//                    }
//                }
//                for (Action* a in heroSeat.actions) {
//                    if (a.action == ActionEventWins) {
//                        NSLog(@"Both players lost, but hero won");
//                    }
//                }
            } else if ([heroDelta compare:[NSDecimalNumber zero]] == NSOrderedDescending
                       && [villainDelta compare:[NSDecimalNumber zero]] == NSOrderedDescending) {
                // Both won, this could be a split pot as well
                // TODO: figure this out
//                NSLog(@"Split pot, both players win");
            } else {
                NSDecimalNumber* realDelta = [villainDelta absoluteMinimum:heroDelta];
                
                if ([realDelta compare:[NSDecimalNumber zero]] == NSOrderedDescending) {
                    //NSLog(@"When does this happen? %@", handID);
                }
                
                if (realDelta == heroDelta) {
                    sum += [heroDelta doubleValue];
                } else {
                    // This is most likely a negative value
                    sum -= [villainDelta doubleValue];
                }
            }
            
        }
    }
    
    return sum;
}

@end
