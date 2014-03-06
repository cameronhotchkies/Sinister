//
//  SRSFeltTableView.m
//  Sinister
//
//  Created by Cameron Hotchkies on 3/5/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import "SRSFeltTableView.h"

#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/CoreImage.h>

@implementation SRSFeltTableView

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
	
    CGRect feltFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    [[NSGraphicsContext currentContext] saveGraphicsState];
    NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
    
    NSRect border = NSInsetRect(feltFrame, 1, 1);
    
	[[NSColor colorWithCalibratedRed:0.2 green:0.5 blue:0.35 alpha:1] set];
	NSBezierPath *ellipseCenter = [NSBezierPath bezierPathWithOvalInRect:border];
	[ellipseCenter fill];
    
    CIFilter *noiseFilter = [CIFilter filterWithName:@"CIRandomGenerator"];
    CIImage *noise = [noiseFilter ]
    
    
//    [[NSColor redColor] set];
//    NSRect bg = NSInsetRect(border, 2, 2);
//    NSBezierPath *bgCenter = [NSBezierPath bezierPathWithOvalInRect:bg];
//	[bgCenter fill];
    
    [[NSGraphicsContext currentContext] saveGraphicsState];
    
}

@end
