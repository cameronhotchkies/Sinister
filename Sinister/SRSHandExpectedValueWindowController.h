//
//  SRSHandExpectedValueWindowController.h
//  Sinister
//
//  Created by Cameron Hotchkies on 1/31/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SRSHandExpectedValueWindowController : NSWindowController

@property (nonatomic, weak) IBOutlet NSArrayController* evArray;
@property (weak) IBOutlet NSManagedObjectContext* aMOC;

- (void)generateEVforHands;
- (double)getFrequency:(id)sender;

@end
