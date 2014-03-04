//
//  SRSSeatViewController.m
//  Sinister
//
//  Created by Cameron Hotchkies on 3/2/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import "SRSSeatViewController.h"

#import "Player+Stats.h"
#import "SRSDealerButtonView.h"
#import "SRSSeatBackgroundView.h"

@interface SRSSeatViewController ()

@end

@implementation SRSSeatViewController

Seat* __strong _seat;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        
    }
    return self;
}

- (void)loadView {
    [super loadView];
    if (_seat == nil) {
        self.playerName.stringValue = @"[vacant]";
        self.playerName.textColor = [NSColor grayColor];
    } else {
        NSString* pn = _seat.player.name;
        NSLog(@"pn: %@", pn);
    }
}

- (void)setSeat:(Seat *)seat {
    _seat = seat;
    [self.playerName setStringValue:seat.player.name];
    self.playerName.textColor = [NSColor blackColor];
    
    NSRect bgFrame = CGRectMake(0, 0, self.backCircle.frame.size.width, self.backCircle.frame.size.height);
    SRSSeatBackgroundView* bg = [[SRSSeatBackgroundView alloc] initWithFrame:bgFrame];
    [self.backCircle addSubview:bg];
    
    if (seat.isDealer) {
        [self.dealerButton setHidden:NO];
        
        
        CGRect dFrm = CGRectMake(0, 0, self.dealerButton.frame.size.width, self.dealerButton.frame.size.height);
        SRSDealerButtonView* dbtn = [[SRSDealerButtonView alloc] initWithFrame:dFrm];
        
        [self.dealerButton addSubview:dbtn];
        
        if ([self.dealerButton.subviews containsObject:dbtn]) {
            NSLog(@"should be there");
        }
        
//        NSTextField* dTxt = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//        dTxt.stringValue = @"D";
//        [self.dealerButton addSubview:dTxt];
    } else {
        [self.dealerButton setHidden:YES];
    }
}

- (Seat*)seat {
    return _seat;
}

@end
