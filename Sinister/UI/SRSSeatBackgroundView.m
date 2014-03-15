//
//  SRSSeatBackgroundView.m
//  Sinister
//
//  Created by Cameron Hotchkies on 3/3/14.
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


#import "SRSSeatBackgroundView.h"

@implementation SRSSeatBackgroundView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
    [[NSGraphicsContext currentContext] saveGraphicsState];
    
    NSRect border = NSInsetRect(self.frame, 1, 1);
    
	[[NSColor blackColor] set];
	NSBezierPath *ellipseCenter = [NSBezierPath bezierPathWithOvalInRect:border];
	[ellipseCenter fill];
    
    [[NSColor redColor] set];
    NSRect bg = NSInsetRect(border, 2, 2);
    NSBezierPath *bgCenter = [NSBezierPath bezierPathWithOvalInRect:bg];
	[bgCenter fill];
    
    [[NSGraphicsContext currentContext] saveGraphicsState];

}

@end
