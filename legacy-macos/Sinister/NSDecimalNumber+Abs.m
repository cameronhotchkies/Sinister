//
//  NSDecimalNumber+Abs.m
//  Sinister
//
//  Created by Cameron Hotchkies on 3/1/14.
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
