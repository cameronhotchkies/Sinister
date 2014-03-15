//
//  SRSSeatViewController.h
//  Sinister
//
//  Created by Cameron Hotchkies on 3/2/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Seat+Stats.h"

@interface SRSSeatViewController : NSViewController

@property (weak) IBOutlet NSView* backCircle;
@property (weak) IBOutlet NSTextField* playerNameView;
@property (weak) IBOutlet NSView* dealerButton;

@property (strong) NSString* playerName;

@property (strong) Seat* seat;

- (void)fold;

@end
