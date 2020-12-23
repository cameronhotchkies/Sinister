//
//  SRSInitialSetupWindowController.h
//  Sinister
//
//  Created by Cameron Hotchkies on 2/7/14.
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
