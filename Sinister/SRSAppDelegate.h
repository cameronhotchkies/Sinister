//
//  SRSAppDelegate.h
//  Sinister
//
//  Created by Cameron Hotchkies on 1/18/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SRSHandHistoriesLocationWindowController.h"
#import "SRSPreferencesWindowController.h"
#import "SRSParseEngineWindowController.h"
#import "SRSPlayerStatsWindowController.h"
#import "SRSHandExpectedValueWindowController.h"
#import "SRSParseEngine.h"
#import "SRSInitialSetupWindowController.h"

@interface SRSAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) NSWindow *logLocations;

@property (strong) SRSHandHistoriesLocationWindowController *handLocController;
@property (strong) SRSPreferencesWindowController *preferences;
@property (strong) SRSParseEngineWindowController *parseEngineController;
@property (strong) SRSPlayerStatsWindowController *playerStats;
@property (strong) SRSHandExpectedValueWindowController* expectedValues;
@property (strong) SRSInitialSetupWindowController* initialSetup;

@property (strong) SRSParseEngine* parseEngine;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

- (IBAction)preferencesAction:(id)sender;

- (IBAction)showHandExpectedValues:(id)sender;

- (void)initForGeneralUse;

@end
