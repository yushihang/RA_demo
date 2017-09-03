//
//  ViewController.m
//  ARDemo
//
//  Created by apple on 02/09/2017.
//  Copyright © 2017 fish. All rights reserved.
//

#import "ViewController.h"
#import "Scene.h"
#import "UIAlertView+Blocks.h"

@interface ViewController () <ARSKViewDelegate>
{
    Scene* scene_;
}
@property (nonatomic, strong) IBOutlet ARSKView *sceneView;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the view's delegate
    self.sceneView.delegate = self;
    
    // Show statistics such as fps and node count
    self.sceneView.showsFPS = YES;
    self.sceneView.showsNodeCount = YES;
    
    // Load the SKScene from 'Scene.sks'
    scene_ = [(Scene *)[Scene sceneWithSize:self.sceneView.bounds.size] retain];
    // Present the scene
    [self.sceneView presentScene:scene_];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetTrackWithClear) name:RESET_ARKIT_TRACK_FROM_SCENE object:nil];
}
- (void) resetTrackWithClear
{
    [self resetTrackWithOption:ARSessionRunOptionResetTracking|ARSessionRunOptionRemoveExistingAnchors];
    [scene_ resetCount];
}
- (void) resetTrack
{
    [self resetTrackWithOption:0];
}
- (void) resetTrackWithOption:(ARSessionRunOptions)options
{
    if (ARWorldTrackingConfiguration.isSupported) {
        ARWorldTrackingConfiguration*  configuration = [[[ARWorldTrackingConfiguration alloc] init] autorelease];
        //configuration.planeDetection = .horizontal
        [self.sceneView.session runWithConfiguration:configuration options:options];
    }
    else{
        AROrientationTrackingConfiguration* configuration = [[[AROrientationTrackingConfiguration alloc] init] autorelease];
        [self.sceneView.session runWithConfiguration:configuration options:options];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    /*
     // Create a session configuration
     ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
     
     // Run the view's session
     [self.sceneView.session runWithConfiguration:configuration];
     */
    
    [self resetTrack];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Pause the view's session
    [self.sceneView.session pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - ARSKViewDelegate

- (SKNode *)view:(ARSKView *)view nodeForAnchor:(ARAnchor *)anchor {
    // Create and configure a node for the anchor added to the view's session.
    return [scene_ view:view nodeForAnchor:anchor];
}

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    // Present an error message to the user
    
    [UIAlertView showWithTitle:@"ARKit错误提示" message:error.localizedDescription  cancelButtonTitle:nil otherButtonTitles:@[@"重试"] tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
        [self resetTrackWithClear];
    }];
}

- (void)sessionWasInterrupted:(ARSession *)session {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    [self resetTrack];
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    [self resetTrack];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [scene_ release];
    [super dealloc];
}

- (void)view:(ARSKView *)view didRemoveNode:(SKNode *)node forAnchor:(ARAnchor *)anchor;
{
    
}

@end
