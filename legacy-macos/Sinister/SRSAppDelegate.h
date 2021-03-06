//
//  SRSAppDelegate.h
//  Sinister
//
//  Created by Cameron Hotchkies on 1/18/14.
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


#import <Cocoa/Cocoa.h>

#import "SRSHandHistoriesLocationWindowController.h"
#import "SRSPreferencesWindowController.h"
#import "SRSPlayerStatsWindowController.h"
#import "SRSHandExpectedValueWindowController.h"
#import "SRSParseEngine.h"
#import "SRSInitialSetupWindowController.h"

@interface SRSAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) NSWindow *logLocations;

@property (strong) SRSHandHistoriesLocationWindowController *handLocController;
@property (strong) SRSPreferencesWindowController *preferences;
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

- (void)observeManagedObjectContext:(NSManagedObjectContext*)context;
- (void)removeObservedManagedObjectContext:(NSManagedObjectContext*)context;

@end
