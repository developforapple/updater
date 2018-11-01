//
//  SPUpdaterState.h
//  SPUpdater
//
//  Created by Jay on 2017/12/13.
//  Copyright © 2017年 tiny. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPUpdaterState : NSObject

@property (assign) BOOL oldServiceOn;
@property (assign) BOOL adServiceOn;
@property (assign) BOOL proServiceOn;

@property (assign) NSTimeInterval lastCheckTime;
@property (assign) NSTimeInterval nextCheckTime;
@property (assign) NSTimeInterval lastUpdateTime;

// version
@property (assign) long long baseDataVersion;
@property (strong) NSDictionary<NSString *,NSNumber *> *langVersion;
@property (strong) NSDictionary<NSString *,NSNumber *> *langPatchVersion;

// resource
@property (copy) NSString *url;
@property (assign) long long dota2Buildid;
@property (assign) long long dota2LastUpdated;

// 上次保存的状态。从未保存过，返回默认状态。
+ (instancetype)lastState;

// 返回默认状态。
- (instancetype)init;

// 重置 version 和 resource 的内容为上次保存的状态。
- (void)reset;

// 保存状态
- (void)save;

- (long long)getLangVersion:(NSString *)lang;
- (void)setLangVersion:(long long)version lang:(NSString *)lang;

- (long long)getPatchVersion:(NSString *)lang;
- (void)setPatchVersion:(long long)version lang:(NSString *)lang;

// 获取最新的item_game_url
+ (NSString *)latestItemGameURL;

// 获取最新的lastupdate和buildid。 当配置文件的state不为4时，返回NO。
+ (BOOL)latestDotaInfo:(long long *)lastupdate
               buildid:(long long *)buildid;

@end
