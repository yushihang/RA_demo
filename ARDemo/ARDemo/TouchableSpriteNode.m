//
//  TouchableSpriteNode.m
//  ARDemo
//
//  Created by apple on 06/10/2017.
//  Copyright © 2017 fish. All rights reserved.
//

#import "TouchableSpriteNode.h"

@interface TouchableSpriteNode()
@property (nonatomic, assign) BOOL isHighlighted_;
@end
@implementation TouchableSpriteNode

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}
-(void)setHighlightStatus:(BOOL)highlight
{
    if (self.isHighlighted_ == highlight)
        return;
    self.isHighlighted_ = highlight;
    if (self.highlightImage == nil || self.normalImage == nil)
        return;
    if (self.isHighlighted_)
        self.texture = [SKTexture textureWithImageNamed:self.highlightImage];
    else
        self.texture = [SKTexture textureWithImageNamed:self.normalImage];
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self setHighlightStatus:YES];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    if (touch == nil)
        return;
    
    CGPoint p = [touch locationInNode:self.parent];
    if (CGRectContainsPoint(self.frame, p))
        [self setHighlightStatus:YES];
    else
        [self setHighlightStatus:NO];
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self setHighlightStatus:NO];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self setHighlightStatus:NO];
}

@end
