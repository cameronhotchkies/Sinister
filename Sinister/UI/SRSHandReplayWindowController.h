//
//  SRSHandReplayWindowController.h
//  Sinister
//
//  Created by Cameron Hotchkies on 3/2/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SRSSeatViewController.h"
#import "Hand.h"

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

- (void)setHand:(Hand*)hand;

@end
