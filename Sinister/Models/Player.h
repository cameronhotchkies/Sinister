//
//  Player.h
//  Sinister
//
//  Created by Cameron Hotchkies on 1/22/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Action, Hand;

@interface Player : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *playedHands;
@property (nonatomic, retain) NSSet *actions;
@end

@interface Player (CoreDataGeneratedAccessors)

- (void)addPlayedHandsObject:(Hand *)value;
- (void)removePlayedHandsObject:(Hand *)value;
- (void)addPlayedHands:(NSSet *)values;
- (void)removePlayedHands:(NSSet *)values;

- (void)addActionsObject:(Action *)value;
- (void)removeActionsObject:(Action *)value;
- (void)addActions:(NSSet *)values;
- (void)removeActions:(NSSet *)values;

@end
