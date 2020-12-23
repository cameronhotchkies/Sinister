//
//  SRSDealerButtonView.m
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
    
    [[NSColor blackColor] set];
	NSFont *timesUnicode = [[NSFontManager sharedFontManager] fontWithFamily:@"Baskerville"
                                                                      traits:NSBoldFontMask
                                                                      weight:5
                                                                        size:14/*345*/];
    
    
    // Get the glyph using CTFont
	NSInteger numGlyphs = 1;
	NSGlyph *glyphs = (NSGlyph *)malloc(sizeof(NSGlyph) * (numGlyphs + 1)); // includes space for NULL terminator
	CTFontGetGlyphsForCharacters((CTFontRef)timesUnicode, (const UniChar *)L"D", (CGGlyph *)glyphs, numGlyphs);
	
	NSBezierPath *dealerCharPath = [[NSBezierPath alloc] init];
	[dealerCharPath moveToPoint:NSMakePoint(5,5.25)];//(130, 140)];
	[dealerCharPath appendBezierPathWithGlyphs:glyphs count:numGlyphs inFont:timesUnicode];
	free(glyphs);

	[dealerCharPath fill];
    
	[[NSGraphicsContext currentContext] restoreGraphicsState];
}

@end
