//
//  SRSSeatBackgroundView.m
//  Sinister
//
//  Created by Cameron Hotchkies on 3/3/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

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
