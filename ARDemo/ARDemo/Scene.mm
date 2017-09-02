//
//  Scene.m
//  ARDemo
//
//  Created by apple on 02/09/2017.
//  Copyright © 2017 fish. All rights reserved.
//

#import "Scene.h"
#import <simd/types.h>
#import <SceneKit/SceneKit.h>
#define MAX_KOF_COUNT (3)

@interface Scene()
{
    SKLabelNode* noticelabel_;
    SKLabelNode* numberLabel_;
    int nodeNumber_;
    int currentRemainAnchorCount_;
    int successedAnchorCount_;
}
@end


@implementation Scene

- (instancetype)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self != nil)
    {
        noticelabel_ = [[SKLabelNode labelNodeWithText:@"剩余格斗家个数:"] retain];
        noticelabel_.fontSize = 15;
        noticelabel_.fontName =  [UIFont boldSystemFontOfSize:20.f].fontName;
        noticelabel_.fontColor = UIColor.whiteColor;
        noticelabel_.position = CGPointMake(noticelabel_.frame.size.width*0.5, noticelabel_.fontSize * 0.55);
        
        numberLabel_ = [[SKLabelNode labelNodeWithText:@"0"] retain];
        numberLabel_.fontSize = noticelabel_.fontSize;
        numberLabel_.fontName = noticelabel_.fontName;
        numberLabel_.fontColor = noticelabel_.fontColor;
        numberLabel_.position = CGPointMake(noticelabel_.frame.size.width + 10 + numberLabel_.frame.size.width*0.5, noticelabel_.position.y);
        
        [self setNodeNumer:0];
        currentRemainAnchorCount_ = 0;
        successedAnchorCount_ = 0;
        
        
    }
    return self;
    
}
- (void)didMoveToView:(SKView *)view {
    // Setup your scene here
    [self addChild:noticelabel_];
    [self addChild:numberLabel_];
    
    ARSKView* sceneView= (ARSKView*)self.view;
    if (![sceneView isKindOfClass:[ARSKView class]]){
        return;
    }
    
    sceneView.session.delegate = self;

}

- (void)setNodeNumer:(int)number{
    nodeNumber_ = number;
    numberLabel_.text = [NSString stringWithFormat:@"%d", number];
    numberLabel_.position = CGPointMake(noticelabel_.frame.size.width + 10 + numberLabel_.frame.size.width*0.5, noticelabel_.position.y);
}

- (void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
    int shouldCreateCount = MAX_KOF_COUNT - currentRemainAnchorCount_ - successedAnchorCount_;
    for (int i=0; i<shouldCreateCount; i++){
        [self createNodeAnchor];
        [self setNodeNumer:nodeNumber_+1];
    }
}

float randomFloat(float min, float max) {
    return (((float)(arc4random())) / 0xFFFFFFFF) * (max - min) + min;
}

NS_INLINE simd_float4x4 SCNMatrix4TosimdMat4(const SCNMatrix4& m) {
    simd_float4x4 mat;
    mat.columns[0] = (simd_float4){(float)m.m11, (float)m.m12, (float)m.m13, (float)m.m14};
    mat.columns[1] = (simd_float4){(float)m.m21, (float)m.m22, (float)m.m23, (float)m.m24};
    mat.columns[2] = (simd_float4){(float)m.m31, (float)m.m32, (float)m.m33, (float)m.m34};
    mat.columns[3] = (simd_float4){(float)m.m41, (float)m.m42, (float)m.m43, (float)m.m44};
    return mat;
}

- (void)createNodeAnchor {
    
    ARSKView* sceneView= (ARSKView*)self.view;
    if (![sceneView isKindOfClass:[ARSKView class]]){
        return;
    }

    
    // Define 360º in radians
    float _360degrees = 2.0 * M_PI;
    // Create a rotation matrix in the X-axis
    simd_float4x4 rotateX = SCNMatrix4TosimdMat4(SCNMatrix4MakeRotation(_360degrees * randomFloat(0.0, 1.0), 1, 0, 0));
    
    // Create a rotation matrix in the Y-axis
    simd_float4x4 rotateY = SCNMatrix4TosimdMat4(SCNMatrix4MakeRotation(_360degrees * randomFloat(0.0, 1.0), 0, 1, 0));
    
    // Combine both rotation matrices
    simd_float4x4 rotation = simd_mul(rotateX, rotateY);
    
    // Create a translation matrix in the Z-axis with a value between 1 and 2 meters
    simd_float4x4 translation = matrix_identity_float4x4;
    translation.columns[3].z = -1 - randomFloat(0.0, 1.0);
    
    // Combine the rotation and translation matrices
    simd_float4x4 transform = simd_mul(rotation, translation);
    
    // Create an anchor
    ARAnchor* anchor = [[[ARAnchor alloc]initWithTransform:transform] autorelease];
    
    // Add the anchor
    [sceneView.session addAnchor:anchor];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![self.view isKindOfClass:[ARSKView class]]) {
        return;
    }
    return;
    ARSKView *sceneView = (ARSKView *)self.view;
    ARFrame *currentFrame = [sceneView.session currentFrame];
    
    // Create anchor using the camera's current position
    if (currentFrame) {
        
        // Create a transform with a translation of 0.2 meters in front of the camera
        matrix_float4x4 translation = matrix_identity_float4x4;
        translation.columns[3].z = -0.6;
        //translation.columns[3].x = -0.5;
        //translation.columns[3].y = -0.5;
        matrix_float4x4 transform = matrix_multiply(currentFrame.camera.transform, translation);
        
        // Add a new anchor to the session
        ARAnchor *anchor = [[ARAnchor alloc] initWithTransform:transform];
        [sceneView.session addAnchor:anchor];
    }
}

- (void)dealloc
{
    [noticelabel_ release];
    [numberLabel_ release];
    [super dealloc];
}


- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame;
{
    
}

/**
 This is called when new anchors are added to the session.
 
 @param session The session being run.
 @param anchors An array of added anchors.
 */
- (void)session:(ARSession *)session didAddAnchors:(NSArray<ARAnchor*>*)anchors;
{
    currentRemainAnchorCount_ += anchors.count;
}

/**
 This is called when anchors are updated.
 
 @param session The session being run.
 @param anchors An array of updated anchors.
 */
- (void)session:(ARSession *)session didUpdateAnchors:(NSArray<ARAnchor*>*)anchors;
{
}

/**
 This is called when anchors are removed from the session.
 
 @param session The session being run.
 @param anchors An array of removed anchors.
 */
- (void)session:(ARSession *)session didRemoveAnchors:(NSArray<ARAnchor*>*)anchors;
{
    currentRemainAnchorCount_ -= anchors.count;
}

@end
