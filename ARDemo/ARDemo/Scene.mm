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
#import <unordered_map>
#import <string>
#define MAX_NODE_COUNT (3)

#define RESET_BUTTON_NAME @"resetButton"
#define MY_NODE_NAME @"MY_NODE_NAME"


@interface NSMutableArray (my_Shuffling)
- (void)myshuffle;
@end




@implementation NSMutableArray (my_Shuffling)

- (void)myshuffle
{
    NSUInteger count = [self count];
    if (count <= 1) return;
    for (NSUInteger i = 0; i < count - 1; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [self exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}

@end

@interface Scene()
{
    SKLabelNode* noticelabel_;
    SKLabelNode* numberLabel_;
    int nodeNumber_;
    //int currentRemainAnchorCount_;
    int successedAnchorCount_;
    SKSpriteNode* resetButton_;
    NSMutableDictionary<NSString*, SKNode* >* anchorNodeDict_;
    NSMutableArray<NSNumber*>* nodeTypeArray_;
    
    std::unordered_map<int, std::pair<std::string, int>> gifDataMap_;
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
        
        resetButton_ = [[SKSpriteNode alloc] initWithImageNamed:@"reset.png"];
        resetButton_.size = CGSizeMake(40, 40);
        resetButton_.userInteractionEnabled = false;
        resetButton_.position = CGPointMake([UIScreen mainScreen].bounds.size.width -  resetButton_.size.width*0.6, [UIScreen mainScreen].bounds.size.height -  resetButton_.size.height*0.6);
        resetButton_.name = RESET_BUTTON_NAME;
        
        [self setNodeNumer:0];
        //currentRemainAnchorCount_ = 0;
        successedAnchorCount_ = 0;
        
        anchorNodeDict_ = [[NSMutableDictionary alloc]initWithCapacity:3];
        
        nodeTypeArray_ = [[NSMutableArray alloc]initWithCapacity:3];
        
        [self resetNodeTypeArray];
        
        
        
    }
    return self;
    
}

-(void)initGifDataMap
{
    gifDataMap_[0] = std::pair<std::string, int>("东丈", 12);
    gifDataMap_[1] = std::pair<std::string, int>("吉斯", 6);
    gifDataMap_[2] = std::pair<std::string, int>("坂崎良", 6);
    gifDataMap_[3] = std::pair<std::string, int>("安迪", 13);
    gifDataMap_[4] = std::pair<std::string, int>("特瑞", 18);
    gifDataMap_[5] = std::pair<std::string, int>("雅典娜", 16);
}
-(void)resetNodeTypeArray
{
    [nodeTypeArray_  removeAllObjects];
    for (int i=0; i<6; i++)
        [nodeTypeArray_ addObject:@(i)];
    [nodeTypeArray_ myshuffle];
    
}

-(SKSpriteNode*) generateSKSpriteNode
{
    int gifIndex = arc4random() % 6;
    if (nodeTypeArray_.count > 0)
    {
        gifIndex = [nodeTypeArray_ lastObject].intValue;
        [nodeTypeArray_ removeLastObject];
        if (gifIndex >= 6)
            gifIndex = arc4random() % 6;
    }
    
    auto& pair = gifDataMap_[gifIndex];
    
    
    NSMutableArray* frames = [NSMutableArray arrayWithCapacity:pair.second];
    for (int i=0 ; i<pair.second; i++)
    {
        NSString* texName = [NSString stringWithFormat:@"%s-%d (dragged).tiff", pair.first.c_str(), i+1];
        SKTexture* texture = [SKTexture textureWithImageNamed:texName];
        [frames addObject:texture];
    }
    
    SKSpriteNode* node = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"%s-1 (dragged).tiff", pair.first.c_str()]];
    
    SKAction* animation = [SKAction animateWithTextures:frames timePerFrame:0.2];
    // Change the frame per 0.2 sec
    [node runAction:[SKAction repeatActionForever:animation]];
    
    return node;
}

- (SKNode *)view:(ARSKView *)view nodeForAnchor:(ARAnchor *)anchor {
    // Create and configure a node for the anchor added to the view's session.
    SKSpriteNode* node = [self generateSKSpriteNode];
    anchorNodeDict_[anchor.identifier.UUIDString] = node;
    return node;
}


- (void)didMoveToView:(SKView *)view {
    // Setup your scene here
    [self addChild:noticelabel_];
    [self addChild:numberLabel_];
    [self addChild:resetButton_];
    
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
    
    static NSTimeInterval lastCreateTime = 0;
    NSTimeInterval now = [[NSDate  date]timeIntervalSince1970];
    if (now - lastCreateTime < 5)
        return;
    // Called before each frame is rendered
    int shouldCreateCount = MAX_NODE_COUNT - nodeNumber_ - successedAnchorCount_;
    for (int i=0; i<shouldCreateCount; i++){
        [self createNodeAnchor];
        [self setNodeNumer:nodeNumber_+1];
    }
    lastCreateTime = now;
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
    simd_float4x4 rotateX = SCNMatrix4TosimdMat4(SCNMatrix4MakeRotation(_360degrees * randomFloat(0.2, 0.6), 1, 0, 0));
    
    // Create a rotation matrix in the Y-axis
    simd_float4x4 rotateY = SCNMatrix4TosimdMat4(SCNMatrix4MakeRotation(_360degrees * randomFloat(0.0, 1.0), 0, 1, 0));
    
    // Combine both rotation matrices
    simd_float4x4 rotation = simd_mul(rotateX, rotateY);

    
    // Create a translation matrix in the Z-axis with a value between 1 and 2 meters
    simd_float4x4 translation = matrix_identity_float4x4;
    translation.columns[3].z = -1.0 - randomFloat(0.0, 1.0);
    // Combine the rotation and translation matrices
    simd_float4x4 transform = simd_mul(rotation, translation);
    
    // Create an anchor
    ARAnchor* anchor = [[[ARAnchor alloc]initWithTransform:transform] autorelease];
    
    // Add the anchor
    [sceneView.session addAnchor:anchor];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    if (touch == nil)
        return;
    
    CGPoint location = [touch locationInNode:self];
    
    NSArray* hitNodes = [self nodesAtPoint:location];
    if (hitNodes.count == 0)
        return;
    
    SKNode* hitNode = hitNodes.firstObject;
    if (hitNode == nil)
        return;
    
    if ([hitNode.name isEqualToString:RESET_BUTTON_NAME])
    {
        [self resetTrack];
        return;
    }
    
    if ([hitNode.name hasPrefix:MY_NODE_NAME])
    {
        float currentlength = MAX(hitNode.frame.size.width, hitNode.frame.size.height);
        float screensize = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        float rate = currentlength/ screensize;
        if (rate < 0.33)
        {
            [self showNotifyForDistance];
            return;
        }
        return;
    }
    /*
    if (![self.view isKindOfClass:[ARSKView class]]) {
        return;
    }

    
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
  */
}
- (void)showNotifyForDistance
{
    SKSpriteNode* node = [[[SKSpriteNode alloc]initWithImageNamed:@"distance_notify.png"] autorelease];
    node.xScale = node.yScale = [UIScreen mainScreen].bounds.size.height * 0.1 / node.size.height ;
    [self addChild:node];
    node.position = CGPointMake([UIScreen mainScreen].bounds.size.width*0.5, [UIScreen mainScreen].bounds.size.height - node.frame.size.height*0.75);
    NSArray* array = [NSArray arrayWithObjects:[SKAction waitForDuration:1],[SKAction fadeAlphaTo:0 duration:1], [SKAction removeFromParent], nil];
    [node runAction:[SKAction sequence:array]];
}
- (void) resetTrack
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RESET_ARKIT_TRACK_FROM_SCENE object:nil];
}
- (void) resetCount
{
    [self setNodeNumer:0];
    [anchorNodeDict_ enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        SKNode* node = (SKNode*)obj;
        if ([node isKindOfClass:[SKNode class]])
            [node removeFromParent];
    }];
    [anchorNodeDict_ removeAllObjects];
    [self resetNodeTypeArray];

    //currentRemainAnchorCount_ = 0;
}



- (void)dealloc
{
    [noticelabel_ release];
    [numberLabel_ release];
    [anchorNodeDict_ release];
    [nodeTypeArray_ release];
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
    //currentRemainAnchorCount_ += anchors.count;
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
    //currentRemainAnchorCount_ -= anchors.count;
    
}

@end
