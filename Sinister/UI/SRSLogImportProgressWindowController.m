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
    [self.progress setIndeterminate:NO];
    [self.progress setUsesThreadedAnimation:YES];
    [self.progress becomeFirstResponder];
    
    
    // Something is stealing the key window
    if (self.window.isKeyWindow) {
    } else {
        [self.window becomeKeyWindow];
    }
}


- (void)incrementProgressIndicator {

    if (!self.window.isKeyWindow) {
        [self.window becomeKeyWindow];
    }
    
    [self.progress incrementBy:1.0f];
}

- (void)setMax:(NSInteger)max {

    if (!self.window.isKeyWindow){
        [self.window becomeKeyWindow];
    }
    
    self.progress.maxValue = max;
    [self.progress startAnimation:nil];
}

@end
