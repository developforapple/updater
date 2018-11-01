//
//  SPLocalMapping.m
//  ShiPing
//
//  Created by wwwbbat on 16/4/13.
//  Copyright © 2016年 wwwbbat. All rights reserved.
//

#import "SPLocalMapping.h"
#import "VDFParser.h"
#import <SSZipArchive.h>
#import "SPPathManager.h"
#import "SPLogHelper.h"
#import "NSData+SP.h"

  const long long kMagicNumber = 1010110203019LL;
//const long long kMagicNumber = 1413261661000LL;

static NSString *pwd = @"wwwbbat.DOTA2.19880920";
#define FileManager [NSFileManager defaultManager]

@interface SPLocalMapping ()
@property (weak, nonatomic) SPUpdaterState *state;
@property (copy, nonatomic) NSString *lang;
@end

@implementation SPLocalMapping

- (instancetype)init:(SPUpdaterState *)state
                lang:(NSString *)lang
{
    self = [super init];
    if (self) {
        self.state = state;
        self.lang = lang;
        self.langDict = [NSMutableDictionary dictionary];
        
        [self copyFilesIfNeed];
    }
    return self;
}

- (void)dealloc
{
    SPLog(@"SPLocalMapping 释放");
}

- (void)copyFilesIfNeed
{
    // 如果存在主文件，就复制一份主文件过来
    NSString *mainFile = [SPArchivePathManager langMainFilePath:self.lang];
    if ([[NSFileManager defaultManager] fileExistsAtPath:mainFile]) {
        NSString *tmpMainFile = [SPTmpPathManager langMainFilePath:self.lang];
        [[NSFileManager defaultManager] copyItemAtPath:mainFile toPath:tmpMainFile error:nil];
    }
}

- (BOOL)update
{
    NSString *lang = self.lang;
    
    // 生成最新的本地化数据
    SPLog(@"准备处理语言数据，语言：%@",lang);
    
    NSDictionary *newLangDict = [self loadLocalDataWithLang:lang];
    if (!newLangDict) {
        SPLog(@"读取本地化文件出错了。中断。");
        return NO;
    }
    
    self.langDict[lang] = newLangDict;
    
    // 主版本号，如果需要更新主文件，就用此版本号。不需要更新主文件，依然用旧主版本号
    long long mainVersion;
    // 补丁版本号，更新后总是使用此版本号
    long long patchVersion;
    
    // 保存的文件路径
    NSString *langMainFilePath = [SPTmpPathManager langMainFilePath:self.lang];
    NSString *langPatchFilePath = [SPTmpPathManager langPatchFilePath:self.lang];
    
    BOOL hasMainFile = [[NSFileManager defaultManager] fileExistsAtPath:langMainFilePath];
    if (hasMainFile) {
        mainVersion = [self.state getLangVersion:self.lang];
        patchVersion = [[NSDate date] timeIntervalSince1970] * 1000 - kMagicNumber;
    }else{
        mainVersion = [[NSDate date] timeIntervalSince1970] * 1000 - kMagicNumber;
        patchVersion = mainVersion;
    }
    
    // 压缩文件路径。
    NSString *langMainZipFilePath = [SPTmpPathManager langMainZipFilePath:self.lang version:mainVersion];
    NSString *langPatchZipFilePath = [SPTmpPathManager langPatchZipFilePath:self.lang version:mainVersion patch:patchVersion];
    
    if (hasMainFile == NO) {

        // step: 1
        {
            SPLog(@"没有发现主文件！准备生成主文件...");
            SPLog(@"解析...");
            NSError *error;
            NSData *data = [NSJSONSerialization dataWithJSONObject:newLangDict options:kNilOptions error:&error];
            if (!data || error) {
                SPLog(@"解析主语言数据失败！error:%@",error);
                return NO;
            }
            SPLog(@"保存...");
            
            BOOL created = [data spSafeWriteToFile:langMainFilePath error:&error];
            if (!created || error) {
                SPLog(@"保存主语言文件失败！error:%@",error);
                return NO;
            }
            SPLog(@"保存主语言文件完成！");
        }
        
        // step: 2
        {
            SPLog(@"准备创建空补丁文件...");
            NSError *error;
            NSData *difData = [NSJSONSerialization dataWithJSONObject:@{} options:kNilOptions error:&error];
            if (!difData || error) {
                SPLog(@"生成补丁文件失败！error:%@",error);
                return NO;
            }
            SPLog(@"保存...");
            BOOL suc = [difData spSafeWriteToFile:langPatchFilePath error:&error];
            if (!suc || error) {
                SPLog(@"补丁文件保存失败！error:%@",error);
                return NO;
            }
            SPLog(@"保存补丁文件完成");
        }
        
        // step: 3
        {
            BOOL langMainFileSuc = [self createZipAt:langMainZipFilePath file:langMainFilePath];
            if (!langMainFileSuc) {
                SPLog(@"压缩主文件出错。中断。");
                return NO;
            }
            
            BOOL langPatchFileSuc = [self createZipAt:langPatchZipFilePath file:langPatchFilePath];
            if (!langPatchFileSuc) {
                SPLog(@"压缩补丁文件出错。中断。");
                return NO;
            }
        }
        
        // end
        SPLog(@"更新语言版本号:");
        SPLog(@"更新主语言文件版本至：%lld",mainVersion);
        SPLog(@"更新语言补丁版本至：%lld",patchVersion);
        [self.state setLangVersion:mainVersion lang:lang];
        [self.state setPatchVersion:patchVersion lang:lang];
        
    }else{
    
        // 主文件存在，比较差异
        
        // step: 1
        SPLog(@"主文件已存在。准备生成补丁...");
        NSError *error;
        
        SPLog(@"读取旧主语言文件...");
        NSData *oldLangData = [NSData dataWithContentsOfFile:langMainFilePath options:NSDataReadingMappedIfSafe error:&error];
        if (!oldLangData || error) {
            SPLog(@"读取旧主语言文件失败! error:%@",error);
            return NO;
        }
        
        SPLog(@"解析旧主语言文件...");
        NSDictionary *oldLangDict = [NSJSONSerialization JSONObjectWithData:oldLangData options:kNilOptions error:&error];
        if (!oldLangDict || error || ![oldLangDict isKindOfClass:[NSDictionary class]]) {
            SPLog(@"解析旧主语言文件失败！error:%@",error);
            return NO;
        }
        
        // 新增部分
        NSMutableSet *add = [NSMutableSet set];
        // 修改部分
        NSMutableSet *modify = [NSMutableSet set];
        
        // step: 2
        // 比较旧主文件和新主文件的差异，差异部分即为此次的补丁内容。
        SPLog(@"比较差异内容...");
        NSMutableDictionary *newPatch = [NSMutableDictionary dictionary];
        {
            for (NSString *newKey in newLangDict) {
                NSString *newValue = newLangDict[newKey];
                NSString *oldValue = oldLangDict[newKey];
                if (!oldValue) {
                    // 新出现的key
                    [add addObject:newKey];
                    newPatch[newKey] = newValue;
                }else if (![oldValue isEqualToString:newValue]) {
                    // 旧的key，但是value变了
                    [modify addObject:newKey];
                    newPatch[newKey] = newValue;
                }
            }
        }
        SPLog(@"比较得到 %d 条结果。新增 %d 条。修改 %d 条",(int)newPatch.count,(int)add.count,(int)modify.count);
        
        // step: 3
        // 保存补丁到文件
        {
            SPLog(@"准备创建补丁文件...");
            NSData *patchData = [NSJSONSerialization dataWithJSONObject:newPatch options:kNilOptions error:&error];
            if (!patchData || error) {
                SPLog(@"生成补丁文件失败！error:%@",error);
                return NO;
            }
            SPLog(@"准备保存补丁文件...");
            BOOL suc = [patchData spSafeWriteToFile:langPatchFilePath error:&error];
            if (!suc || error) {
                SPLog(@"保存补丁文件失败！error:%@",error);
                return NO;
            }
            SPLog(@"生成补丁文件完成");
        }
        

        // step: 4
        // 保存本次更新的更新内容
        {
            // 保存
            SPLog(@"准备生成语言文件更新记录...");
            NSMutableDictionary *changeLog = [NSMutableDictionary dictionary];
            changeLog[@"add"] = [add objectEnumerator].allObjects;
            changeLog[@"modify"] = [modify objectEnumerator].allObjects;
            NSData *changeLogData = [NSJSONSerialization dataWithJSONObject:changeLog options:kNilOptions error:&error];
            if (!changeLogData || error) {
                SPLog(@"生成语言文件更新记录失败！error:%@",error);
                return NO;
            }
            
            SPLog(@"保存语言文件更新记录...");
            NSString *changeLogPath = [SPTmpPathManager langChangeLogFilePath:self.lang patch:patchVersion];
            BOOL suc = [changeLogData spSafeWriteToFile:changeLogPath error:&error];
            if (!suc || error) {
                SPLog(@"保存语言文件更新记录失败！error:%@",error);
                return NO;
            }
            SPLog(@"保存语言文件更新记录完成");
        }
        
        // 这里只生成补丁zip 不用生成主文件zip
        BOOL langPatchFileSuc = [self createZipAt:langPatchZipFilePath file:langPatchFilePath];
        if (!langPatchFileSuc) {
            SPLog(@"补丁文件出错。中断。");
            return NO;
        }
        
        // step: 5
        // 更新版本号
        {
            SPLog(@"更新语言版本号:");
            SPLog(@"主语言文件版本不变：%lld",mainVersion);
            SPLog(@"更新语言补丁版本：%lld",patchVersion);
            [self.state setPatchVersion:patchVersion lang:lang];
        }
    }
    
    SPLog(@"语言数据处理完成！");
    return YES;
}

- (NSDictionary *)loadLocalDataWithLang:(NSString *)lang
{
    //从三种文件获取本地化
    // 1 /Applications/SteamLibrary/SteamApps/common/dota 2 beta/game/dota/panorama/localization/dota_%@.txt
    // 2 /Applications/SteamLibrary/SteamApps/common/dota 2 beta/game/dota/resource/dota_%@.txt
    // 3 /Applications/SteamLibrary/SteamApps/common/dota 2 beta/game/dota/resource/items_%@.txt
    
    SPLog(@"开始生成本地化映射：语言：%@",lang);
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    {
        //file 1
        NSString *filePath = [SPDota2PathManager dotaLangFile1:lang];
        SPLog(@"文件1：%@",filePath);
        if (![fm fileExistsAtPath:filePath]) {
            SPLog(@"找不到文件路径：%@",filePath);
            return nil;
        }
        
        NSError *error;
        NSString *txt = [NSString stringWithContentsOfFile:filePath encoding:NSUTF16LittleEndianStringEncoding error:&error];
        if (error || txt.length == 0) {
            SPLog(@"读取文件出错：%@",error);
            return nil;
        }

        NSData *data = [txt dataUsingEncoding:NSUTF8StringEncoding];
        VDFNode *root = [VDFParser parse:data];
        VDFNode *dota = [root firstChildWithKey:@"dota"];
        NSDictionary *tokens = [dota datasDict];
        [dict addEntriesFromDictionary:tokens];
        SPLog(@"文件1找到 %d 条数据",(int)tokens.count);
        [dict addEntriesFromDictionary:tokens];
    }
    
    {
        // file 2
        NSString *filePath = [SPDota2PathManager dotaLangFile2:lang];
        SPLog(@"文件2：%@",filePath);
        if (![fm fileExistsAtPath:filePath]) {
            SPLog(@"找不到文件路径：%@",filePath);
            return nil;
        }
        
        NSError *error;
        NSString *txt = [NSString stringWithContentsOfFile:filePath encoding:NSUTF16LittleEndianStringEncoding error:&error];
        if (error || txt.length == 0) {
            SPLog(@"读取文件出错：%@",error);
            return nil;
        }
        
        NSData *data = [txt dataUsingEncoding:NSUTF8StringEncoding];
        VDFNode *root = [VDFParser parse:data];
        VDFNode *lang = [root firstChildWithKey:@"lang"];
        VDFNode *Tokens = [lang firstChildWithKey:@"Tokens"];
        NSDictionary *tokens = [Tokens datasDict];
        SPLog(@"文件2找到 %d 条数据",(int)tokens.count);
        [dict addEntriesFromDictionary:tokens];
    }
    
    {
        // file 3
        NSString *filePath = [SPDota2PathManager dotaLangFile3:lang];;
        SPLog(@"文件3：%@",filePath);
        if (![fm fileExistsAtPath:filePath]) {
            SPLog(@"找不到文件路径：%@",filePath);
            return nil;
        }
        
        NSError *error;
        NSString *txt = [NSString stringWithContentsOfFile:filePath encoding:NSUTF16LittleEndianStringEncoding error:&error];
        if (error || txt.length == 0) {
            SPLog(@"读取文件出错：%@",error);
            return nil;
        }
        
        NSData *data = [txt dataUsingEncoding:NSUTF8StringEncoding];
        VDFNode *root = [VDFParser parse:data];
        VDFNode *lang = [root firstChildWithKey:@"lang"];
        VDFNode *Tokens = [lang firstChildWithKey:@"Tokens"];
        NSDictionary *tokens = [Tokens datasDict];
        SPLog(@"文件3找到 %d 条数据",(int)tokens.count);
        [dict addEntriesFromDictionary:tokens];
    }
    
    SPLog(@"创建本地化映射成功，共 %d 条数据",(int)dict.count);
    return dict;
}

- (BOOL)createZipAt:(NSString *)zipPath file:(NSString *)filePath
{
    SPLog(@"准备压缩文件：%@",filePath.lastPathComponent);
    if (![FileManager fileExistsAtPath:filePath]) {
        SPLog(@"文件不存在！");
        return NO;
    }

    [FileManager removeItemAtPath:zipPath error:nil];
    BOOL suc = [SSZipArchive createZipFileAtPath:zipPath withFilesAtPaths:@[filePath] withPassword:pwd];
    if (!suc) {
        SPLog(@"压缩失败！");
        return NO;
    }
    SPLog(@"创建压缩包完成");
    return YES;
}

@end

NSString *const kSPLanguageSchinese = @"schinese";
NSString *const kSPLanguageEnglish = @"english";
