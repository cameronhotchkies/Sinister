//
//  NSDecimalNumber+Abs.m
//  Sinister
//
//  Created by Cameron Hotchkies on 3/1/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import "NSDecimalNumber+Abs.h"

@implementation NSDecimalNumber (Abs)

- (NSDecimalNumber*)absoluteValue {
    if ([self compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
        return [self negate];
    } else {
        return self;
    }
}

- (NSDecimalNumber*)negate {
    NSDecimalNumber * negativeOne = [NSDecimalNumber decimalNumberWithMantissa:1
                                                                      exponent:0
                                                                    isNegative:YES];
    return [self decimalNumberByMultiplyingBy:negativeOne];
}

- (NSDecimalNumber*)absoluteMinimum:(NSDecimalNumber*)that {
    NSDecimalNumber *selfAbs = [self absoluteValue];
    NSDecimalNumber *thatAbs = [that absoluteValue];
    
    if ([selfAbs compare:thatAbs] == NSOrderedDescending) {
        return that;
    } else {
        return self;
    }
}

@end
