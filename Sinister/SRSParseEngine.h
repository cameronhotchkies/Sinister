//
//  SRSParseEngine.h
//  Sinister
//
//  Created by Cameron Hotchkies on 2/7/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SRSLogImportProgressWindowController.h"

@interface SRSParseEngine : NSObject

+ (BOOL)isParseEngineReady:(NSManagedObjectContext*)aMOC;

@property (weak) NSManagedObjectContext* aMOC;
@property (strong) SRSLogImportProgressWindowController* progressWindow;

- (id)initWithManagedObjectContext:(NSManagedObjectContext*) managedObjectContext;

@end
