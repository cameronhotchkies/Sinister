//
//  SRSPlayerHandsWindowController.m
//  Sinister
//
//  Created by Cameron Hotchkies on 2/6/14.
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

- (IBAction)showPlayerHand:(id)sender {
    NSButton* btn = sender;
    
    NSInteger handRow = [self.handsTable rowForView:btn];
    
    NSArray* arr = self.handsArray.arrangedObjects;
    Seat* s = [arr objectAtIndex:handRow];
    Hand*h = s.hand;
    
    self.handReplay = [[SRSHandReplayWindowController alloc] initWithWindowNibName:@"SRSHandReplayWindowController"];

    [self.handReplay showWindow:nil];
    [self.handReplay setHand:h];

}

@end
