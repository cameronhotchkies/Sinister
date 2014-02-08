//
//  SRSParseEngine.m
//  Sinister
//
//  Created by Cameron Hotchkies on 2/7/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import "SRSParseEngine.h"

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

@end
