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

- (void)addPayout:(NSDecimalNumber*)payout;

- (double)averageExpectedValue;
- (double)highestPayout;
- (double)lowestPayout;


@end
