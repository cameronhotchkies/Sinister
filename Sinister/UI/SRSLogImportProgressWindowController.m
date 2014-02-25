//
//  SRSLogImportProgressWindowController.m
//  Sinister
//
//  Created by Cameron Hotchkies on 2/14/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import "SRSLogImportProgressWindowController.h"

@interface SRSLogImportProgressWindowController ()

@end

@implementation SRSLogImportProgressWindowController

- (id)initWithWindow:(NSWindow *)window
{
    if ([NSThread isMainThread]) {
        NSLog(@"Init from main");
    } else {
        NSLog(@"Init from non-main");
    }
    
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidResignKey:(NSNotification *)notification {
    NSLog(@"Resigned key");
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
    NSLog(@"Got key");
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self.progress setIndeterminate:NO];
    [self.progress setUsesThreadedAnimation:YES];
    [self.progress becomeFirstResponder];
    
    
    
    if (self.window.isKeyWindow) {
        NSLog(@"isKey onload");
    } else {
        NSLog(@"notKey onload");
        [self.window becomeKeyWindow];
    }
}


- (void)incrementProgressIndicator {
    if ([NSThread isMainThread]) {
        NSLog(@"Increment from main");
    } else {
        NSLog(@"Increment from non-main");
    }
    if (self.window.isKeyWindow) {
        NSLog(@"isKey onInc");
    } else {
        NSLog(@"notKey onInc");
        [self.window becomeKeyWindow];
    }
    
    [self.progress incrementBy:1.0f];
}

- (void)setMax:(NSInteger)max {
    if ([NSThread isMainThread]) {
        NSLog(@"setMax from main");
    } else {
        NSLog(@"setMax from non-main");
    }
    if (self.window.isKeyWindow) {
        NSLog(@"isKey onSetMax");
    } else {
        NSLog(@"notKey onSetMax");
        [self.window becomeKeyWindow];
    }
    self.progress.maxValue = max;
    [self.progress startAnimation:nil];
}

@end
