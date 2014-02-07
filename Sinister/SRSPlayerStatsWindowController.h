//
//  SRSPlayerStatsWindowController.h
//  Sinister
//
//  Created by Cameron Hotchkies on 1/27/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Player+Stats.h"

#import "SRSPlayerHandsWindowController.h"

@interface SRSPlayerStatsWindowController : NSWindowController

@property (weak) IBOutlet NSManagedObjectContext* aMOC;
@property (weak) IBOutlet NSArrayController* playerArray;
@property (weak) IBOutlet NSTableView* playerTable;

@property (strong) SRSPlayerHandsWindowController* playerHands;

- (IBAction)moreDetails:(id)sender;

@end
