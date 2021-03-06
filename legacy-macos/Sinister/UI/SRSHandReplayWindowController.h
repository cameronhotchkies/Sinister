//
//  SRSHandReplayWindowController.h
//  Sinister
//
//  Created by Cameron Hotchkies on 3/2/14.
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
#import "SRSSeatViewController.h"
#import "Hand.h"
#import "Action+Constants.h"

@interface SRSHandReplayWindowController : NSWindowController

@property (weak) IBOutlet SRSSeatViewController* seat1ViewController;
@property (weak) IBOutlet SRSSeatViewController* seat2ViewController;
@property (weak) IBOutlet SRSSeatViewController* seat3ViewController;
@property (weak) IBOutlet SRSSeatViewController* seat4ViewController;
@property (weak) IBOutlet SRSSeatViewController* seat5ViewController;
@property (weak) IBOutlet SRSSeatViewController* seat6ViewController;
@property (weak) IBOutlet SRSSeatViewController* seat7ViewController;
@property (weak) IBOutlet SRSSeatViewController* seat8ViewController;
@property (weak) IBOutlet SRSSeatViewController* seat9ViewController;


@property (weak) IBOutlet NSView* seat9View;
@property (weak) IBOutlet NSView* seat1View;
@property (weak) IBOutlet NSView* seat2View;
@property (weak) IBOutlet NSView* seat3View;
@property (weak) IBOutlet NSView* seat4View;
@property (weak) IBOutlet NSView* seat5View;
@property (weak) IBOutlet NSView* seat6View;
@property (weak) IBOutlet NSView* seat7View;
@property (weak) IBOutlet NSView* seat8View;

@property (strong) IBOutlet NSTextView* actionText;
@property (strong) IBOutlet NSTextView* notes;

@property (strong) NSArray* seatViews;

@property (strong) Hand* hand;

@property (assign) NSInteger currentAction;
@property (assign) ActionStreet street;

- (void)setHand:(Hand*)hand;

- (IBAction)nextAction:(id)sender;
- (IBAction)prevAction:(id)sender;

@end
