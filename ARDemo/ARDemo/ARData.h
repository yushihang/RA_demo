//
//  ARData.h
//  ARDemo
//
//  Created by apple on 02/10/2017.
//  Copyright © 2017 fish. All rights reserved.
//
#if !__has_feature(objc_arc)
#error "open arc please"
#endif
#import <Foundation/Foundation.h>
@interface ARGuessData : NSObject
@property (nonatomic, retain) NSArray<NSString*>* guessAnswerStringArray;
@property (nonatomic, assign) int answerIndex;
@property (nonatomic, assign) int fighterId;

@end


@interface ARData : NSObject
+ (ARData*)getInstance;
/*
 按照策划案，每天最多只能猜6次，并且成功次数只能3次
 建议每次开始都重新请求一次数据
 int remainGuessCount 本次还可以猜的次数
 array  guessInfo 每次传递若干个如下信息的数组
 {
 int fighterID 对应ar_res/anim下的目录名
 array(string) guessNames 4个备选名字
 int answerIndex [0-3]
 }
 
 */
- (void)setFighterGuessInfo:(NSDictionary*)guessInfo;

@property (nonatomic, assign)int remainGuessCount;
@property (nonatomic, assign)int totalFighterCount;
@property (nonatomic, retain) NSMutableArray<ARGuessData*>* guessDataArray;
@property (nonatomic, retain) NSDictionary* guessInfoDict;
@property (nonatomic, assign) int currentCreateIndex;
@end
