//
//  SRSMavenHandFileParser.h
//  Sinister
//
//  Created by Cameron Hotchkies on 1/18/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Hand.h"

@interface SRSMavenHandFileParser : NSObject

- (Hand*) parseHandData:(NSString*)handData;

@end
