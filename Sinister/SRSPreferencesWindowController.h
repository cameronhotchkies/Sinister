//
//  SRSPreferencesWindowController.h
//  Sinister
//
//  Created by Cameron Hotchkies on 1/27/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SRSPreferencesWindowController : NSWindowController <NSTableViewDataSource,NSTableViewDelegate>

@property (weak) NSManagedObjectContext* aMOC;
@property (weak) IBOutlet NSView* siteView;
@property (weak) IBOutlet NSView* generalView;

- (IBAction)generalPreferences:(id)sender;
- (IBAction)sitePreferences:(id)sender;

@end
