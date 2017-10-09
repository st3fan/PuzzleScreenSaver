// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

#import "PuzzleScene.h"

@implementation TileIndex
@synthesize row;
@synthesize column;
- (instancetype) initWithRow: (NSUInteger) row column: (NSUInteger) column {
    if (self = [super init]) {
        self.row = row;
        self.column = column;
    }
    return self;
}
@end

#pragma mark -

@implementation PuzzleScene

- (instancetype) initWithSize:(CGSize)size image: (NSImage*) image {
    if (self = [super initWithSize: size]) {
        _image = image;
        _tiles = [NSMutableArray new];
    }
    return self;
}

- (CGPoint) positionForTileAtRow: (NSUInteger) row column: (NSUInteger) column {
    NSUInteger offset = (CGRectGetWidth(self.frame) / 2) - ((CGRectGetWidth(self.frame) / TILE_WIDTH) * TILE_WIDTH) / 2;
    return CGPointMake(offset + row * TILE_WIDTH + (TILE_WIDTH / 2), offset + column * TILE_HEIGHT + (TILE_HEIGHT / 2));
}

- (TileIndex*) randomTileIndex {
    return [[TileIndex alloc] initWithRow: arc4random_uniform((uint32_t) _rows) column: arc4random_uniform((uint32_t) _columns)];
}

- (NSUInteger) arrayIndexForTileIndex: (TileIndex*) tileIndex {
    return tileIndex.row * _columns + tileIndex.column;
}

- (NSArray*) findTileIndexesSurroundingTileIndex: (TileIndex*) tileIndex {
    NSMutableArray *indexes = [NSMutableArray new];
    if (tileIndex.column > 0) {
        [indexes addObject: [[TileIndex alloc] initWithRow:tileIndex.row column:tileIndex.column-1]];
    }
    if (tileIndex.column < (_columns - 1)) {
        [indexes addObject: [[TileIndex alloc] initWithRow:tileIndex.row column:tileIndex.column+1]];
    }

    if (tileIndex.row > 0) {
        [indexes addObject: [[TileIndex alloc] initWithRow:tileIndex.row - 1 column:tileIndex.column]];
    }
    if (tileIndex.row < (_rows - 1)) {
        [indexes addObject: [[TileIndex alloc] initWithRow:tileIndex.row + 1 column:tileIndex.column]];
    }
    return indexes;
}

-(void)sceneDidLoad {
    [super sceneDidLoad];
    self.backgroundColor = [NSColor darkGrayColor];
}

-(void)didMoveToView:(SKView *)view {
    [super didMoveToView: view];

    _rows = CGRectGetHeight(self.frame) / TILE_WIDTH;
    _columns = CGRectGetWidth(self.frame) / TILE_WIDTH;

    for (NSUInteger v = 0; v < _rows; v++) {
        for (NSUInteger h = 0; h < _columns; h++) {
            NSImage *tileImage = [[NSImage alloc] initWithSize: NSMakeSize(TILE_WIDTH * 2, TILE_HEIGHT * 2)];
            if (tileImage != nil) {
                [tileImage lockFocus];
                NSRect rect = NSMakeRect(h * TILE_WIDTH * 2, v * TILE_HEIGHT * 2, TILE_WIDTH * 2, TILE_HEIGHT * 2);
                [_image drawAtPoint: NSZeroPoint fromRect:rect operation:NSCompositingOperationCopy fraction: 1.0];
                [tileImage unlockFocus];

                SKTexture *texture = [SKTexture textureWithImage: tileImage];
                if (texture != nil) {
                    SKSpriteNode *node = [SKSpriteNode spriteNodeWithTexture: texture size: CGSizeMake(TILE_WIDTH - 1, TILE_HEIGHT - 1)];
                    if (node != nil) {
                        node.position = [self positionForTileAtRow: h column: v];
                        [self addChild: node];
                        [_tiles addObject: node];
                    }
                }
            }
        }
    }

    _openTileIndex = [self randomTileIndex];
    [[_tiles objectAtIndex: [self arrayIndexForTileIndex: _openTileIndex]] setHidden: YES];

    _timer = [NSTimer scheduledTimerWithTimeInterval:0.33 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSArray *tileIndexes = [self findTileIndexesSurroundingTileIndex: _openTileIndex];
        if (_lastTileIndexMoved != nil) {
            tileIndexes = [tileIndexes objectsAtIndexes: [tileIndexes indexesOfObjectsPassingTest:^BOOL(TileIndex* _Nonnull tileIndex, NSUInteger idx, BOOL * _Nonnull stop) {
                return (tileIndex.row != _lastTileIndexMoved.row && tileIndex.column != _lastTileIndexMoved.column);
            }]];
        }

        TileIndex *newOpenTileIndex = [tileIndexes objectAtIndex: random() % tileIndexes.count];
        _lastTileIndexMoved = _openTileIndex;

        SKNode *srcTile = [_tiles objectAtIndex: [self arrayIndexForTileIndex: newOpenTileIndex]];
        SKNode *dstTile = [_tiles objectAtIndex: [self arrayIndexForTileIndex: _openTileIndex]];

        [srcTile runAction: [SKAction moveTo: dstTile.position duration: TILE_SPEED]];
        [dstTile runAction: [SKAction moveTo: srcTile.position duration: TILE_SPEED]];

        [_tiles exchangeObjectAtIndex: [self arrayIndexForTileIndex: newOpenTileIndex] withObjectAtIndex: [self arrayIndexForTileIndex: _openTileIndex]];
        _openTileIndex = newOpenTileIndex;
    }];

    // For some reason this throws the animation off?
//    SKAction *moveOnePieceAction = [SKAction runBlock:^{
//    }];
//
//    [self runAction: [SKAction repeatActionForever: [SKAction sequence: @[moveOnePieceAction, [SKAction waitForDuration: 0.5]]]]];
}

@end
