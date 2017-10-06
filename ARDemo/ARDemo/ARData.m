//
//  ARData.m
//  ARDemo
//
//  Created by apple on 02/10/2017.
//  Copyright © 2017 fish. All rights reserved.
//
#if !__has_feature(objc_arc)
#error "open arc please"
#endif
#import "ARData.h"

@implementation ARGuessData
@end

@implementation ARData
+(ARData*)getInstance;
{
    static ARData* s_data = nil;
    if (s_data == nil)
        s_data = [[ARData alloc] init];
    return s_data;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.remainGuessCount = 0;
        self.totalFighterCount = 0;
        self.guessDataArray = [NSMutableArray array];
        self.currentCreateIndex = 0;
    }
    return self;
}
- (void)updateRemainGuessCount
{
    NSNumber* number = self.guessInfoDict[@"remainGuessCount"];
    if ([number isKindOfClass:[NSNumber class]])
        self.remainGuessCount = number.intValue;
}

- (void)updateGuessData
{
    self.totalFighterCount = 0;
    self.currentCreateIndex = 0;
    [self.guessDataArray removeAllObjects];
    NSArray* array = self.guessInfoDict[@"guessInfo"];
    if (![array isKindOfClass:[NSArray class]])
        return;
    
    for (NSDictionary* dict in array)
    {
        if (![dict isKindOfClass:[NSDictionary class]])
            continue;
        
        ARGuessData* data = [[ARGuessData alloc] init];
        
        NSNumber* number = dict[@"fighterID"];
        if (![number isKindOfClass:[number class]])
            continue;
        data.fighterId = number.intValue;
        
        number = dict[@"answerIndex"];
        if (![number isKindOfClass:[number class]])
            continue;
        data.answerIndex = number.intValue;
        
        
        NSArray* array = dict[@"guessNames"];
        if (![array isKindOfClass:[NSArray class]])
            continue;
        NSMutableArray* stringArray = [NSMutableArray arrayWithCapacity:array.count];
        for (NSString* string in array)
        {
            if (![string isKindOfClass:[NSString class]])
                continue;
            
            [stringArray addObject:string];
        }
        
        data.guessAnswerStringArray = stringArray;
        
        
        [self.guessDataArray addObject:data];
        self.totalFighterCount ++;
    }
    
#ifdef DEBUG
    self.totalFighterCount = 1;
#endif
}

- (void)setFighterGuessInfo:(NSDictionary*)guessInfo;
{
    self.guessInfoDict = guessInfo;
    [self updateRemainGuessCount];
    [self updateGuessData];
}

@end
