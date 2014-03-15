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
#import <QuartzCore/CAShapeLayer.h>

@implementation SRSFeltTableView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        
        [self setWantsLayer:YES];
        self.feltBackLayer = [CAShapeLayer layer];//[CALayer layer];
        self.feltBackLayer.frame = frame;
        self.feltBackLayer.delegate = self;
      
        [self.feltBackLayer setNeedsDisplay];
        
        self.layerUsesCoreImageFilters = YES;
        
        CIFilter *gloom = [CIFilter filterWithName:@"CIGloom"];
        [gloom setDefaults];
        [gloom setValue: @25.0f forKey: kCIInputRadiusKey];
        [gloom setValue: @0.75f forKey: kCIInputIntensityKey];
        [self.feltBackLayer setFilters:@[gloom]];
        
        [self setLayer:self.feltBackLayer];
    }
    return self;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    if (layer == self.feltBackLayer) {
        CGRect feltFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        
        NSGraphicsContext *nsGraphicsContext;
        nsGraphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:ctx
                                                                       flipped:NO];
        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext:nsGraphicsContext];
        
        
        NSRect border = NSInsetRect(feltFrame, 1, 1);
        
        [[NSColor colorWithCalibratedRed:0.2 green:0.5 blue:0.35 alpha:1] set];
        NSBezierPath *ellipseCenter = [NSBezierPath bezierPathWithOvalInRect:border];
        [ellipseCenter fill];
        
        
        [NSGraphicsContext restoreGraphicsState];
    } else {
        [super drawLayer:layer inContext:ctx];
    }
}

//- (void)drawRect:(NSRect)dirtyRect
//{
//	[super drawRect:dirtyRect];
//	
//   
//    
//}

@end
