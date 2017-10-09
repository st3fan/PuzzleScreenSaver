// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

@import SpriteKit;
@import CoreGraphics;

#define TILE_WIDTH (80)
#define TILE_HEIGHT (80)
#define TILE_SPEED 0.25

#pragma mark -

@interface TileIndex : NSObject
@property NSUInteger row;
@property NSUInteger column;
- (instancetype) initWithRow: (NSUInteger) row column: (NSUInteger) column;
@end

#pragma mark -

@interface PuzzleScene : SKScene {
    NSImage *_image;
    NSUInteger _rows;
    NSUInteger _columns;
    NSMutableArray *_tiles;
    TileIndex *_openTileIndex;
    TileIndex *_lastTileIndexMoved;

    NSTimer *_timer;
}
- (instancetype) initWithSize:(CGSize)size image: (NSImage*) image;
@end
