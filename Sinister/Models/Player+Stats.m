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
#import "Hand.h"
#import "Action+Constants.h"

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
    
    NSPredicate* p = [NSPredicate predicateWithFormat:@"self > %d", ActionEventCheck];
    
    NSArray* vpipActions = [[compressed allValues] filteredArrayUsingPredicate:p];
    
    NSInteger numerator = vpipActions.count;
    NSInteger denominator = compressed.count;
    double rv = (double)numerator / (double)denominator;
    
    return rv * 100;
}

@end
