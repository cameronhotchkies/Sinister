//
//  SRSHandHistoriesLocationWindowController.h
//  Sinister
//
//  Created by Cameron Hotchkies on 1/18/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SRSHandHistoriesLocationWindowController : NSWindowController

@property (nonatomic, assign) IBOutlet NSButton *addHandHistory;
@property (nonatomic, assign) IBOutlet NSButton *deleteHandHistory;

- (IBAction)addNewHandHistoryPath:(id)sender;
- (IBAction)removeSelectedHandHistoryPath:(id)sender;

@end
