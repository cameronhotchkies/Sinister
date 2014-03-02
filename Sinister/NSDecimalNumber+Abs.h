//
//  NSDecimalNumber+Abs.h
//  Sinister
//
//  Created by Cameron Hotchkies on 3/1/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDecimalNumber (Abs)

- (NSDecimalNumber*)absoluteValue;

// Takes the MIN(ABS(x),ABS(y)) but returns the non-abs version
- (NSDecimalNumber*)absoluteMinimum:(NSDecimalNumber*)that;

- (NSDecimalNumber*)negate;

@end
