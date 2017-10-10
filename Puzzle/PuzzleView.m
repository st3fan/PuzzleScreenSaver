// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

#import "PuzzleScene.h"
#import "PuzzleView.h"

@interface MySKView: SKView {
}
@end

@implementation MySKView
-(BOOL)acceptsFirstResponder {
    return NO;
}
@end

#pragma mark -

@implementation PuzzleView

@synthesize sceneView;
@synthesize scene;

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    if (self = [super initWithFrame:frame isPreview:isPreview]) {
        self.sceneView = [[MySKView alloc] initWithFrame: self.frame];
        self.sceneView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        [self addSubview: self.sceneView];
    }
    return self;
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

- (void) startAnimation {
    NSInteger windowNumber = self.window.windowNumber;
    NSArray* windows = (NSArray*) CFBridgingRelease(CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID));
    if (windows != nil) {
        for (NSDictionary *window in windows) {
            if ([[window objectForKey: (NSString*) kCGWindowOwnerName] isEqualToString: @"loginwindow"]) {
                windowNumber = [[window objectForKey: (NSString*) kCGWindowNumber] integerValue];
                break;
            }
        }
    }

    CGImageRef imageRef = CGWindowListCreateImage(self.frame, kCGWindowListOptionOnScreenBelowWindow, (CGWindowID) windowNumber, kCGWindowImageBestResolution);
    if (imageRef != NULL) {
        // TODO That *2 should only be there for retina images?
        NSImage *image = [[NSImage alloc] initWithCGImage: imageRef size: CGSizeMake(CGRectGetWidth(self.frame)*2, CGRectGetHeight(self.frame)*2)];
        if (image != nil) {
            self.scene = [[PuzzleScene alloc] initWithSize: self.frame.size image: image];
            [self.sceneView presentScene: self.scene];
        }
        CGImageRelease(imageRef);
    }
}

@end
