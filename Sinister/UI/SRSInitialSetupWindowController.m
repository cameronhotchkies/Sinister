//
//  SRSInitialSetupWindowController.m
//  Sinister
//
//  Created by Cameron Hotchkies on 2/7/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import "SRSInitialSetupWindowController.h"
#import "AnimationFlipWindow.h"
#import "SRSAppDelegate.h"
#import "Site.h"

@interface SRSInitialSetupWindowController ()

@end

@implementation SRSInitialSetupWindowController

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
    
    [self.window setMovable:NO];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)setupForSealsWithClubs:(id)sender {
    AnimationFlipWindow* afw = [[AnimationFlipWindow alloc] init];
    [self performSelector:@selector(lookForSwcApp:) withObject:nil afterDelay:1.0];
    
    [afw flip:self.window toBack:self.sealsWindow];
    [self.sealsWindow setMovable:NO];
}

- (void)lookForSwcApp:(id)sender {
    NSWorkspace *myWorkspace = [NSWorkspace  sharedWorkspace];
    NSArray* applications = [myWorkspace runningApplications];
    
    NSURL* sealsAppUrl = nil;
    
    for (NSRunningApplication* proc in applications) {
        if ([proc.localizedName hasPrefix:@"Seals with Clubs Poker Client"]) {
            sealsAppUrl = [proc executableURL];
            break;
        }
    }
    
    float delay = 0.5;
    
    if (self.sealsDetectedPath.stringValue.length == 0) {
        if (sealsAppUrl == nil) {
            self.sealsDetection.stringValue = @"Seals with Clubs *not* detected";
        } else {
            self.sealsDetection.stringValue = @"Seals with Clubs app detected";
            NSString* pathComponent = [[sealsAppUrl URLByDeletingLastPathComponent] path];
            NSString* hhCandidate = [pathComponent stringByAppendingPathComponent:@"handhistories"];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            BOOL isDir;
            if ([fileManager fileExistsAtPath:hhCandidate isDirectory:&isDir]) {
                
                self.sealsDetectedPath.stringValue = hhCandidate;
                [self.sealsDetectedPath.currentEditor setSelectedRange:NSMakeRange(hhCandidate.length, 0)];
            }
        }
    } else {
        delay = 5;
    }
    
    [self performSelector:@selector(lookForSwcApp:) withObject:nil afterDelay:delay];
}

- (void)changeDetectedPath:(id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setTreatsFilePackagesAsDirectories:YES];
    [openDlg setPrompt:@"Select"];
    
    if ([openDlg runModal] == NSOKButton )
    {
        NSArray* files = [openDlg URLs];
        NSString* handHistory = @"";
        
        for (NSURL *u in files)
        {
            handHistory = [u absoluteString];
        }
        
        self.sealsDetectedPath.stringValue = handHistory;
        [self.sealsDetectedPath.currentEditor setSelectedRange:NSMakeRange(handHistory.length, 0)];
        
    }
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    
    if (textField == self.sealsDetectedPath || textField == self.accountName) {
        if (self.sealsDetectedPath.stringValue.length > 0 &&
            self.accountName.stringValue.length > 0 &&
            [fileManager fileExistsAtPath:self.sealsDetectedPath.stringValue
                              isDirectory:&isDir]) {
                [self.addAccount setEnabled:YES];
            } else {
                [self.addAccount setEnabled:NO];
            }
    }
}

- (IBAction)addSealsAccount:(id)sender {
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    NSManagedObjectContext *aMOC = d.managedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Site"
                                              inManagedObjectContext:aMOC];
    
    
    Site* site = [[Site alloc] initWithEntity:entity
               insertIntoManagedObjectContext:aMOC];
    
    
    site.name = @"Seals With Clubs";
    site.account = self.accountName.stringValue;
    site.handHistoryLocation = self.sealsDetectedPath.stringValue;
    
    [aMOC save:nil];
}

@end
