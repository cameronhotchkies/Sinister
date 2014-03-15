//
//  SRSHandHistoriesLocationWindowController.m
//  Sinister
//
//  Created by Cameron Hotchkies on 1/18/14.
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
