//
//  SRSLogImportProgressWindowController.h
//  Sinister
//
//  Created by Cameron Hotchkies on 2/14/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SRSLogImportProgressWindowController : NSWindowController <NSWindowDelegate>

@property (weak) IBOutlet NSProgressIndicator* progress;

- (void)incrementProgressIndicator;
- (void)setMax:(NSInteger)max;

@end
