//
//  SPUpdaterState.m
//  SPUpdater
//
//  Created by Jay on 2017/12/13.
//  Copyright © 2017年 tiny. All rights reserved.
//

#import "SPUpdaterState.h"
#import "SPLogHelper.h"
#import "SPPathManager.h"
#import <YYModel.h>
#import "NSData+SP.h"
#import "VDFParser.h"

@implementation SPUpdaterState

+ (instancetype)lastState
{
    NSString *path = [SPPathManager stateFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        
        NSData *data = [NSData dataWithContentsOfFile:path];
        SPUpdaterState *state = [SPUpdaterState yy_modelWithJSON:data];
        return state;
    
    }else{
        
        SPUpdaterState *state = [[SPUpdaterState alloc] init];
        return state;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _oldServiceOn = NO;
        _adServiceOn = YES;
        _proServiceOn = YES;
        
        _lastCheckTime = [NSDate distantPast].timeIntervalSince1970;
        _nextCheckTime = [NSDate distantFuture].timeIntervalSince1970;
        _lastUpdateTime = _lastCheckTime;
        
        _baseDataVersion = 0;
        _langVersion = [NSMutableDictionary dictionary];
        _langPatchVersion = [NSMutableDictionary dictionary];
        
        _url = @"";
        _dota2Buildid = 0;
        _dota2LastUpdated = 0;
    }
    return self;
}

// 重置为上次存档的状态
- (void)reset
{
    SPLog(@"重置 Updater 状态");
    SPUpdaterState *state = [SPUpdaterState lastState];
    
    self.baseDataVersion = state.baseDataVersion;
    self.langVersion = [state.langVersion mutableCopy];
    self.langPatchVersion = [state.langPatchVersion mutableCopy];
    
    self.url = state.url;
    self.dota2Buildid = state.dota2Buildid;
    self.dota2LastUpdated = state.dota2LastUpdated;
}

// 保存状态
- (void)save
{
    id jsonObject = [self yy_modelToJSONObject];
    if (!jsonObject) return;
    SPLog(@"保存 Updater 状态：%@",jsonObject);
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:NULL];
    NSString *path = [SPPathManager stateFilePath];
    [data spSafeWriteToFile:path error:nil];
}

- (long long)getLangVersion:(NSString *)lang
{
    return [self.langVersion[lang] longLongValue];
}

- (void)setLangVersion:(long long)version lang:(NSString *)lang
{
    NSMutableDictionary *dict = [self.langVersion mutableCopy];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    dict[lang] = @(version);
    self.langVersion = dict;
}

- (long long)getPatchVersion:(NSString *)lang
{
    return [self.langPatchVersion[lang] longLongValue];
}

- (void)setPatchVersion:(long long)version lang:(NSString *)lang
{
    NSMutableDictionary *dict = [self.langPatchVersion mutableCopy];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    dict[lang] = @(version);
    self.langPatchVersion = dict;
}

+ (NSString *)latestItemGameURL
{
    SPLog(@"获取 items_game_url ");
    NSString *apiURL = @"https://api.steampowered.com/IEconItems_570/GetSchemaURL/v1?key=CD9010FD71FA1583192F9BDB87ED8164";
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:apiURL] options:NSDataReadingMappedIfSafe error:&error];
    if (!data || error) {
        SPLog(@"获取schemaURL失败！error:%@",error);
        return nil;
    }
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( !json || error || ![json isKindOfClass:[NSDictionary class]]) {
        SPLog(@"items_game数据错误。data:%@\nerror:%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding],error);
        return nil;
    }
    
    NSString *items_game_url = json[@"result"][@"items_game_url"];
    SPLog(@"items_game_url: %@",items_game_url);
    
    return items_game_url;
}

+ (BOOL)latestDotaInfo:(long long *)lastupdate
               buildid:(long long *)buildid
{
    NSData *data = [NSData dataWithContentsOfFile:[SPDota2PathManager dotaManifestPath]];
    if (!data) {
        SPLog(@"读取 appmanifest_570.acf 文件失败！");
        return NO;
    }
    
    VDFNode *root = [VDFParser parse:data];
    if (!root) {
        SPLog(@"解析 appmanifest_570.acf 文件失败！");
        return NO;
    }
    
    NSDictionary *dict = [root allDict];
    int state = [dict[@"AppState"][@"stateflags"] intValue];
    if (state != 4) {
        SPLog(@"StateFlags 不是 4 ? appmanifest_570.acf 内容：");
        SPLog(@"{\n%@\n}",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        SPLog(@"读取 appmanifest_570.acf 提前退出！");
        return NO;
    }
    NSString *lastupdateInfo = dict[@"AppState"][@"lastupdated"];
    NSString *buildidInfo = dict[@"AppState"][@"buildid"];
    
    if (lastupdate) {
        *lastupdate = lastupdateInfo.longLongValue;
    }
    if (buildid) {
        *buildid = buildidInfo.longLongValue;
    }
    return YES;
}

@end
