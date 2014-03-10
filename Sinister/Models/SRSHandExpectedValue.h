//
//  SRSHandExpectedValue.h
//  Sinister
//
//  Created by Cameron Hotchkies on 1/31/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRSHandExpectedValue : NSObject

@property (nonatomic, strong) NSString* hand;
@property (nonatomic, strong) NSArray* payouts;
@property (assign) NSInteger handCount;

- (void)addPayout:(NSDecimalNumber*)payout;

- (double)averageExpectedValue;
- (double)highestPayout;
- (double)lowestPayout;
- (double)seen;
- (double)expectedFrequency;

@end
