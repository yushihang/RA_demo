//
//  TouchableSpriteNode.h
//  ARDemo
//
//  Created by apple on 06/10/2017.
//  Copyright © 2017 fish. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#define YH_TouchableSpriteNode_Notification @"__YH_TouchableSpriteNode_Notification_!!"

@interface TouchableSpriteNode : SKSpriteNode
@property (nonatomic, retain) NSString* normalImage;
@property (nonatomic, retain) NSString* highlightImage;
@end
