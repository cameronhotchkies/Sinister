//
//  SRSHandHistoriesLocationWindowController.m
//  Sinister
//
//  Created by Cameron Hotchkies on 1/18/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import "SRSHandHistoriesLocationWindowController.h"

@interface SRSHandHistoriesLocationWindowController ()

@end

@implementation SRSHandHistoriesLocationWindowController

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

- (IBAction)addNewHandHistoryPath:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setTreatsFilePackagesAsDirectories:YES];
    [openDlg setPrompt:@"Select"];

    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    NSArray *currentLocations = [def arrayForKey:@"HandPaths"];
    
    if ([openDlg runModal] == NSOKButton )
    {
        NSArray* files = [openDlg URLs];
        
        NSMutableArray *clm = [currentLocations mutableCopy];
        
        if (clm == Nil)
        {
            clm = [[NSMutableArray alloc] init];
        }
        
        for (NSURL *u in files)
        {
            [clm addObject:[u absoluteString]];
        }
        
        [def setObject:clm forKey:@"HandPaths"];
        
        [def synchronize];
    }
    
}

- (IBAction)removeSelectedHandHistoryPath:(id)sender
{
    // TODO: remove
}

@end
