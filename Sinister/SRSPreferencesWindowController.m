//
//  SRSPreferencesWindowController.m
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


#import "SRSPreferencesWindowController.h"

@interface SRSPreferencesWindowController ()

@end

@implementation SRSPreferencesWindowController

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
    [self.window.contentView addSubview:self.generalView];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSArray *handPaths = [def arrayForKey:@"HandPaths"];
    
    return handPaths.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSArray *handPaths = [def arrayForKey:@"HandPaths"];
    
    NSString* key = [handPaths objectAtIndex:row];
    if ([tableColumn.identifier isEqualToString:@"site"]) {
        return @"SWC";
    } else {
        return key;
    }
}


- (IBAction)generalPreferences:(id)sender {
    [self.siteView removeFromSuperview];
    [self.window.contentView addSubview:self.generalView];
}

- (IBAction)sitePreferences:(id)sender {
    [self.generalView removeFromSuperview];
    [self.window.contentView addSubview:self.siteView];
}

@end
