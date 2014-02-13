//
//  ParsedFile.h
//  Sinister
//
//  Created by Cameron Hotchkies on 2/10/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Site;

@interface ParsedFile : NSManagedObject

@property (nonatomic, retain) NSString * filename;
@property (nonatomic) NSTimeInterval parseTime;
@property (nonatomic) NSTimeInterval lastModification;
@property (nonatomic, retain) Site *site;

@end
