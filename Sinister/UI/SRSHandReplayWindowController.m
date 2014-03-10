//
//  SRSHandReplayWindowController.m
//  Sinister
//
//  Created by Cameron Hotchkies on 3/2/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import "SRSHandReplayWindowController.h"
#import "Seat+Stats.h"

@interface SRSHandReplayWindowController ()

@end

@implementation SRSHandReplayWindowController

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
    
    [self.seat1View addSubview:self.seat1ViewController.view];
    [self.seat2View addSubview:self.seat2ViewController.view];
    [self.seat3View addSubview:self.seat3ViewController.view];
    [self.seat4View addSubview:self.seat4ViewController.view];
    [self.seat5View addSubview:self.seat5ViewController.view];
    [self.seat6View addSubview:self.seat6ViewController.view];
    [self.seat7View addSubview:self.seat7ViewController.view];
    [self.seat8View addSubview:self.seat8ViewController.view];
    [self.seat9View addSubview:self.seat9ViewController.view];
}

- (void)setHand:(Hand*)hand {
    self.window.title = hand.handID;
    
    for (Seat* s in hand.seats) {
        NSInteger position = s.position;
        
        switch (position) {
            case 1:
                self.seat1ViewController.seat = s;
                break;
            case 2:
                self.seat2ViewController.seat = s;
                break;
            case 3:
                self.seat3ViewController.seat = s;
                break;
            case 4:
                self.seat4ViewController.seat = s;
                break;
            case 5:
                self.seat5ViewController.seat = s;
                break;
            case 6:
                self.seat6ViewController.seat = s;
                break;
            case 7:
                self.seat7ViewController.seat = s;
                break;
            case 8:
                self.seat8ViewController.seat = s;
                break;
            case 9:
                self.seat9ViewController.seat = s;
                break;
            default:
                break;
        }
    }
}

@end
