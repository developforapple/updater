//
//  SPPathManager.h
//  ShiPing
//
//  Created by Jay on 2017/12/5.
//  Copyright © 2017年 wwwbbat. All rights reserved.
//

#import <Foundation/Foundation.h>

// 不要直接使用这个类。获取文件路径。需要使用相关的子类来获取正确的路径。
@interface SPPathManager : NSObject

+ (void)createFolderIfNeed:(NSString *)path;

// 根目录。在 BuildSetting 中使用宏 TMPFILEPATH 指定
+ (NSString *)rootDir;                                  // ../Files
+ (NSString *)stateFilePath;                            // ../Files/State.json
+ (NSString *)logFilePath;                              // ../Files/log.txt
+ (NSString *)imageDir;                                 // ../Files/image/

// 在根目录下的随机目录
+ (NSString *)randomDir;

// 工作目录。需要子类来确定是哪个文件夹。
+ (NSString *)workDir;                                  // ?
+ (NSString *)downloadDir;                              // ${workDir}/download/
+ (NSString *)baseDataDir;                              // ${workDir}/basedata/
+ (NSString *)langRootDir;                              // ${workDir}/lang/
+ (NSString *)langDir:(NSString *)lang;                 // ${workDir}/lang/${lang}/

+ (NSString *)langMainFilePath:(NSString *)lang;        // ${workDir}/lang/${lang}/lang.json
+ (NSString *)langPatchFilePath:(NSString *)lang;       // ${workDir}/lang/${lang}/lang_patch.json
+ (NSString *)langMainZipFilePath:(NSString *)lang
                          version:(long long)version;   // ${workDir}/lang/${lang}/${lang}_${version}.json
+ (NSString *)langPatchZipFilePath:(NSString *)lang
                           version:(long long)version
                             patch:(long long)patch;    // ${workDir}/lang/${lang}/${lang}_${version}_${patch}_patch.json
+ (NSString *)langChangeLogFilePath:(NSString *)lang
                              patch:(long long)patch;   // ${workDir}/lang/${lang}/change_log_${patch}.json

+ (NSString *)itemsGameTxtFilePath:(NSString *)name;    // ${workDir}/download/${name}

+ (NSString *)baseDataFilePath;                         // ${workDir}/basedata/data.json
+ (NSString *)itemDatabaseFilePath;                     // ${workDir}/basedata/item.db
+ (NSString *)itemChangeLogFilePath;                    // ${workDir}/basedata/change.json
+ (NSString *)baseDataZipFilePath:(long long)version;   // ${workDir}/basedata/base_data_${version}.zip

@end

// 获取归档的相关路径时使用这个类
@interface SPArchivePathManager : SPPathManager
@end

// 获取临时路径时使用这个类
@interface SPTmpPathManager : SPPathManager
@end

// 游戏文件相关的路径
@interface SPDota2PathManager : NSObject
// /Applications/SteamLibrary/SteamApps/appmanifest_570.acf
+ (NSString *)dotaManifestPath;
// /Applications/SteamLibrary/SteamApps/common/dota 2 beta/game/dota
+ (NSString *)dotaDir;
// /Applications/SteamLibrary/SteamApps/common/dota 2 beta/game/dota/panorama/localization/dota_${lang}.txt
+ (NSString *)dotaLangFile1:(NSString *)lang;
// /Applications/SteamLibrary/SteamApps/common/dota 2 beta/game/dota/resource/dota_${lang}.txt
+ (NSString *)dotaLangFile2:(NSString *)lang;
// /Applications/SteamLibrary/SteamApps/common/dota 2 beta/game/dota/resource/items_${lang}.txt
+ (NSString *)dotaLangFile3:(NSString *)lang;
// /Applications/SteamLibrary/SteamApps/common/dota 2 beta/game/dota/scripts/npc/npc_heroes.txt
+ (NSString *)dotaHeroListFile;
@end
