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
#import "Card+Constants.h"

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

- (void)addCardImages:(Seat*)s {
    
    NSString* img1eps = @"Blue_Back.eps";
    NSString* img2eps = @"Blue_Back.eps";
    
    NSArray* arr = [s.holeCards allObjects];
    
    if (arr.count > 0) {
        img1eps = [NSString stringWithFormat:@"%@.eps", [[((Card*) [arr objectAtIndex:0]) printable] uppercaseString]];
        img2eps = [NSString stringWithFormat:@"%@.eps", [[((Card*) [arr objectAtIndex:1]) printable] uppercaseString]];
    }
    
    NSImage* img1Pre = [NSImage imageNamed:img1eps];//@"KH.eps"];
    NSImage* img2Pre = [NSImage imageNamed:img2eps];//@"KS.eps"];
    
    
    CGRect c1Frame = CGRectMake(15, 20, 50, 70);
    CGRect c2Frame = CGRectMake(25, 16, 50, 70);
    NSImageView* c1 = [[NSImageView alloc] initWithFrame:c1Frame];
    NSImageView* c2 = [[NSImageView alloc] initWithFrame:c2Frame];
    [c1 setImage:img1Pre];
    [c2 setImage:img2Pre];
    
    
    [self.view addSubview:c1];
    [self.view addSubview:c2];
}


- (void)setSeat:(Seat *)seat {
    _seat = seat;
    [self.playerName setStringValue:seat.player.name];
    self.playerName.textColor = [NSColor blackColor];
    
    NSRect bgFrame = CGRectMake(0, 0, self.backCircle.frame.size.width, self.backCircle.frame.size.height);
    SRSSeatBackgroundView* bg = [[SRSSeatBackgroundView alloc] initWithFrame:bgFrame];
    [self.backCircle addSubview:bg];
    
    [self addCardImages:seat];
    
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
