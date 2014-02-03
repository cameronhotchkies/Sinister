//
//  Player+Stats.m
//  Sinister
//
//  Created by Cameron Hotchkies on 1/27/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import "Player+Stats.h"
#import "SRSAppDelegate.h"
#import "Seat.h"
#import "Hand+Stats.h"
#import "Action+Constants.h"
#import "Site.h"

@implementation Player (Stats)

- (NSInteger)handsPlayed {
    NSSet* ph = self.seats;
    return ph.count;
}

- (NSDate*)mostRecentlySeen {
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    NSManagedObjectContext *aMOC = d.managedObjectContext;
    
    // create the fetch request to get all Employees matching the IDs
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Seat"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    //and site.name == %@
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(player == %@)", self]];
    
    // make sure the results are sorted as well
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey:@"hand.date"
                                                       ascending:NO];
    
    [fetchRequest setSortDescriptors: [NSArray arrayWithObject:sd]];
    // Execute the fetch
    NSError *error;
    NSArray *seats = [aMOC executeFetchRequest:fetchRequest error:&error];
    
    if ([seats count] > 0) {
        Seat* s = [seats objectAtIndex:0];
        Hand* h = s.hand;
        NSTimeInterval dt = h.date;
        
        return [NSDate dateWithTimeIntervalSince1970:dt];;
    } else {
        return nil;
    }

}

- (NSInteger)pfr {
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    NSManagedObjectContext *aMOC = d.managedObjectContext;
    
    // create the fetch request to get all Employees matching the IDs
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Action"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    //and site.name == %@
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(player == %@ and stage == %d)", self, ActionStagePreflop]];
    
    // make sure the results are sorted as well
    
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
    
    // create the fetch request to get all Employees matching the IDs
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Action"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    //and site.name == %@
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(player == %@ and stage == %d)", self, ActionStagePreflop]];
    
    // make sure the results are sorted as well
    
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
    
    // create the fetch request to get all Employees matching the IDs
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Action"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    //and site.name == %@
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(player == %@ and stage != %d)", self, ActionStagePreflop]];
    
    // make sure the results are sorted as well
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey:@"hand.handID"
                                                       ascending:NO];
    
    [fetchRequest setSortDescriptors: [NSArray arrayWithObject:sd]];
    // Execute the fetch
    NSError *error;
    NSArray *actions = [aMOC executeFetchRequest:fetchRequest error:&error];
    
    NSInteger numerator = 0;
    NSInteger denominator = 0;
    
    if ([self.name isEqualToString:@"TBaged"]) {
        NSLog(@"halt");
    }
    
    for (Action* a in actions) {
        
        ActionEvent ae = a.action;
        
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
    
    // create the fetch request to get all Employees matching the IDs
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Action"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    //and site.name == %@
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(player == %@ and stage == %d)", self, ActionStageFlop]];
    
    // make sure the results are sorted as well
    
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
    
    // create the fetch request to get all Employees matching the IDs
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Action"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    //and site.name == %@
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(player == %@ and stage == %d)", self, ActionStageTurn]];
    
    // make sure the results are sorted as well
    
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
    
    // create the fetch request to get all Employees matching the IDs
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Action"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    //and site.name == %@
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(player == %@ and stage == %d)", self, ActionStageRiver]];
    
    // make sure the results are sorted as well
    
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
    
    // create the fetch request to get all Employees matching the IDs
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Action"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    //and site.name == %@
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(player == %@ and stage == %d)", self, ActionStageFlop]];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setReturnsDistinctResults:YES];
    [fetchRequest setPropertiesToFetch:@[@"hand.handID"]];
    
    // Execute the fetch
    NSError *error;
    NSArray *flopHands = [aMOC executeFetchRequest:fetchRequest error:&error];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(player == %@ and stage == %d)", self, ActionStageShowdown]];
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
    
    // create the fetch request to get all Employees matching the IDs
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Action"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    //and site.name == %@
       [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(player == %@ and stage == %d)", self, ActionStageShowdown]];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setReturnsDistinctResults:YES];
    [fetchRequest setPropertiesToFetch:@[@"hand.handID"]];
    
    // Execute the fetch
    NSError *error;
    NSArray *sdHands = [aMOC executeFetchRequest:fetchRequest error:&error];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(player == %@ and stage == %d and action == %d)", self, ActionStageShowdown, ActionEventWins]];
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
    
    // create the fetch request to get all Employees matching the IDs
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Player"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(name == %@ and site.name == %@)", name, site.name]];
    
    // make sure the results are sorted as well
    
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


- (double)chipsLostToActivePlayer {
    // TODO: this doesn't account for split pots
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    NSString* activePlayerName = [def objectForKey:@"activePlayer"];
    Player* activePlayer = [self findPlayerWithName:activePlayerName forSite:self.site];
    
    
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    NSManagedObjectContext *aMOC = d.managedObjectContext;
    
    // create the fetch request to get all Employees matching the IDs
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Action"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(player == %@ and action == %d)", activePlayer, ActionEventWins]];
    NSError *error;
    
    NSArray* activePlayerWins = [aMOC executeFetchRequest:fetchRequest error:&error];
    
    double sum = 0;
    
    for (Action* w in activePlayerWins) {
        Hand* wHand = w.hand;
        
        sum += MIN([wHand amountSpentByPlayer:self], [w.bet doubleValue]);
    }
    
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(player == %@ and action == %d)", self, ActionEventWins]];
    
    NSArray* thisPlayerWins = [aMOC executeFetchRequest:fetchRequest error:&error];
    
    for (Action* w in thisPlayerWins) {
        Hand* wHand = w.hand;
        
        sum -= MIN([wHand amountSpentByPlayer:activePlayer], [w.bet doubleValue]);
    }
    
    return sum;
}

@end
