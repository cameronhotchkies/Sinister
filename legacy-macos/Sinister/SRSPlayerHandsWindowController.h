//
//  SRSPlayerHandsWindowController.h
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


#import <Cocoa/Cocoa.h>

#import "Player+Stats.h"
#import "SRSHandReplayWindowController.h"

@interface SRSPlayerHandsWindowController : NSWindowController

@property (strong) Player* player;
@property (strong) NSArray* hands;

@property (weak) IBOutlet NSTableView* handsTable;
@property (weak) IBOutlet NSArrayController* handsArray;

@property (strong) SRSHandReplayWindowController* handReplay;

- (IBAction)showPlayerHand:(id)sender;

@end
