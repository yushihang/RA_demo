//
//  Scene.h
//  ARDemo
//
//  Created by apple on 02/09/2017.
//  Copyright © 2017 fish. All rights reserved.
//
#if !__has_feature(objc_arc)
#error "open arc please"
#endif
#import <SpriteKit/SpriteKit.h>
#import <ARKit/ARKit.h>
#define RESET_ARKIT_TRACK_FROM_SCENE @"RESET_ARKIT_TRACK_FROM_SCENE__1"
#define PAUSE_ARKIT_TRACK_FROM_SCENE @"PAUSE_ARKIT_TRACK_FROM_SCENE__2"
#define RESUME_ARKIT_TRACK_FROM_SCENE @"RESUME_ARKIT_TRACK_FROM_SCENE__3"
@interface Scene : SKScene<ARSessionDelegate>
- (void) resetCount;
- (SKNode *)view:(ARSKView *)view nodeForAnchor:(ARAnchor *)anchor;
- (void)setDirectionNotifyNodeVisible:(BOOL)visible;


@end
