//
//  SRSInitialSetupWindowController.h
//  Sinister
//
//  Created by Cameron Hotchkies on 2/7/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SRSInitialSetupWindowController : NSWindowController

@property (weak) IBOutlet NSView* introView;
@property (weak) IBOutlet NSWindow* sealsWindow;

@property (weak) IBOutlet NSTextField* sealsDetection;
@property (weak) IBOutlet NSTextField* sealsDetectedPath;

@property (weak) IBOutlet NSTextField* accountName;

@property (weak) IBOutlet NSButton* addAccount;


- (IBAction)setupForSealsWithClubs:(id)sender;
- (IBAction)changeDetectedPath:(id)sender;
- (IBAction)addSealsAccount:(id)sender;

@end
