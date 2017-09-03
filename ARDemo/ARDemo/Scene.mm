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
#define GUESS_Z_POS (100)

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
    
    SKLabelNode* foundNoticeLabel_;
    SKLabelNode* foundNumberLabel_;
    
    int nodeNumber_;
    //int currentRemainAnchorCount_;
    int successedAnchorCount_;
    SKSpriteNode* resetButton_;
    NSMutableDictionary<NSNumber*, ARAnchor* >* nodeTypeAnchorDict_;
    NSMutableArray<NSNumber*>* nodeTypeArray_;
    
    std::unordered_map<int, std::pair<std::string, int>> gifDataMap_;
    
    SKSpriteNode* distanceNotifyNode_;
    
    BOOL guessMode_;
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
        
        
        foundNoticeLabel_ = [[SKLabelNode labelNodeWithText:@"已找到:"] retain];
        foundNoticeLabel_.fontSize = noticelabel_.fontSize;
        foundNoticeLabel_.fontName =  noticelabel_.fontName;
        foundNoticeLabel_.fontColor = noticelabel_.fontColor;

        
        
        foundNumberLabel_ = [[SKLabelNode labelNodeWithText:@"0"] retain];
        foundNumberLabel_.fontSize = noticelabel_.fontSize;
        foundNumberLabel_.fontName =  noticelabel_.fontName;
        foundNumberLabel_.fontColor = noticelabel_.fontColor;
  
        
        resetButton_ = [[SKSpriteNode alloc] initWithImageNamed:@"reset.png"];
        resetButton_.size = CGSizeMake(40, 40);
        resetButton_.userInteractionEnabled = false;
        resetButton_.position = CGPointMake([UIScreen mainScreen].bounds.size.width -  resetButton_.size.width*0.6, [UIScreen mainScreen].bounds.size.height -  resetButton_.size.height*0.6);
        resetButton_.name = RESET_BUTTON_NAME;
        
        [self setNodeNumer:0];
        //currentRemainAnchorCount_ = 0;
        [self setSuccessNodeNumer:0];
        
        nodeTypeAnchorDict_ = [[NSMutableDictionary alloc]initWithCapacity:MAX_NODE_COUNT];
        
        nodeTypeArray_ = [[NSMutableArray alloc]initWithCapacity:MAX_NODE_COUNT];
        
        [self resetNodeTypeArray];
        [self initGifDataMap];
        
        distanceNotifyNode_ = [[SKSpriteNode alloc]initWithImageNamed:@"distance_notify.png"];
        distanceNotifyNode_.xScale = distanceNotifyNode_.yScale = [UIScreen mainScreen].bounds.size.height * 0.1 / distanceNotifyNode_.size.height ;
        distanceNotifyNode_.position = CGPointMake([UIScreen mainScreen].bounds.size.width*0.5, [UIScreen mainScreen].bounds.size.height - distanceNotifyNode_.frame.size.height*0.75);
        
        guessMode_ = NO;
        
    }
    return self;
    
}

-(void)initGifDataMap
{
    gifDataMap_[0] = std::pair<std::string, int>("dz", 12);
    gifDataMap_[1] = std::pair<std::string, int>("js", 6);
    gifDataMap_[2] = std::pair<std::string, int>("bql", 6);
    gifDataMap_[3] = std::pair<std::string, int>("ad", 13);
    gifDataMap_[4] = std::pair<std::string, int>("tr", 18);
    gifDataMap_[5] = std::pair<std::string, int>("ydn", 16);
}
-(void)resetNodeTypeArray
{
    [nodeTypeArray_  removeAllObjects];
    for (int i=0; i<6; i++)
        [nodeTypeArray_ addObject:@(i)];
    [nodeTypeArray_ myshuffle];
    
}

-(SKNode*) generateSKSpriteNode:(int)gifIndex_orig
{
    int gifIndex = gifIndex_orig;
    if (gifIndex == -1)
    {
        if (nodeTypeArray_.count > 0)
        {
            gifIndex = [nodeTypeArray_ lastObject].intValue;
            [nodeTypeArray_ removeLastObject];
            
        }
    }
    if (gifIndex >= 6 || gifIndex < 0)
        gifIndex = arc4random() % 6;
    auto& pair = gifDataMap_[gifIndex];
    
    
    NSMutableArray* frames = [NSMutableArray arrayWithCapacity:pair.second];
    for (int i=0 ; i<pair.second; i++)
    {
        NSString* texName = [NSString stringWithFormat:@"%s-%d (dragged).tiff", pair.first.c_str(), i+1];
        SKTexture* texture = [SKTexture textureWithImageNamed:texName];
        [frames addObject:texture];
    }
    
    SKSpriteNode* node = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"%s-1 (dragged).tiff", pair.first.c_str()]];
    
    SKAction* animation = [SKAction animateWithTextures:frames timePerFrame:0.08];
    // Change the frame per 0.2 sec
    [node runAction:[SKAction repeatActionForever:animation]];
    //node.xScale = node.yScale = 0.5;
    //SKNode* nodeP = [SKNode node];
    //[nodeP addChild:node];
    
    node.name = [NSString stringWithFormat:@"%@%d", MY_NODE_NAME, gifIndex];
    
    //if (gifIndex_orig == -1)
    {
        node.color = [SKColor blackColor];
        
        node.colorBlendFactor = 1.0f;
    }
    
    return node;
}

-(int)getGifIndexByNodeName:(NSString*)name
{
    NSAssert([name hasPrefix:MY_NODE_NAME], @"getGifIndexByNodeName data error");
    NSString* string = [name substringFromIndex:MY_NODE_NAME.length];
    int gifIndex = string.intValue;
    return gifIndex;
}
- (SKNode *)view:(ARSKView *)view nodeForAnchor:(ARAnchor *)anchor {
    // Create and configure a node for the anchor added to the view's session.
    SKNode* node = [self generateSKSpriteNode:-1];
    int gifIndex = [self getGifIndexByNodeName:node.name];
    nodeTypeAnchorDict_[@(gifIndex)] = anchor;
    return node;
}


- (void)didMoveToView:(SKView *)view {
    // Setup your scene here
    [self addChild:noticelabel_];
    [self addChild:numberLabel_];
    [self addChild:foundNoticeLabel_];
    [self addChild:foundNumberLabel_];
    [self addChild:resetButton_];
    [self addChild:distanceNotifyNode_];
    distanceNotifyNode_.alpha = 0;
    
    ARSKView* sceneView= (ARSKView*)self.view;
    if (![sceneView isKindOfClass:[ARSKView class]]){
        return;
    }
    
    sceneView.session.delegate = self;

}

- (void)setNodeNumer:(int)number{
    nodeNumber_ = number;
    [self updateLabels];
    
}


- (void)setSuccessNodeNumer:(int)number{
    successedAnchorCount_ = number;
    [self updateLabels];
}

-(void)updateLabels
{
    numberLabel_.text = [NSString stringWithFormat:@"%d", nodeNumber_];
    foundNumberLabel_.text = [NSString stringWithFormat:@"%d", successedAnchorCount_];

    numberLabel_.position = CGPointMake(noticelabel_.frame.size.width+noticelabel_.frame.origin.x + 10 + numberLabel_.frame.size.width*0.5, noticelabel_.position.y);
    

    foundNoticeLabel_.position = CGPointMake(numberLabel_.frame.size.width+numberLabel_.frame.origin.x + 10 + foundNoticeLabel_.frame.size.width*0.5, noticelabel_.position.y);
    
    foundNumberLabel_.position = CGPointMake(foundNoticeLabel_.frame.size.width+foundNoticeLabel_.frame.origin.x + 10 + foundNumberLabel_.frame.size.width*0.5, noticelabel_.position.y);
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
    translation.columns[3].z = -2.5 - randomFloat(0.0, 1.0);
    //translation.columns[3].z = -0.5;
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
    
    if (guessMode_)
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
        distanceNotifyNode_.alpha = 0;
        [distanceNotifyNode_ removeAllActions];
        float currentlength = MAX(hitNode.frame.size.width, hitNode.frame.size.height);
        float screensize = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        float rate = currentlength/ screensize;
        if (rate < 0.5)
        {
            [self showNotifyForDistance];
            return;
        }
        [self touchSuccess:hitNode];
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

-(void)touchSuccess:(SKNode*) hitNode
{
    guessMode_ = YES;
    int gifIndex = [self getGifIndexByNodeName:hitNode.name];
    
    SKNode* newNode = [self generateSKSpriteNode:gifIndex];
    newNode.position = hitNode.position;
    newNode.yScale = hitNode.yScale;
    newNode.xScale = hitNode.xScale;
    newNode.zPosition = GUESS_Z_POS;
    [self addChild:newNode];
    
    
    ARAnchor* anchor = nodeTypeAnchorDict_[@(gifIndex)];
    if (anchor != nil)
    {
        ARSKView* sceneView= (ARSKView*)self.view;
        if (![sceneView isKindOfClass:[ARSKView class]]){
            return;
        }
        
        [sceneView.session removeAnchor:anchor];
        [hitNode removeFromParent];
        [nodeTypeAnchorDict_ removeObjectForKey:@(gifIndex)];
        [self setNodeNumer:nodeNumber_-1];
        [self setSuccessNodeNumer:successedAnchorCount_+1];

    }
    
}

- (void)showNotifyForDistance
{
    [distanceNotifyNode_ removeAllActions];

    NSArray* array = [NSArray arrayWithObjects:[SKAction fadeAlphaTo:1 duration:0.1], [SKAction waitForDuration:1],[SKAction fadeAlphaTo:0 duration:1], nil];
    [distanceNotifyNode_ runAction:[SKAction sequence:array]];
}
- (void) resetTrack
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RESET_ARKIT_TRACK_FROM_SCENE object:nil];
}
- (void) resetCount
{
    [self setNodeNumer:0];

    [nodeTypeAnchorDict_ removeAllObjects];
    [self resetNodeTypeArray];

    //currentRemainTAnchorCount_ = 0;
}



- (void)dealloc
{
    [noticelabel_ release];
    [numberLabel_ release];
    [foundNoticeLabel_ release];
    [foundNumberLabel_ release];
    [nodeTypeAnchorDict_ release];
    [nodeTypeArray_ release];
    [distanceNotifyNode_ release];
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
