//
//  SRSHandExpectedValue.m
//  Sinister
//
//  Created by Cameron Hotchkies on 1/31/14.
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


#import "SRSHandExpectedValue.h"

@implementation SRSHandExpectedValue

@synthesize hand;

- (void)addPayout:(NSDecimalNumber*)payout {
    if (self.payouts == nil) {
        self.payouts = [NSArray arrayWithObject:payout];
    } else {
        self.payouts = [self.payouts arrayByAddingObject:payout];
    }
}

- (double)averageExpectedValue {
    
    int denom = 0;
    double numer = 0;
    
    for (NSDecimalNumber* d in self.payouts) {
        denom += 1;
        numer += [d doubleValue];
    }
    
    if (denom == 0) return 0.0;
    
    double returnValue = numer / denom;
    
    // Otherwise we end up with -0.00 which doesn't make sense
    if (returnValue < 0.005 && returnValue > -0.005) returnValue = 0;
    
    return returnValue;
}

- (double)highestPayout {
    NSDecimalNumber* runner = [NSDecimalNumber minimumDecimalNumber];
    for (NSDecimalNumber* d in self.payouts) {
        if ([d compare:runner] == NSOrderedDescending) {
            runner = d;
        }
    }
    
    if ([runner compare:[NSDecimalNumber minimumDecimalNumber]] == NSOrderedSame) {
        return 0;
    } else {
        return [runner doubleValue];
    }
}
- (double)lowestPayout {
    NSDecimalNumber* runner = [NSDecimalNumber maximumDecimalNumber];
    for (NSDecimalNumber* d in self.payouts) {
        if ([d compare:runner] == NSOrderedAscending) {
            runner = d;
        }
    }
    
    if ([runner compare:[NSDecimalNumber maximumDecimalNumber]] == NSOrderedSame) {
        return 0;
    } else {
        return [runner doubleValue];
    }

}

- (double)seen {
    double result = (((double)self.payouts.count) / ((double)self.handCount)) * 100.0;
    return result;
}


- (double)expectedFrequency {
    if ([self.hand hasSuffix:@"o"]) {
        // eg. AhKc, AhKs, AhKd
        //     AcKh, AcKs, AcKd
        //     AsKh, AsKc, AsKd
        //     AdKc, AdKh, AdKc
        // hand freq / all hands * 2 for order * 100 for readability
        return (12.0 / 2652.0) * 200.0;
    } else if ([self.hand hasSuffix:@"s"]) {
        // eg. AhKh, AcKc, AsKs, AdKd
        return (4.0 / 2652.0) * 200.0;
    } else {
        // PP: AhAd, AhAc, AhAs
        //     AdAc, AdAs,
        //     AcAs
        return (6.0 / 2652.0) * 200.0;
    }
}

@end
