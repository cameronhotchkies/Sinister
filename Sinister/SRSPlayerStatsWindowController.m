//
//  SRSPlayerStatsWindowController.m
//  Sinister
//
//  Created by Cameron Hotchkies on 1/27/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import "SRSPlayerStatsWindowController.h"
#import "SRSAppDelegate.h"

@interface SRSPlayerStatsWindowController ()

@end

@implementation SRSPlayerStatsWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    self.aMOC = d.managedObjectContext;

    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    NSSortDescriptor* playerSort = [NSSortDescriptor sortDescriptorWithKey:@"mostRecentlySeen" ascending:NO];
    [self.playerArray setSortDescriptors:[NSArray arrayWithObject:playerSort]];
}

@end
