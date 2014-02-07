//
//  SRSPlayerHandsWindowController.m
//  Sinister
//
//  Created by Cameron Hotchkies on 2/6/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import "SRSPlayerHandsWindowController.h"

@interface SRSPlayerHandsWindowController ()

@end

@implementation SRSPlayerHandsWindowController


@synthesize player = _player;

- (void)setPlayer:(Player *)player {
    _player = player;
    // trigger redraws as needed
    
    self.window.title = player.name;
}

- (Player*)player {
    return _player;
}

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
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
