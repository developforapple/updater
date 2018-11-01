//
//  SPPathManager.m
//  ShiPing
//
//  Created by Jay on 2017/12/5.
//  Copyright © 2017年 wwwbbat. All rights reserved.
//

#import "SPPathManager.h"

#define _yg_cat(a,b) a b
#define _yg_str1(a) # a
#define _yg_str2(a) _yg_str1(a)
#define _yg_prefix1 @
#define _yg_prefix2 _yg_prefix1
#define _yg_toNSString1(a) _yg_cat(_yg_prefix2, _yg_str2(a))
#define YGTokenToString(token) _yg_toNSString1(token)


#define FileManager [NSFileManager defaultManager]

@implementation SPPathManager

+ (void)createFolderIfNeed:(NSString *)path
{
    NSError *error;
    BOOL isDirectory = NO;
    BOOL exists = [FileManager fileExistsAtPath:path isDirectory:&isDirectory];
    if (!exists) {
        BOOL suc = [FileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        NSAssert(suc && !error, @"出错了");
    }else if(!isDirectory){
        [FileManager removeItemAtPath:path error:nil];
        BOOL suc = [FileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        NSAssert(suc && !error, @"出错了");
    }
}

+ (NSString *)rootDir
{
    NSString *path = YGTokenToString(TMPFILEPATH);
    [self createFolderIfNeed:path];
    return path;
}

+ (NSString *)stateFilePath
{
    return [[self rootDir] stringByAppendingPathComponent:@"State.json"];
}

+ (NSString *)logFilePath
{
    return [[self rootDir] stringByAppendingPathComponent:@"log.txt"];
}

+ (NSString *)randomDir
{
    return [[self rootDir] stringByAppendingPathComponent:[NSString stringWithFormat:@".tmp_%lld",(long long)arc4random_uniform(99999999)]];
}

+ (NSString *)workDir
{
    // 子类来决定
    return nil;
}

+ (NSString *)downloadDir
{
    NSString *path = [[self workDir] stringByAppendingPathComponent:@"download"];
    [self createFolderIfNeed:path];
    return path;
}

+ (NSString *)imageDir
{
    NSString *path = [[self rootDir] stringByAppendingPathComponent:@"image"];
    [self createFolderIfNeed:path];
    return path;
}

+ (NSString *)baseDataDir
{
    NSString *path = [[self workDir] stringByAppendingPathComponent:@"basedata"];
    [self createFolderIfNeed:path];
    return path;
}

+ (NSString *)langRootDir
{
    NSString *path = [[self workDir] stringByAppendingPathComponent:@"lang"];
    [self createFolderIfNeed:path];
    return path;
}

+ (NSString *)langDir:(NSString *)lang
{
    NSString *path = [[self langRootDir] stringByAppendingPathComponent:lang];
    [self createFolderIfNeed:path];
    return path;
}

+ (NSString *)langMainFilePath:(NSString *)lang
{
    return [[self langDir:lang] stringByAppendingPathComponent:@"lang.json"];
}

+ (NSString *)langPatchFilePath:(NSString *)lang
{
    return [[self langDir:lang] stringByAppendingPathComponent:@"lang_patch.json"];
}

+ (NSString *)langMainZipFilePath:(NSString *)lang
                          version:(long long)version
{
    return [[self langDir:lang] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%lld.zip",lang,version]];
}

+ (NSString *)langPatchZipFilePath:(NSString *)lang
                           version:(long long)version
                             patch:(long long)patch
{
    return [[self langDir:lang] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%lld_%lld_patch.zip",lang,version,patch]];
}

+ (NSString *)langChangeLogFilePath:(NSString *)lang
                              patch:(long long)patch
{
    return [[self langDir:lang] stringByAppendingPathComponent:[NSString stringWithFormat:@"change_log_%lld.json",patch]];
}

+ (NSString *)itemsGameTxtFilePath:(NSString *)name
{
    return [[self downloadDir] stringByAppendingPathComponent:name];
}

+ (NSString *)baseDataFilePath
{
    return [[self baseDataDir] stringByAppendingPathComponent:@"data.json"];
}

+ (NSString *)itemDatabaseFilePath
{
    return [[self baseDataDir] stringByAppendingPathComponent:@"item.db"];
}

+ (NSString *)itemChangeLogFilePath
{
    return [[self baseDataDir] stringByAppendingPathComponent:@"change.json"];
}

+ (NSString *)baseDataZipFilePath:(long long)version
{
    return [[self baseDataDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"base_data_%lld.zip",version]];
}

@end

@implementation SPArchivePathManager

+ (NSString *)workDir
{
    NSString *dir = [[self rootDir] stringByAppendingPathComponent:@"Archive"];
    [self createFolderIfNeed:dir];
    return dir;
}

@end

@implementation SPTmpPathManager

+ (NSString *)workDir
{
    NSString *dir = [[self rootDir] stringByAppendingPathComponent:@"tmp"];
    [self createFolderIfNeed:dir];
    return dir;
}

@end

@implementation SPDota2PathManager
+ (NSString *)dotaManifestPath
{
    return @"/Applications/SteamLibrary/SteamApps/appmanifest_570.acf";
}

+ (NSString *)dotaDir
{
    return @"/Applications/SteamLibrary/SteamApps/common/dota 2 beta/game/dota";
}

+ (NSString *)dotaLangFile1:(NSString *)lang
{
    return [[self dotaDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"panorama/localization/dota_%@.txt",lang]];
}

+ (NSString *)dotaLangFile2:(NSString *)lang
{
    return [[self dotaDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"resource/dota_%@.txt",lang]];
}

+ (NSString *)dotaLangFile3:(NSString *)lang
{
    return [[self dotaDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"resource/items_%@.txt",lang]];
}

+ (NSString *)dotaHeroListFile
{
    return [[self dotaDir] stringByAppendingPathComponent:@"scripts/npc/npc_heroes.txt"];
}
@end
