//
//  SRSPreferencesWindowController.h
//  Sinister
//
//  Created by Cameron Hotchkies on 1/27/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SRSPreferencesWindowController : NSWindowController <NSTableViewDataSource,NSTableViewDelegate>

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;

@end
