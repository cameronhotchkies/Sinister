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
    NSLog(@"OK");
    NSButton* btn = sender;
    
    NSInteger playerRow = [self.playerTable rowForView:btn];
    
    NSArray* arr = self.playerArray.arrangedObjects;
    Player* p = [arr objectAtIndex:playerRow];
    
//    NSString* name = p.name;
    
    self.playerHands = [[SRSPlayerHandsWindowController alloc] initWithWindowNibName:@"SRSPlayerHandsWindowController"];
    self.playerHands.player = p;
    
    [self.playerHands showWindow:nil];
    
//    -[NSTableView rowForView:]
    NSLog(@"KO");
}

@end
