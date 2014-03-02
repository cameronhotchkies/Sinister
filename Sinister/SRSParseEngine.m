//
//  SRSParseEngine.m
//  Sinister
//
//  Created by Cameron Hotchkies on 2/7/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import "SRSParseEngine.h"
#include <CoreServices/CoreServices.h>
#import "Site.h"
#import "ParsedFile.h"
#import "SRSMavenHandFileParser.h"
#import "SRSAppDelegate.h"

@interface CallBackInfo : NSObject 
    @property (weak) SRSParseEngine* parseEngine;
    @property (strong) NSManagedObjectID* siteID;
@end

@implementation CallBackInfo

@end

@implementation SRSParseEngine

// Determine if there is enough configuration setup for general
// use
+ (BOOL)isParseEngineReady:(NSManagedObjectContext*)aMOC {
    // create the fetch request to get all Sites
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Site"
                                              inManagedObjectContext:aMOC];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate: nil];
    
    // make sure the results are sorted as well
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey: @"name"
                                                       ascending:YES];
    
    [fetchRequest setSortDescriptors: [NSArray arrayWithObject:sd]];
    // Execute the fetch
    NSError *error;
    NSArray *sites = [aMOC executeFetchRequest:fetchRequest error:&error];
    
    return sites.count > 0;
}

- (void)createDirectoryMonitor:(NSManagedObjectID*)siteID {
    
    Site* tSite = (Site*)[self.aMOC objectWithID:siteID];
    NSString* scanPath = tSite.handHistoryLocation;
    /* Define variables and create a CFArray object containing
     CFString objects containing paths to watch.
     */
    
    CFStringRef mypath = (__bridge CFStringRef) scanPath;
    CFArrayRef pathsToWatch = CFArrayCreate(NULL, (const void **)&mypath, 1, NULL);
    
    
    CallBackInfo* cbi = [[CallBackInfo alloc] init];
    cbi.siteID = siteID;
    cbi.parseEngine = self;
    
    // stream-specific data here.
    FSEventStreamContext callbackInfo;
    callbackInfo.version = 0;
    callbackInfo.release = nil;
    callbackInfo.retain = nil;
    callbackInfo.copyDescription = nil;
    callbackInfo.info = (void*)CFBridgingRetain(cbi);
    FSEventStreamRef stream;
    CFAbsoluteTime latency = 3.0; /* Latency in seconds */
    
    /* Create the stream, passing in a callback */
    stream = FSEventStreamCreate(NULL,
                                 &myCallbackFunction,
                                 &callbackInfo,
                                 pathsToWatch,
                                 kFSEventStreamEventIdSinceNow, /* Or a previous event ID */
                                 latency,
                                 kFSEventStreamCreateFlagFileEvents /* Flags explained in reference */
                                 );
    
    /* Create the stream before calling this. */
    FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    
    FSEventStreamStart(stream);
}

- (ParsedFile*)fileByName:(NSString*)filename
                  forSite:(Site*)site
                inContext:(NSManagedObjectContext*)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ParsedFile"
                                              inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat: @"(filename == %@ and site == %@)", filename, site]];
     
                                                                                                
    // Execute the fetch
    NSError *error;
    NSArray *files = [context executeFetchRequest:fetchRequest error:&error];
    
    @synchronized(self) {
        if ([files count] > 0) {
            return [files objectAtIndex:0];
        } else {
            ParsedFile* newFile = [[ParsedFile alloc] initWithEntity:entity
                                      insertIntoManagedObjectContext:context];
            newFile.filename = filename;
            newFile.lastModification = 0;
            newFile.parseTime = 0;
            newFile.site = site;

            return newFile;
        }
    }

}

- (Site*)findSiteWithName:(NSString*)name
                inContext:(NSManagedObjectContext*)fastContext {
    
    // create the fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Site"
                                              inManagedObjectContext:fastContext];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(name == %@)", name]];
    
    // make sure the results are sorted as well
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey: @"name"
                                                       ascending:YES];
    
    [fetchRequest setSortDescriptors: [NSArray arrayWithObject:sd]];
    // Execute the fetch
    NSError *error;
    NSArray *sites = [fastContext executeFetchRequest:fetchRequest error:&error];
    
    // TODO: check error
    
    Site *rv = nil;
    
    if ([sites count] != 0) {
        rv = [sites objectAtIndex:0];
    }
    
    return rv;
}

- (void)parseLogFile:(NSString*)filePath
             forSite:(NSManagedObjectID*)siteID
           inContext:(NSManagedObjectContext*)importContext{
    NSString* filename = [[filePath pathComponents] lastObject];
    
    
    Site* s = (Site*)[importContext objectWithID:siteID];
    ParsedFile* pf = [self fileByName:filename forSite:s inContext:importContext];

    NSFileManager* fm = [NSFileManager defaultManager];
    NSDictionary* attribs = [fm attributesOfItemAtPath:filePath error:nil];
    
    NSDate* actualMod = [attribs objectForKey:NSFileModificationDate];
    NSDate* storedMod = [NSDate dateWithTimeIntervalSince1970:pf.lastModification];
    
    @synchronized(self) {
        if ([actualMod compare:storedMod] == NSOrderedDescending) {
            // TODO: Parse
            NSString* f = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:filePath]
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
            NSArray* hands = [f componentsSeparatedByString:@"\n\n\n"];
            NSLog(@"Hand count: %ld", hands.count);
            
            SRSMavenHandFileParser *parser = [[SRSMavenHandFileParser alloc] init];
            [parser parseHands:hands forSiteID:siteID inContext:importContext];
            
            Site* aSite = (Site*)[importContext objectWithID:siteID];
            
            pf = [self fileByName:filename forSite:aSite inContext:importContext];
            
            pf.lastModification = [actualMod timeIntervalSince1970];
            pf.parseTime = [NSDate timeIntervalSinceReferenceDate];

            // ****************************************************
            // Saving the context is on the burden of the caller
            // ****************************************************
            
        } else {
           // NSLog(@"File (%@) wasn't actually modified?", filename);
        }
    }

}

void myCallbackFunction(ConstFSEventStreamRef streamRef,
                        void *context,
                        size_t numEvents,
                        void *eventPaths,
                        const FSEventStreamEventFlags eventFlags[],
                        const FSEventStreamEventId eventIds[]) {
    int i;
    char **paths = eventPaths;
    
    
    CallBackInfo* cbi = (__bridge CallBackInfo*)context;
    
    NSManagedObjectID* siteID = cbi.siteID;
    
    NSManagedObjectContext *importContext = [[NSManagedObjectContext alloc] init];
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    
    [d observeManagedObjectContext:importContext];
    
    NSPersistentStoreCoordinator *coordinator = d.persistentStoreCoordinator;
    [importContext setPersistentStoreCoordinator:coordinator];
    [importContext setUndoManager:nil];

    
    SRSParseEngine* parseEngine = cbi.parseEngine;
    
    for (i=0; i<numEvents; i++) {
        NSString* filePath = [NSString stringWithCString:paths[i] encoding:NSUTF8StringEncoding];
        
        @synchronized(parseEngine) {
            [parseEngine parseLogFile:filePath forSite:siteID inContext:importContext];
            NSError *error = nil;
            [importContext save:&error];
        }
    }
    
    [d removeObservedManagedObjectContext:importContext];
}

- (NSArray*)fetchSites {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Site"
                                              inManagedObjectContext:self.aMOC];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:nil];
    
    // Execute the fetch
    NSError *error;
    NSArray *sites = [self.aMOC executeFetchRequest:fetchRequest error:&error];

    return sites;
}

- (void)initializeProgressWindow {
    [self.progressWindow showWindow:self];
    [self.progressWindow.window makeKeyAndOrderFront:self];
}

- (void)checkForUpdatesSinceLastLaunch:(NSManagedObjectID *)siteID {
    
    
    Site *ms = (Site*)[self.aMOC objectWithID:siteID];
    NSString* path = ms.handHistoryLocation;
    
    
    NSURL* pathUrl = [NSURL fileURLWithPath:path];
    NSArray *dirContents = [[NSFileManager defaultManager]  contentsOfDirectoryAtURL:pathUrl includingPropertiesForKeys:nil options:0 error:nil];
    
    @synchronized(self) {
        
        if (self.progressWindow == nil) {
            self.progressWindow = [[SRSLogImportProgressWindowController alloc] initWithWindowNibName:@"SRSLogImportProgressWindowController"];
        }
        
        [self.progressWindow setMax:[dirContents count]];
        
        [self performSelectorOnMainThread:@selector(initializeProgressWindow) withObject:nil waitUntilDone:NO];
        
        dispatch_queue_t queue = dispatch_queue_create("import hands", NULL);
        dispatch_async(queue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
            });
            
            NSManagedObjectContext *importContext = [[NSManagedObjectContext alloc] init];
            SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
            NSPersistentStoreCoordinator *coordinator = d.persistentStoreCoordinator;
            [importContext setPersistentStoreCoordinator:coordinator];
            [importContext setUndoManager:nil];

            for (NSURL* fileName in dirContents) {
                [self parseLogFile:[fileName path] forSite:siteID inContext:importContext];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressWindow incrementProgressIndicator];
                });
            }
            
            // Save as one large batch
            NSError *error = nil;
            [importContext save:&error];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SRSEngineInitialized"
                                                                object:nil];

            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressWindow close];
            });
        });
    }
}

- (void)checkForNewHandHistories:(id)sender {
    NSArray* sites = [self fetchSites];
    
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    if ([def boolForKey:@"autoImport"] == YES) {
        // perform imports
        for (Site* s in sites) {
            [self checkForUpdatesSinceLastLaunch:[s objectID]];
            
            [self createDirectoryMonitor:s.objectID];
        }
    }
    
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext*) managedObjectContext {
    if (self = [super init]) {
        self.aMOC = managedObjectContext;
        [self checkForNewHandHistories:nil];
    }
    
    return self;
}

@end
