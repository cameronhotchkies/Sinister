//
//  SRSDealerButtonView.m
//  Sinister
//
//  Created by Cameron Hotchkies on 3/3/14.
//  Copyright (c) 2014 Cameron Hotchkies. All rights reserved.
//

#import "SRSDealerButtonView.h"

@implementation SRSDealerButtonView

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
	//[super drawRect:dirtyRect];
	
    // Drawing code here.
    [[NSGraphicsContext currentContext] saveGraphicsState];

    NSRect border = NSInsetRect(self.frame, 1, 1);
    
	[[NSColor blackColor] set];
	NSBezierPath *ellipseCenter = [NSBezierPath bezierPathWithOvalInRect:border];
	[ellipseCenter fill];
    
    [[NSColor whiteColor] set];
    NSRect bg = NSInsetRect(border, 2, 2);
    NSBezierPath *bgCenter = [NSBezierPath bezierPathWithOvalInRect:bg];
	[bgCenter fill];
    
    id fonts = [[NSFontManager sharedFontManager] availableFontFamilies];
    
    [[NSColor blackColor] set];
	NSFont *timesUnicode = [[NSFontManager sharedFontManager] fontWithFamily:@"Baskerville"
                                                                      traits:NSBoldFontMask
                                                                      weight:5
                                                                        size:14/*345*/];
    
//    NSString *dealerChar = @"D";
//	NSRange stringRange = NSMakeRange(0, [dealerChar length]);
//	NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
//	NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:dealerChar];
//	[textStorage addAttribute:NSFontAttributeName value:timesUnicode range:stringRange];
//	[textStorage fixAttributesInRange:stringRange];
//	[textStorage addLayoutManager:layoutManager];
//	NSInteger numGlyphs = [layoutManager numberOfGlyphs];
//	NSGlyph *glyphs = (NSGlyph *)malloc(sizeof(NSGlyph) * (numGlyphs + 1)); // includes space for NULL terminator
//	[layoutManager getGlyphs:glyphs range:NSMakeRange(0, numGlyphs)];
//	[textStorage removeLayoutManager:layoutManager];
    
    //	// Get the glyph using CTFont instead
	NSInteger numGlyphs = 1;
	NSGlyph *glyphs = (NSGlyph *)malloc(sizeof(NSGlyph) * (numGlyphs + 1)); // includes space for NULL terminator
	CTFontGetGlyphsForCharacters((CTFontRef)timesUnicode, (const UniChar *)L"D", (CGGlyph *)glyphs, numGlyphs);
	
	NSBezierPath *dealerCharPath = [[NSBezierPath alloc] init];
	[dealerCharPath moveToPoint:NSMakePoint(5,5.25)];//(130, 140)];
	[dealerCharPath appendBezierPathWithGlyphs:glyphs count:numGlyphs inFont:timesUnicode];
	free(glyphs);

    //[NSShadow setShadowWithOffset:NSZeroSize blurRadius:12 * scale color:[NSColor colorWithCalibratedWhite:0 alpha:1.0]];
	//[[NSColor colorWithCalibratedWhite:0.9 alpha:1.0] set];
	[dealerCharPath fill];
//	[ellipseCenter setClip];
    
	[[NSGraphicsContext currentContext] restoreGraphicsState];

//    NSSize nativeSize = self.frame.size;
//	NSSize boundsSize = [[NSGraphicsContext currentContext] isDrawingToScreen] ? self.bounds.size : self.frame.size;
//	CGFloat nativeAspect = nativeSize.width / nativeSize.height;
//	CGFloat boundsAspect = boundsSize.width / boundsSize.height;
//	CGFloat scale = nativeAspect > boundsAspect ?
//    boundsSize.width / nativeSize.width :
//    boundsSize.height / nativeSize.height;
//	
//	[[NSGraphicsContext currentContext] saveGraphicsState];
//    
//	NSAffineTransform *transform = [[NSAffineTransform alloc] init];
//	[transform translateXBy:0.5 * (boundsSize.width - scale * nativeSize.width) yBy:0.5 * (boundsSize.height - scale * nativeSize.height)];
//	[transform scaleBy:scale];
//	[transform set];
//	
//	NSRect ellipseRect = NSMakeRect(32, 38, 448, 448);
//	
////	[NSShadow setShadowWithOffset:NSMakeSize(0, -8 * scale) blurRadius:12 * scale color:[NSColor colorWithCalibratedWhite:0 alpha:0.75]];
//	[[NSColor colorWithCalibratedWhite:0.9 alpha:1.0] set];
//	[[NSBezierPath bezierPathWithOvalInRect:ellipseRect] fill];
////	[NSShadow clearShadow];
//    
//	NSBezierPath *ellipse = [NSBezierPath bezierPathWithOvalInRect:ellipseRect];
//	NSGradient *borderGradient =
//    [[NSGradient alloc]
//      initWithStartingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]
//      endingColor:[NSColor colorWithCalibratedWhite:0.82 alpha:1.0]];
//	[borderGradient drawInBezierPath:ellipse angle:-90];
//	
//	NSRect ellipseCenterRect = NSInsetRect(ellipseRect, 16, 16);
//	[[NSColor blackColor] set];
//	NSBezierPath *ellipseCenter = [NSBezierPath bezierPathWithOvalInRect:ellipseCenterRect];
//	[ellipseCenter fill];
//	
//	[ellipseCenter setClip];
//    
//	NSGradient *bottomGlowGradient =
//    [[NSGradient alloc]
//      initWithColorsAndLocations:
//      [NSColor colorWithCalibratedRed:0 green:0.94 blue:0.82 alpha:1.0], 0.0,
//      [NSColor colorWithCalibratedRed:0 green:0.62 blue:0.56 alpha:1.0], 0.35,
//      [NSColor colorWithCalibratedRed:0 green:0.05 blue:0.35 alpha:1.0], 0.6,
//      [NSColor colorWithCalibratedRed:0 green:0.0 blue:0.0 alpha:1.0], 0.7,
//      nil];
//	[bottomGlowGradient drawInRect:ellipseCenterRect relativeCenterPosition:NSMakePoint(0, -0.2)];
//    
//	NSGradient *topGlowGradient =
//    [[NSGradient alloc]
//      initWithColorsAndLocations:
//      [NSColor colorWithCalibratedRed:0 green:0.68 blue:1.0 alpha:0.75], 0.0,
//      [NSColor colorWithCalibratedRed:0 green:0.45 blue:0.62 alpha:0.55], 0.25,
//      [NSColor colorWithCalibratedRed:0 green:0.45 blue:0.62 alpha:0.0], 0.40,
//      nil];
//	[topGlowGradient drawInRect:ellipseCenterRect relativeCenterPosition:NSMakePoint(0, 0.4)];
//    
//	NSGradient *centerGlowGradient =
//    [[NSGradient alloc]
//      initWithColorsAndLocations:
//      [NSColor colorWithCalibratedRed:0 green:0.9 blue:0.9 alpha:0.9], 0.0,
//      [NSColor colorWithCalibratedRed:0 green:0.49 blue:1.0 alpha:0.0], 0.85,
//      nil];
//	[centerGlowGradient drawInRect:ellipseCenterRect relativeCenterPosition:NSMakePoint(0, 0)];
//    
//	NSFont *arialUnicode =
//    [[NSFontManager sharedFontManager]
//     fontWithFamily:@"Arial Unicode MS"
//     traits:0
//     weight:5
//     size:345];
//    
//	// Getting the glyph using AppKit's NSLayoutManager
//	NSString *floralHeart = @"\u2766";
//	NSRange stringRange = NSMakeRange(0, [floralHeart length]);
//	NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
//	NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:floralHeart];
//	[textStorage addAttribute:NSFontAttributeName value:arialUnicode range:stringRange];
//	[textStorage fixAttributesInRange:stringRange];
//	[textStorage addLayoutManager:layoutManager];
//	NSInteger numGlyphs = [layoutManager numberOfGlyphs];
//	NSGlyph *glyphs = (NSGlyph *)malloc(sizeof(NSGlyph) * (numGlyphs + 1)); // includes space for NULL terminator
//	[layoutManager getGlyphs:glyphs range:NSMakeRange(0, numGlyphs)];
//	[textStorage removeLayoutManager:layoutManager];
//    
//    //	// Get the glyph using CTFont instead
//    //	NSInteger numGlyphs = 1;
//    //	NSGlyph *glyphs = (NSGlyph *)malloc(sizeof(NSGlyph) * (numGlyphs + 1)); // includes space for NULL terminator
//    //	CTFontGetGlyphsForCharacters((CTFontRef)arialUnicode, (const UniChar *)L"\u2766", (CGGlyph *)glyphs, numGlyphs);
//	
//	NSBezierPath *floralHeartPath = [[NSBezierPath alloc] init];
//	[floralHeartPath moveToPoint:NSMakePoint(130, 140)];
//	[floralHeartPath appendBezierPathWithGlyphs:glyphs count:numGlyphs inFont:arialUnicode];
//	free(glyphs);
//    
////	[NSShadow setShadowWithOffset:NSZeroSize blurRadius:12 * scale color:[NSColor colorWithCalibratedWhite:0 alpha:1.0]];
//	[[NSColor colorWithCalibratedWhite:0.9 alpha:1.0] set];
//	[floralHeartPath fill];
//	[borderGradient drawInBezierPath:floralHeartPath angle:-90];
////	[NSShadow clearShadow];
//    
//	const CGFloat glossInset = 8;
//	CGFloat glossRadius = (ellipseCenterRect.size.width * 0.5) - glossInset;
//	NSPoint center = NSMakePoint(NSMidX(ellipseRect), NSMidY(ellipseRect));
//    
//	double arcFraction = 0.02;
//	NSPoint arcStartPoint = NSMakePoint(
//                                        center.x - glossRadius * cos(arcFraction * M_PI),
//                                        center.y + glossRadius * sin(arcFraction * M_PI));
//	NSPoint arcEndPoint = NSMakePoint(
//                                      center.x + glossRadius * cos(arcFraction * M_PI),
//                                      center.y + glossRadius * sin(arcFraction * M_PI));
//    
//	NSBezierPath *glossPath = [[NSBezierPath alloc] init];
//	[glossPath moveToPoint:arcStartPoint];
//	[glossPath
//     appendBezierPathWithArcWithCenter:center
//     radius:glossRadius
//     startAngle:arcFraction * 180
//     endAngle:(1.0 - arcFraction) * 180];
//    
//	const CGFloat bottomArcBulgeDistance = 70;
//	const CGFloat bottomArcRadius = 2.6;
//	[glossPath moveToPoint:arcEndPoint];
//	[glossPath
//     appendBezierPathWithArcFromPoint:
//     NSMakePoint(center.x, center.y - bottomArcBulgeDistance)
//     toPoint:arcStartPoint
//     radius:glossRadius * bottomArcRadius];
//	[glossPath lineToPoint:arcStartPoint];
//    
//	NSGradient *glossGradient =
//    [[NSGradient alloc]
//      initWithColorsAndLocations:
//      [NSColor colorWithCalibratedWhite:1 alpha:0.85], 0.0,
//      [NSColor colorWithCalibratedWhite:1 alpha:0.5], 0.5,
//      [NSColor colorWithCalibratedWhite:1 alpha:0.05], 1.0,
//      nil];
//	[glossGradient drawInBezierPath:glossPath angle:-90];
//    
//	[[NSGraphicsContext currentContext] restoreGraphicsState];


}

@end
