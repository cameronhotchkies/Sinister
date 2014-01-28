//
//  SRSParseEngineWindowController.h
//  Sinister
//
//  Created by Cameron Hotchkies on 1/27/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SRSParseEngineWindowController : NSWindowController

@property (weak) IBOutlet NSTextField* fileCount;
@property (weak) IBOutlet NSTextField* handsParsedCount;
@property (weak) IBOutlet NSManagedObjectContext* aMOC;
@property NSInteger junk;

- (NSInteger)handsParsed;

- (IBAction)goClicked:(id)sender;

@end
