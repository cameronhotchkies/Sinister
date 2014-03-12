//
//  ParsedFile.h
//  Sinister
//
//  Created by Cameron Hotchkies on 3/12/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Site;

@interface ParsedFile : NSManagedObject

@property (nonatomic, retain) NSString * filename;
@property (nonatomic) NSTimeInterval lastModification;
@property (nonatomic) NSTimeInterval parseTime;
@property (nonatomic, retain) Site *site;

@end
