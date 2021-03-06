//
//  ViewController.m
//  ARDemo
//
//  Created by apple on 02/09/2017.
//  Copyright © 2017 fish. All rights reserved.
//
#if !__has_feature(objc_arc)
#error "open arc please"
#endif
#import "ViewController.h"
#import "Scene.h"
#import "UIAlertView+Blocks.h"
#import <CoreMotion/CoreMotion.h>

@interface ViewController () <ARSKViewDelegate>
{
    Scene* scene_;
    CMMotionManager *motionManager_;
    NSOperationQueue *motionQueue_;
}
@property (nonatomic, strong) IBOutlet ARSKView *sceneView;

@end


@implementation ViewController
// Add this method
- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    else
    {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    // Set the view's delegate
    self.sceneView.delegate = self;
    
    // Show statistics such as fps and node count
    self.sceneView.showsFPS = YES;
    self.sceneView.showsNodeCount = YES;
    
    // Load the SKScene from 'Scene.sks'
    scene_ = (Scene *)[Scene sceneWithSize:self.sceneView.bounds.size];
    // Present the scene
    [self.sceneView presentScene:scene_];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetTrackWithClear) name:RESET_ARKIT_TRACK_FROM_SCENE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseTrack) name:PAUSE_ARKIT_TRACK_FROM_SCENE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeTrack) name:RESUME_ARKIT_TRACK_FROM_SCENE object:nil];
    
    motionManager_ = [[CMMotionManager alloc] init];
    motionManager_.accelerometerUpdateInterval = 0.1;       // 0.01 = 1s/100 = 100Hz
    motionQueue_ = [[NSOperationQueue alloc] init];
    [self resetTrack];
}
- (void) resetTrackWithClear
{
    [self resetTrackWithOption:ARSessionRunOptionResetTracking|ARSessionRunOptionRemoveExistingAnchors];
    [scene_ resetCount];
}

- (void) pauseTrack
{
    [self.sceneView.session pause];
}

- (void) resumeTrack
{
    [self resetTrackWithOption:0];
}

- (void) resetTrack
{ 
    [self pauseTrack];
    if ([motionManager_ isAccelerometerAvailable])
    {
        [motionManager_ startAccelerometerUpdatesToQueue:motionQueue_ withHandler:^(CMAccelerometerData *accelerometerData, NSError *error){
            /*
            NSLog(@"X = %0.4f, Y = %.04f, Z = %.04f",
                  accelerometerData.acceleration.x,
                  accelerometerData.acceleration.y,
                  accelerometerData.acceleration.z);
             */
            if (fabs(accelerometerData.acceleration.z) < 0.1)
            {
                [self resetTrackWithOption:0];
                [motionManager_ stopAccelerometerUpdates];
                [scene_ setDirectionNotifyNodeVisible:NO];
            }
            else
            {
                [scene_ setDirectionNotifyNodeVisible:YES];
            }
            //[motionManager_ stopAccelerometerUpdates];
        }];
    }
    else
        [self resetTrackWithOption:0];
}
- (void) resetTrackWithOption:(ARSessionRunOptions)options
{

    
    if (ARWorldTrackingConfiguration.isSupported) {
        ARWorldTrackingConfiguration*  configuration = [[ARWorldTrackingConfiguration alloc] init];
        //configuration.planeDetection = .horizontal
        [self.sceneView.session runWithConfiguration:configuration options:options];
    }
    else{
        AROrientationTrackingConfiguration* configuration = [[AROrientationTrackingConfiguration alloc] init];
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

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Pause the view's session
    [self pauseTrack];
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
}

- (void)view:(ARSKView *)view didRemoveNode:(SKNode *)node forAnchor:(ARAnchor *)anchor;
{
    
}

@end
