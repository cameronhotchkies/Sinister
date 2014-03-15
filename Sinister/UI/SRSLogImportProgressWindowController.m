//
//  SRSLogImportProgressWindowController.m
//  Sinister
//
//  Created by Cameron Hotchkies on 2/14/14.
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
