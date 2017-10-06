//
//  Scene.m
//  ARDemo
//
//  Created by apple on 02/09/2017.
//  Copyright © 2017 fish. All rights reserved.
//
#if !__has_feature(objc_arc)
#error "open arc please"
#endif
#import "Scene.h"
#import <simd/types.h>
#import <SceneKit/SceneKit.h>
#import "ARData.h"
#import "TouchableSpriteNode.h"
#import "UIAlertView+Blocks.h"
//#define MAX_NODE_COUNT (3)

#define RESET_BUTTON_NAME @"resetButton_1"
#define MY_NODE_NAME @"MY_NODE_NAME_2"
#define OPTION_NODE_NAME @"OPTION_NODE_NAME_3"
#define GUESS_Z_POS (100)
#define LABEL_Z_POS (100)
#define TOUCH_RATE (0.1) //0.4
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
    //SKLabelNode* noticelabel_;
    //SKLabelNode* numberLabel_;
    
    SKLabelNode* foundNoticeLabel_;
    SKLabelNode* foundNumberLabel_;
    
    int nodeNumber_;
    //int currentRemainAnchorCount_;
    int successedAnchorCount_;
    SKSpriteNode* resetButton_;
    NSMutableDictionary<NSNumber*, ARAnchor* >* nodeTypeAnchorDict_;
    //NSMutableArray<NSNumber*>* nodeTypeArray_;
    
    
    NSMutableDictionary* gifDataDictionary_;
    
    SKSpriteNode* distanceNotifyNode_;
    SKSpriteNode* directionNotifyNode_;
    
    SKSpriteNode* titleNode_;
    
    TouchableSpriteNode* closeNode_;
    TouchableSpriteNode* currentTouchableNode_;
    
    BOOL guessMode_;
    SKNode* guessContainerNode_;
    
    matrix_float4x4 cameraFrameTransform_;
}
@end


@implementation Scene

- (instancetype)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self != nil)
    {
        /*
        noticelabel_ = [SKLabelNode labelNodeWithText:@"剩余格斗家个数:"];
        noticelabel_.fontSize = 15;
        noticelabel_.fontName =  [UIFont boldSystemFontOfSize:20.f].fontName;
        noticelabel_.fontColor = UIColor.whiteColor;
        noticelabel_.position = CGPointMake(noticelabel_.frame.size.width*0.5, noticelabel_.fontSize * 0.55);
        noticelabel_.zPosition = LABEL_Z_POS;
        
        numberLabel_ = [SKLabelNode labelNodeWithText:@"0"];
        numberLabel_.fontSize = noticelabel_.fontSize;
        numberLabel_.fontName = noticelabel_.fontName;
        numberLabel_.fontColor = noticelabel_.fontColor;
        numberLabel_.zPosition = LABEL_Z_POS;
        */

        
        resetButton_ = [[SKSpriteNode alloc] initWithImageNamed:@"ar_res/ui/reset.png"];
        resetButton_.size = CGSizeMake(40, 40);
        resetButton_.userInteractionEnabled = false;
        resetButton_.position = CGPointMake([UIScreen mainScreen].bounds.size.width -  resetButton_.size.width*0.6, resetButton_.size.height*0.6);
        resetButton_.name = RESET_BUTTON_NAME;
        resetButton_.zPosition = LABEL_Z_POS;
        
        [self setNodeNumer:0];
        //currentRemainAnchorCount_ = 0;
        [self setSuccessNodeNumer:0];
        
        nodeTypeAnchorDict_ = [[NSMutableDictionary alloc]initWithCapacity:[ARData getInstance].totalFighterCount];
        
        //nodeTypeArray_ = [[NSMutableArray alloc]initWithCapacity:[ARData getInstance].totalFighterCount];
        
        //[self resetNodeTypeArray];
        [self initGifDataMap];
        
        distanceNotifyNode_ = [[SKSpriteNode alloc]initWithImageNamed:@"ar_res/ui/distance_notify.png"];
        distanceNotifyNode_.xScale = distanceNotifyNode_.yScale = [UIScreen mainScreen].bounds.size.height * 0.1 / distanceNotifyNode_.size.height ;
        distanceNotifyNode_.position = CGPointMake([UIScreen mainScreen].bounds.size.width*0.5, [UIScreen mainScreen].bounds.size.height - distanceNotifyNode_.frame.size.height*0.75);
        
        directionNotifyNode_ = [[SKSpriteNode alloc]initWithImageNamed:@"ar_res/ui/direction_notify.png"];
        directionNotifyNode_.xScale = directionNotifyNode_.yScale = [UIScreen mainScreen].bounds.size.height * 0.1 / directionNotifyNode_.size.height ;
        directionNotifyNode_.position = CGPointMake([UIScreen mainScreen].bounds.size.width*0.5, [UIScreen mainScreen].bounds.size.height - directionNotifyNode_.frame.size.height*0.75);
        directionNotifyNode_.hidden = NO;
        
        titleNode_ = [[SKSpriteNode alloc]initWithImageNamed:@"ar_res/ui/title_floor.png"];
        titleNode_.xScale = titleNode_.yScale = [UIScreen mainScreen].bounds.size.width / titleNode_.size.width ;
        titleNode_.position = CGPointMake([UIScreen mainScreen].bounds.size.width*0.5, [UIScreen mainScreen].bounds.size.height - titleNode_.frame.size.height*0.5);
        titleNode_.hidden = NO;
        
        closeNode_ = [[TouchableSpriteNode alloc]initWithImageNamed:@"ar_res/ui/close.png"];
        closeNode_.xScale = closeNode_.yScale = [UIScreen mainScreen].bounds.size.width*0.12 / closeNode_.size.width ;
        closeNode_.position = CGPointMake([UIScreen mainScreen].bounds.size.width - closeNode_.frame.size.width*0.5, [UIScreen mainScreen].bounds.size.height - closeNode_.frame.size.height*0.5);
        closeNode_.hidden = NO;
        closeNode_.normalImage = @"ar_res/ui/close.png";
        closeNode_.highlightImage = @"ar_res/ui/close_highlight.png";
        closeNode_.zPosition = LABEL_Z_POS;
        
        
        foundNoticeLabel_ = [SKLabelNode labelNodeWithText:@"今日已找到格斗家:"];
        foundNoticeLabel_.fontSize = titleNode_.frame.size.height*0.25;
        foundNoticeLabel_.fontName =  [UIFont boldSystemFontOfSize:20.f].fontName;
        foundNoticeLabel_.fontColor = SKColor.whiteColor;
        foundNoticeLabel_.zPosition = LABEL_Z_POS;
        
        
        foundNumberLabel_ = [SKLabelNode labelNodeWithText:[NSString stringWithFormat:@"%d/%d", [ARData getInstance].totalFighterCount-[ARData getInstance].remainGuessCount, [ARData getInstance].totalFighterCount]];
        foundNumberLabel_.fontSize = foundNoticeLabel_.fontSize;
        foundNumberLabel_.fontName =  foundNoticeLabel_.fontName;
        foundNumberLabel_.fontColor = foundNoticeLabel_.fontColor;
        foundNumberLabel_.zPosition = LABEL_Z_POS;
        

        
        guessMode_ = NO;
        
        guessContainerNode_= nil;
        
        cameraFrameTransform_ = matrix_identity_float4x4;
        [self resetTrack];
        
    }
    return self;
    
}

-(void)initGifDataMap
{
    gifDataDictionary_ = [NSMutableDictionary dictionary];
    
    NSString *file = @"";
    NSString *frameFile = @"";
    BOOL isDir = YES;
    BOOL exist = YES;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ar_res/anim" ofType:@""];
    for (int i=1; ;i++)
    {
        file = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", i]];
        NSMutableArray* array = [NSMutableArray array];
        exist = [[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:&isDir];
        if (!exist || !isDir)
            break;
        gifDataDictionary_[@(i)] = array;
        for (int k=1; ;k++)
        {
            frameFile = [file stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.png", k]];
            exist = [[NSFileManager defaultManager] fileExistsAtPath:frameFile isDirectory:&isDir];
            if (!exist || isDir)
                break;
            [array addObject:frameFile];
        }
        
    }
    
    int a = 1;
    
}
/*
 -(void)resetNodeTypeArray
 {
 
 [nodeTypeArray_  removeAllObjects];
 for (int i=0; i<6; i++)
 [nodeTypeArray_ addObject:@(i)];
 [nodeTypeArray_ myshuffle];
 
 }
 */
-(SKNode*) generateSKSpriteNode:(int)gifIndex_orig
{
    int gifIndex = gifIndex_orig;
    /*
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
     */
    NSArray* gifFramePathArray = [gifDataDictionary_ objectForKey:@(gifIndex)];
    if (![gifFramePathArray isKindOfClass:[NSArray class]])
        return nil;
    if (gifFramePathArray.count == 0)
        return nil;
    
    NSMutableArray* frames = [NSMutableArray arrayWithCapacity:gifFramePathArray.count];
    for (NSString* texName in gifFramePathArray)
    {
        if (![texName isKindOfClass:[NSString class]])
            return nil;
        SKTexture* texture = [SKTexture textureWithImageNamed:texName];
        [frames addObject:texture];
    }
    
    SKSpriteNode* node = [SKSpriteNode spriteNodeWithImageNamed:gifFramePathArray[0]];
    
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
    SKNode* emptyNode = nil;//[SKNode node];
    // Create and configure a node for the anchor added to the view's session.
    if ([ARData getInstance].currentCreateIndex >= [ARData getInstance].totalFighterCount)
        return emptyNode;
    NSArray<ARGuessData*>* guessDataArray = [ARData getInstance].guessDataArray;
    if ([ARData getInstance].currentCreateIndex >= guessDataArray.count)
        return emptyNode;
    ARGuessData* guessData = [guessDataArray objectAtIndex:[ARData getInstance].currentCreateIndex];
    SKNode* node = [self generateSKSpriteNode:guessData.fighterId];
    if (node == nil)
        return emptyNode;
    [ARData getInstance].currentCreateIndex++;
    int gifIndex = [self getGifIndexByNodeName:node.name];
    nodeTypeAnchorDict_[@(gifIndex)] = anchor;
    return node;
}


- (void)didMoveToView:(SKView *)view {
    // Setup your scene here
    //[self addChild:noticelabel_];
    //[self addChild:numberLabel_];
    [self addChild:foundNoticeLabel_];
    [self addChild:foundNumberLabel_];
    [self addChild:resetButton_];
    [self addChild:distanceNotifyNode_];
    distanceNotifyNode_.alpha = 0;
    [self addChild:directionNotifyNode_];
    [self addChild:titleNode_];
    [self addChild:closeNode_];
    [self updateLabels];
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
    //numberLabel_.text = [NSString stringWithFormat:@"%d", nodeNumber_];
    foundNumberLabel_.text = [NSString stringWithFormat:@"%d/%d", [ARData getInstance].totalFighterCount-[ARData getInstance].remainGuessCount, [ARData getInstance].totalFighterCount];
    
    //numberLabel_.position = CGPointMake(noticelabel_.frame.size.width+noticelabel_.frame.origin.x + 10 + numberLabel_.frame.size.width*0.5, noticelabel_.position.y);
    
    
    foundNoticeLabel_.position = CGPointMake(titleNode_.frame.size.width*0.16f, [UIScreen mainScreen].bounds.size.height - foundNoticeLabel_.frame.size.height*1.0);
    
    foundNumberLabel_.position = CGPointMake(foundNoticeLabel_.frame.size.width+foundNoticeLabel_.frame.origin.x + foundNumberLabel_.frame.size.width*0.5, foundNoticeLabel_.position.y);
}

- (void)update:(CFTimeInterval)currentTime {
    if (!directionNotifyNode_.hidden || guessMode_)
        return;
    static NSTimeInterval lastCreateTime = 0;
    NSTimeInterval now = [[NSDate  date]timeIntervalSince1970];
    if (now - lastCreateTime < 5)
        return;
    // Called before each frame is rendered
    
    
    int shouldCreateCount = [ARData getInstance].totalFighterCount - nodeNumber_ - successedAnchorCount_;
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
    //translation.columns[3].z = -1.5;
    // Combine the rotation and translation matrices
    simd_float4x4 transform = simd_mul(rotation, translation);
    transform = translation;
    translation.columns[3].z = -1.0;
    // Create an anchor
    ARAnchor* anchor = [[ARAnchor alloc]initWithTransform:transform];
    
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
    
    if ([hitNode isKindOfClass:[TouchableSpriteNode class]])
    {
        [currentTouchableNode_ touchesCancelled:nil withEvent:nil];
        currentTouchableNode_ = (TouchableSpriteNode*)hitNode;
        [currentTouchableNode_ touchesBegan:touches withEvent:event];
    }
    
    if (guessMode_)
    {
        if ([hitNode.name hasPrefix:OPTION_NODE_NAME])
        {
            [self optionSelected:hitNode];
            [guessContainerNode_ runAction:
             [SKAction sequence:@[
                                  [SKAction waitForDuration:2.0],
                                  [SKAction runBlock:^{
                 for (SKNode* node in guessContainerNode_.children)
                 {
                     [node runAction:[SKAction fadeOutWithDuration:0.5]];
                 }
             }],
                                  [SKAction waitForDuration:1.0],
                                  [SKAction runBlock:^{
                 [guessContainerNode_ removeFromParent];
                 guessContainerNode_ = nil;
                 guessMode_ = NO;
             }],
                                  ]]];
        }
        return;
    }
    
    
    
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
        float screensize = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)*[UIScreen mainScreen].scale;
        float rate = currentlength/ screensize;
        if (rate < TOUCH_RATE)
        {
            [self showNotifyForDistance];
            return;
        }
        [self touchSuccess:hitNode];
        return;
    }
    
    if (hitNode == closeNode_)
    {
        [UIAlertView showWithTitle:@"提示" message:@"需要退出么?" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
            if (1 == buttonIndex)
            {
                exit(0);
            }
        }];
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

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [currentTouchableNode_ touchesMoved:touches withEvent:event];
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [currentTouchableNode_ touchesCancelled:touches withEvent:event];
    currentTouchableNode_ = nil;
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [currentTouchableNode_ touchesEnded:touches withEvent:event];
    currentTouchableNode_ = nil;
}
-(void)optionSelected:(SKNode*) hitNode
{
    NSAssert([hitNode.name hasPrefix:OPTION_NODE_NAME], @"getGifIndexByNodeName data error");
    NSString* string = [hitNode.name substringFromIndex:OPTION_NODE_NAME.length];
    int optionsIndex = string.intValue;
    BOOL success = NO;
    if (optionsIndex == 1)
        success = YES;
    
    SKSpriteNode* optionNode = (SKSpriteNode*)hitNode;
    if (![optionNode isKindOfClass:[SKSpriteNode class]])
        return;
    if (!success)
        optionNode.texture = [SKTexture textureWithImageNamed:@"error.png"];
    else
    {
        for (SKSpriteNode* node in guessContainerNode_.children)
        {
            if ([node isKindOfClass:[SKSpriteNode class]] && [node.name hasPrefix:MY_NODE_NAME])
                node.colorBlendFactor = 0;
        }
        
        optionNode.texture = [SKTexture textureWithImageNamed:@"success.png"];
    }
    
}

-(void)touchSuccess:(SKNode*) hitNode
{
    [guessContainerNode_ removeFromParent];
    guessContainerNode_ = [SKNode node];
    [self addChild:guessContainerNode_];
    guessContainerNode_.zPosition = GUESS_Z_POS;
    guessMode_ = YES;
    int gifIndex = [self getGifIndexByNodeName:hitNode.name];
    
    SKNode* newNode = [self generateSKSpriteNode:gifIndex];
    newNode.position = hitNode.position;
    newNode.yScale = hitNode.yScale;
    newNode.xScale = hitNode.xScale;
    [guessContainerNode_ addChild:newNode];
    
    
    ARAnchor* anchor = nodeTypeAnchorDict_[@(gifIndex)];
    if (anchor != nil)
    {
        ARSKView* sceneView= (ARSKView*)self.view;
        if (![sceneView isKindOfClass:[ARSKView class]]){
            return;
        }
        
        [sceneView.session removeAnchor:anchor];
    }
    //[self pauseTrack];
    [nodeTypeAnchorDict_ removeObjectForKey:@(gifIndex)];
    [self setNodeNumer:nodeNumber_-1];
    [self showGuessView: newNode];
    [hitNode removeFromParent];
    [self setSuccessNodeNumer:successedAnchorCount_+1];
    
    
}


-(void)showGuessView:(SKNode*)guessNode
{
    //bezier curve
    
    SKSpriteNode* toGuessNode = (SKSpriteNode*)guessNode;
    if (![toGuessNode isKindOfClass:[SKSpriteNode class]])
        return;
    
    float targetNodeHeight = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) * 0.8;
    
    
    float guessNodeHeight = toGuessNode.texture.size.height;
    
    float scale = targetNodeHeight / guessNodeHeight;
    
    CGPoint position;
    position.x = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) * 0.25;
    position.y = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) * 0.5;
    
    float duration = 0.8;
    CGMutablePathRef cgpath = CGPathCreateMutable();
    CGPoint startingPoint = guessNode.position;
    CGPoint controlPoint1 = CGPointMake((guessNode.position.x + position.x)*0.5, [UIScreen mainScreen].bounds.size.height*5.5);
    CGPoint endingPoint = position;
    CGPathMoveToPoint(cgpath, NULL, startingPoint.x, startingPoint.y);
    CGPathAddCurveToPoint(cgpath, NULL, controlPoint1.x, controlPoint1.y,
                          controlPoint1.x, controlPoint1.y,
                          endingPoint.x, endingPoint.y);
    SKAction *enemyCurve = [SKAction followPath:cgpath asOffset:NO orientToPath:NO duration:duration];
    SKAction* scaleAction = [SKAction scaleTo:scale duration:duration];
    //SKAction* moveAction = [SKAction moveTo:position duration:duration];
    SKAction* groupAction = [SKAction group:@[scaleAction, enemyCurve]];
    groupAction.timingMode = SKActionTimingEaseIn;
    SKAction* blockAction = [SKAction runBlock:^{
        for (int i= 0; i<4; i++)
        {
            SKSpriteNode* optionNode = [SKSpriteNode spriteNodeWithImageNamed:@"options.png"];
            optionNode.yScale = optionNode.xScale = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)*0.4/optionNode.texture.size.width;
            
            optionNode.position = CGPointMake(MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)*0.75, (i*0.6/3.0+0.2)*MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height));
            
            [guessContainerNode_ addChild:optionNode];
            optionNode.name = [NSString stringWithFormat:@"%@%d", OPTION_NODE_NAME, i];
            
            optionNode.alpha = 0.f;
            SKAction* fade = [SKAction fadeAlphaTo:1.0 duration:0.3];
            fade.timingMode = SKActionTimingEaseIn;
            [optionNode runAction:fade];
        }
    }];
    [toGuessNode runAction:[SKAction sequence:@[groupAction, blockAction]]];
    
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
-(void) resumeTrack
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RESUME_ARKIT_TRACK_FROM_SCENE object:nil];
}
-(void) pauseTrack
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PAUSE_ARKIT_TRACK_FROM_SCENE object:nil];
}
- (void) resetCount
{
    [self setNodeNumer:0];
    
    [nodeTypeAnchorDict_ removeAllObjects];
    //[self resetNodeTypeArray];
    
    //currentRemainTAnchorCount_ = 0;
}



- (void)dealloc
{
}
- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame;
{
    cameraFrameTransform_ = frame.camera.transform;
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

- (void)setDirectionNotifyNodeVisible:(BOOL)visible;
{
    directionNotifyNode_.hidden = !visible;
}





@end

