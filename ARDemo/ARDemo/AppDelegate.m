//
//  AppDelegate.m
//  ARDemo
//
//  Created by apple on 02/09/2017.
//  Copyright © 2017 fish. All rights reserved.
//

#import "AppDelegate.h"
#import "ARData.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
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
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    dict[@"remainGuessCount"] = @(3);
    dict[@"guessInfo"] = [NSMutableArray array];
    
    {
        NSMutableDictionary* tempDict = [NSMutableDictionary dictionary];
        tempDict[@"fighterID"] = @(3);
        tempDict[@"answerIndex"] = @(2);
        tempDict[@"guessNames"] = @[@"知道火舞", @"不知水舞", @"不知火舞", @"知道水舞"];
        [dict[@"guessInfo"] addObject:tempDict];
    }
    
    {
        NSMutableDictionary* tempDict = [NSMutableDictionary dictionary];
        tempDict[@"fighterID"] = @(2);
        tempDict[@"answerIndex"] = @(1);
        tempDict[@"guessNames"] = @[@"七神", @"八神", @"九神", @"十神"];
        [dict[@"guessInfo"] addObject:tempDict];
    }
    
    {
        NSMutableDictionary* tempDict = [NSMutableDictionary dictionary];
        tempDict[@"fighterID"] = @(1);
        tempDict[@"answerIndex"] = @(0);
        tempDict[@"guessNames"] = @[@"坂崎良", @"板崎良", @"板琦良", @"坂琦良"];
        [dict[@"guessInfo"] addObject:tempDict];
    }

    [[ARData getInstance] setFighterGuessInfo:dict];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
