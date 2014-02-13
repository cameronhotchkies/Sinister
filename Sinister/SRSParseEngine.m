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

@interface CallBackInfo : NSObject 
    @property (weak) SRSParseEngine* parseEngine;
    @property (strong) Site* site;
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

- (void)createDirectoryMonitor:(Site*)site {
    NSString* scanPath = site.handHistoryLocation;
    /* Define variables and create a CFArray object containing
     CFString objects containing paths to watch.
     */
    CFStringRef mypath = (__bridge CFStringRef) scanPath;
    CFArrayRef pathsToWatch = CFArrayCreate(NULL, (const void **)&mypath, 1, NULL);
    
    
    CallBackInfo* cbi = [[CallBackInfo alloc] init];
    cbi.site = site;
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

- (ParsedFile*)fileByName:(NSString*)filename forSite:(Site*)site {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ParsedFile"
                                              inManagedObjectContext:self.aMOC];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat: @"(filename == %@ and site == %@)", filename, site]];
     
                                                                                                
    // Execute the fetch
    NSError *error;
    NSArray *files = [self.aMOC executeFetchRequest:fetchRequest error:&error];
    
    if ([files count] > 0) {
        return [files objectAtIndex:0];
    } else {
        ParsedFile* newFile = [[ParsedFile alloc] initWithEntity:entity
                                  insertIntoManagedObjectContext:self.aMOC];
        newFile.filename = filename;
        newFile.lastModification = 0;
        newFile.parseTime = 0;
        newFile.site = site;
        
        return newFile;
    }

}

- (void)parseLogFile:(NSString*)filePath forSite:(Site*)site {
    NSString* filename = [[filePath pathComponents] lastObject];
    ParsedFile* pf = [self fileByName:filename forSite:site];
    
    NSFileManager* fm = [NSFileManager defaultManager];
    NSDictionary* attribs = [fm attributesOfItemAtPath:filePath error:nil];
    
    NSDate* actualMod = [attribs objectForKey:NSFileModificationDate];
    NSDate* storedMod = [NSDate dateWithTimeIntervalSince1970:pf.lastModification];
    
    if ([actualMod compare:storedMod] == NSOrderedDescending) {
        // TODO: Parse
        NSString* f = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:filePath]
                                               encoding:NSUTF8StringEncoding
                                                  error:nil];
        NSArray* hands = [f componentsSeparatedByString:@"\n\n\n"];
        NSLog(@"Hand count: %ld", hands.count);
        
        SRSMavenHandFileParser *parser = [[SRSMavenHandFileParser alloc] init];
        [parser parseHands:hands];
        
    } else {
        NSLog(@"File (%@) wasn't actually modified?", filename);
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
    Site* site = cbi.site;
    SRSParseEngine* parseEngine = cbi.parseEngine;
    
    // printf("Callback called\n");
    for (i=0; i<numEvents; i++) {
        NSString* filePath = [NSString stringWithCString:paths[i] encoding:NSUTF8StringEncoding];
        
        @synchronized(site) {
            [parseEngine parseLogFile:filePath forSite:site];
            [parseEngine.aMOC save:nil];
            
        }
    }
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

- (void)checkForUpdatesSinceLastLaunch:(Site *)site {
    
    NSString* path = site.handHistoryLocation;
    NSURL* pathUrl = [NSURL fileURLWithPath:path];
    NSArray *dirContents = [[NSFileManager defaultManager]  contentsOfDirectoryAtURL:pathUrl includingPropertiesForKeys:nil options:0 error:nil];
    
    @synchronized(site) {
        for (NSURL* fileName in dirContents) {
            [self parseLogFile:[fileName path] forSite:site];
        }
        
        [self.aMOC save:nil];
    }
}

- (void)checkForNewHandHistories:(id)sender {
    NSArray* sites = [self fetchSites];
    
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    if ([def boolForKey:@"autoImport"] == YES) {
        // TODO: perform imports
        
        for (Site* s in sites) {
            [self checkForUpdatesSinceLastLaunch:s];
            
            [self createDirectoryMonitor:s];
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
