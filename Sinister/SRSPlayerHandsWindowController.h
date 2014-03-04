//
//  SRSPlayerHandsWindowController.h
//  Sinister
//
//  Created by Cameron Hotchkies on 2/6/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Player+Stats.h"
#import "SRSHandReplayWindowController.h"

@interface SRSPlayerHandsWindowController : NSWindowController

@property (strong) Player* player;
@property (strong) NSArray* hands;

@property (weak) IBOutlet NSTableView* handsTable;
@property (weak) IBOutlet NSArrayController* handsArray;

@property (strong) SRSHandReplayWindowController* handReplay;

- (IBAction)showPlayerHand:(id)sender;

@end
