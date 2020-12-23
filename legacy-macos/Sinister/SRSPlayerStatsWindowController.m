//
//  SRSPlayerStatsWindowController.m
//  Sinister
//
//  Created by Cameron Hotchkies on 1/27/14.
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


#import "SRSPlayerStatsWindowController.h"
#import "SRSAppDelegate.h"
#import "Seat+Stats.h"

@interface SRSPlayerStatsWindowController ()

@end

@implementation SRSPlayerStatsWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
        self.aMOC = d.managedObjectContext;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(managedObjectContextChanged:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:self.aMOC];
    }
    return self;
}

- (void)managedObjectContextChanged:(NSNotification*)notification {
    [self.playerArray rearrangeObjects];
    [self.playerTable reloadData];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    NSSortDescriptor* playerSort = [NSSortDescriptor sortDescriptorWithKey:@"mostRecentlySeen" ascending:NO];
    [self.playerArray setSortDescriptors:[NSArray arrayWithObject:playerSort]];
}


- (IBAction)moreDetails:(id)sender {

    NSButton* btn = sender;

    NSInteger playerRow = [self.playerTable rowForView:btn];

    NSArray* arr = self.playerArray.arrangedObjects;
    Player* p = [arr objectAtIndex:playerRow];
    
    // Commented for dev
    self.playerHands = [[SRSPlayerHandsWindowController alloc] initWithWindowNibName:@"SRSPlayerHandsWindowController"];
    self.playerHands.player = p;
    
    [self.playerHands showWindow:nil];
}

@end
