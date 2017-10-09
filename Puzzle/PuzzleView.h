// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

@import ScreenSaver;
@import SpriteKit;

@class PuzzleScene;

@interface PuzzleView : ScreenSaverView {
    SKView *_sceneView;
    PuzzleScene *_scene;
}

@property SKView *sceneView;
@property PuzzleScene *scene;

@end
