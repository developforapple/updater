//
//  SPItemImageDownloader.m
//  ShiPing
//
//  Created by wwwbbat on 2017/7/17.
//  Copyright © 2017年 wwwbbat. All rights reserved.
//

#import "SPItemImageDownloader.h"
#import <FMDatabase.h>
#import "SPLogHelper.h"
@import AppKit;
#import "SPPathManager.h"

NSMutableSet<NSString *> *_doneItems;

NSData *UIImageJPEGRepresentation(NSImage *image,float quality){
    NSData *data = [image TIFFRepresentation];
    NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:data];
    [rep setSize:image.size];
    NSData *jpegData = [rep representationUsingType:NSJPEGFileType properties:@{NSImageCompressionFactor:@(0.85)}];
    return jpegData;
}

#define FileManager [NSFileManager defaultManager]

static NSString *getQiniuName(NSString *inventory){
    return [NSString stringWithFormat:@"%lu",(unsigned long)[[inventory stringByAppendingString:@"_0123456789"] hash]];
}

@implementation SPItemImageDownloader

+ (NSString *)doneFilePath
{
    return [[SPPathManager imageDir] stringByAppendingPathComponent:@"LargeDone"];
}

+ (NSMutableSet *)downloadedItems
{
    if (!_doneItems) {
        _doneItems = [NSMutableSet setWithArray:[NSArray arrayWithContentsOfFile:[self doneFilePath]]];
    }
    return _doneItems;
}

+ (void)saveDownloadedItems
{
    NSArray *array = [_doneItems objectEnumerator].allObjects;
    [[NSFileManager defaultManager] removeItemAtPath:[self doneFilePath] error:nil];
    [array writeToFile:[self doneFilePath] atomically:YES];
}

+ (BOOL)isItemDownloaded:(NSString *)token
{
    return [[self downloadedItems] containsObject:token];
}

+ (void)setItemDownloaded:(NSString *)token
{
    [[self downloadedItems] addObject:token];
}

+ (NSString *)normalPath
{
    NSString *path = [[SPPathManager imageDir] stringByAppendingPathComponent:@"normal"];
    [SPPathManager createFolderIfNeed:path];
    return path;
}

+ (NSString *)largePath
{
    NSString *path = [[SPPathManager imageDir] stringByAppendingPathComponent:@"large"];
    [SPPathManager createFolderIfNeed:path];
    return path;
}

+ (NSDictionary *)itemImageMapFromDB:(NSString *)dbPath
{
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    
    FMResultSet *result = [db executeQuery:@"SELECT token,image_inventory FROM items"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    while ([result next]) {
        NSString *token = [result stringForColumn:@"token"];
        NSString *image_inventory = [result stringForColumn:@"image_inventory"];
        dict[token] = image_inventory;
    }
    [db close];
    return dict;
}

+ (NSDictionary *)itemsImageMapFromArray:(NSArray *)items
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSDictionary *aItemDict in items) {
        NSString *token = aItemDict[@"token"];
        NSString *image_inventory = aItemDict[@"image_inventory"];
        dict[token] = image_inventory;
    }
    return dict;
}

+ (void)compressImages
{
    NSString *imageFolder = [self largePath];
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:imageFolder];
    
    long long pre = 0;
    long long cur = 0;
    
    for (NSString *aFile in files) {
        
        if ([aFile isEqualToString:@".DS_Store"]) {
            continue;
        }
        
        BOOL directory = NO;
        NSString *path = [imageFolder stringByAppendingPathComponent:aFile];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&directory] && !directory) {
            
            NSNumber *size = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil][NSFileSize];
            long preSize = size.longValue;
            
            NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];
            NSData *data = UIImageJPEGRepresentation(image, 0.90);
            
            long curSize = data.length;
            
            SPLog(@"原始大小: %d kb",(int)preSize/1024);
            SPLog(@"压缩后大小：%d kb",(int)curSize/1024);
            SPLog(@"压缩率：%.1f%%",curSize/(float)preSize*100);
            
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            [data writeToFile:path atomically:YES];
            
            pre += preSize;
            cur += curSize;
        }
    }
    
    SPLog(@"压缩前：%d Mb", (int)pre / 1024 / 1024);
    SPLog(@"压缩后：%d Mb", (int)cur / 1024 / 1024);
    SPLog(@"总压缩率： %.1f %%",cur/(double)pre * 100);
    
    SPLog(@"Done");
}

+ (void)downloadAllItems:(NSString *)dbPath
{
    SPLog(@"下载图片！");
    
    SPLog(@"读取数据库");
    NSDictionary *map = [self itemImageMapFromDB:dbPath];
    SPLog(@"共找到 %d 个饰品",(int)map.count);
    
    [self downloadItemsMap:map];
}

+ (void)downloadItemsMap:(NSDictionary *)map
{
    NSArray *allKeys = [map allKeys];
    
    NSMutableSet *done = [NSMutableSet set];
    NSMutableArray *needDownloadTokens = [NSMutableArray array];
    for (NSString *token in allKeys) {
        
        NSString *name = getQiniuName(map[token]);
        NSString *path = [[self largePath] stringByAppendingPathComponent:name];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            
            [done addObject:token];
            
        }else{
            [needDownloadTokens addObject:token];
        }
    }
    
    _doneItems = done;
    [self saveDownloadedItems];
    
    NSArray *needDownloadImages = [map objectsForKeys:needDownloadTokens notFoundMarker:@""];
    NSDictionary *needDownloadItems = [NSDictionary dictionaryWithObjects:needDownloadImages forKeys:needDownloadTokens];
    
    SPLog(@"有 %d 个饰品的图片需要下载",(int)needDownloadItems.count);
    
    if (needDownloadImages.count > 400) {
        //超过200个 需要开多个线程
        
        // todo
        
    }else{
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self downloadThread:needDownloadItems identifier:@"?-?"];
            [self saveDownloadedItems];
            
            
            NSTask *task = [[NSTask alloc] init];
            [task setLaunchPath:@"/bin/bash"];
            
            NSString *qshellPath = [[SPPathManager imageDir] stringByAppendingPathComponent:@"qshell"];
            NSString *confPath = [[SPPathManager imageDir] stringByAppendingPathComponent:@"upload_conf.txt"];
            
            NSString *conf =  @ "{\"bucket\"            :\"items-3-0\","
                                "\"ignore_dir\"         :true,"
                                "\"overwrite\"          :false,"
                                "\"check_exists\"       :false,"
                                "\"check_hash\"         :false,"
                                "\"check_size\"         :false,"
                                "\"rescan_local\"       :true,"
                                "\"log_level\"          :\"info\","
                                "\"log_rotate\"         :1,"
                                "\"log_stdout\"         :true,"
                                "\"file_type\"          :0,";
            
            
            conf = [conf stringByAppendingFormat:@"\"src_dir\":\"%@\",",[[SPPathManager imageDir] stringByAppendingPathComponent:@"large"]];
            conf = [conf stringByAppendingFormat:@"\"log_file\":\"%@\"}",[[SPPathManager imageDir] stringByAppendingPathComponent:@"upload.log"]];
            
            [[NSFileManager defaultManager] removeItemAtPath:confPath error:nil];
            NSData *confData = [conf dataUsingEncoding:NSUTF8StringEncoding];
            [confData writeToFile:confPath atomically:YES];
            
            NSString *cmd1 = [NSString stringWithFormat:@"%@ account xpvGiKMcLq9n992yJs-qXf5vZMMTrF28DQ0uxVC6 -ockoOWZiZn3kcUwKmXn__Xvxe1ks67xdjApl4vP",qshellPath];
            NSString *cmd2 = [NSString stringWithFormat:@"%@ qupload 4 %@",qshellPath,confPath];
            
            NSString *cmd = [@[cmd1,cmd2] componentsJoinedByString:@";"];
            
            NSArray *arguments = @[@"-c",cmd];
            [task setArguments:arguments];
            
            NSPipe *pipe = [NSPipe pipe];
            [task setStandardOutput:pipe];
            
            NSFileHandle *file = [pipe fileHandleForReading];
            [task launch];
            
            NSData *data = [file readDataToEndOfFile];
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"");
        });
    }
}

+ (void)downloadThread:(NSDictionary *)map identifier:(NSString *)identifier
{
    NSString *largeFolder = [self largePath];
    [SPPathManager createFolderIfNeed:largeFolder];
    
    int i = 0;
    
    for (NSString *token in map) {
        
        NSString *imageInventory = map[token];
        NSString *qiniuName = getQiniuName(imageInventory);
        NSString *name = [[imageInventory lastPathComponent] lowercaseString];
        NSString *largePath = [largeFolder stringByAppendingPathComponent:qiniuName];
    
        if ([[NSFileManager defaultManager] fileExistsAtPath:largePath]) {
            
            [self setItemDownloaded:token];
            
            continue;
        }
        
        int largeDownloadResult = [self downloadImageNamed:name type:1 toPath:largePath];

        if (largeDownloadResult) {
            
            [self setItemDownloaded:token];

            SPLog(@"\t%@ ： %d / %d",identifier,i,(int)map.count);
            
            i++;
        }
    }
    SPLog(@"\t%@结束，还有 %d 个大图未完成",identifier,(int)(map.count-i));
}


/**
 下载图片

 @param name 图片名
 @param type 0小图 1大图 2ingame
 @param path 保存位置
 @return 0：错误 1：成功 2：不需要下载
 */
+ (int)downloadImageNamed:(NSString *)name type:(int)type toPath:(NSString *)path
{
    if (name.length == 0) {
        return 2;
    }
    
    NSString *imageURL;
    
    // 获取图片链接
    {
        NSString *key = arc4random_uniform(10)%2==0?@"CD9010FD71FA1583192F9BDB87ED8164":@"D46675A241E560655ABD306C2A275D60";
        NSString *URL = [@"https://api.steampowered.com/IEconDOTA2_570/GetItemIconPath/v1?" stringByAppendingFormat:@"key=%@&iconname=%@&icontype=%d",key,name,type];
        NSError *error;
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:URL] options:NSDataReadingUncached error:&error];
        if (error || !data) {
            if (type == 1) {
                // 大图没找到，下载小图
                [self downloadImageNamed:name type:0 toPath:path];
                return 0;
            }
            SPLog(@"data出错了！%@",error);
            return 0;
        }
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (error) {
            if (type == 1) {
                // 大图没找到，下载小图
                [self downloadImageNamed:name type:0 toPath:path];
                return 0;
            }
            SPLog(@"dict出错了！");
            return 0;
        }
        NSString *imageRemotePath = dict[@"result"][@"path"];
        if (imageRemotePath.length == 0) {
            if (type == 1) {
                // 大图没找到，下载小图
                [self downloadImageNamed:name type:0 toPath:path];
                return 0;
            }
            return 0;
        }
        
        imageURL = [@"http://cdn.dota2.com/apps/570/" stringByAppendingString:imageRemotePath];
    }
    
    // 下载图片
    {
        NSError *error;
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL] options:NSDataReadingUncached error:&error];
        if (error || !data) {
            SPLog(@"下载图片出错了！%@",error);
            return 0;
        }
        [FileManager removeItemAtPath:path error:nil];
        
        NSImage *image = [[NSImage alloc] initWithData:data];
        NSData *jpegData = UIImageJPEGRepresentation(image, 0.90);
        [jpegData writeToFile:path atomically:YES];
    }
    return 1;
}

+ (void)downloadItems:(NSArray *)items
{
    NSDictionary *map = [self itemsImageMapFromArray:items];
    [self downloadItemsMap:map];
}

@end
