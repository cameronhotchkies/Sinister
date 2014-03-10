//
//  SRSParseEngineWindowController.m
//  Sinister
//
//  Created by Cameron Hotchkies on 1/27/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import "SRSParseEngineWindowController.h"
#import "SRSAppDelegate.h"
#import "SRSMavenHandFileParser.h"

@interface SRSParseEngineWindowController ()

@end

@implementation SRSParseEngineWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (NSArray*)logfiles {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSArray *handPaths = [def arrayForKey:@"HandPaths"];
    
    NSString* path = [handPaths objectAtIndex:0];
    
    
    NSArray *dirContents = [[NSFileManager defaultManager]  contentsOfDirectoryAtURL:[NSURL URLWithString:path] includingPropertiesForKeys:nil options:0 error:nil];
    
    return dirContents;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    self.aMOC = d.managedObjectContext;
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSArray* dirContents = [self logfiles];
    
//    NSLog(@"Files to parse: %ld", dirContents.count);
    
    [self.fileCount setStringValue:[NSString stringWithFormat:@"%ld", dirContents.count]];
}

- (NSInteger)handsParsed {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Hand"
                                              inManagedObjectContext:self.aMOC];
    
    [fetchRequest setEntity:entity];
    
    // make sure the results are sorted as well
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey: @"name"
                                                       ascending:YES];
    
    [fetchRequest setSortDescriptors: [NSArray arrayWithObject:sd]];
    // Execute the fetch
    NSError *error;
    NSArray *hands = [self.aMOC executeFetchRequest:fetchRequest error:&error];
    
    return hands.count;
}

- (IBAction)goClicked:(id)sender {

    NSArray* logs = [self logfiles];
    
    for (id l in logs) {
        NSString* f = [NSString stringWithContentsOfURL:l encoding:NSUTF8StringEncoding error:nil];
        NSArray* hands = [f componentsSeparatedByString:@"\n\n\n"];
//        NSLog(@"Hand count: %ld", hands.count);
    }
    [self.aMOC save:nil];
}

@end
