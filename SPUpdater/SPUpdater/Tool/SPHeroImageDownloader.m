//
//  SPHeroImageDownloader.m
//  ShiPing
//
//  Created by wwwbbat on 2017/7/18.
//  Copyright © 2017年 wwwbbat. All rights reserved.
//

#import "SPHeroImageDownloader.h"
#import "SPPathManager.h"
#import "SPLogHelper.h"

@implementation SPHeroImageDownloader

+ (NSString *)heroPath
{
    NSString *path = [[SPPathManager imageDir] stringByAppendingPathComponent:@"hero"];
    [SPPathManager createFolderIfNeed:path];
    return path;
}

+ (void)downloadImages
{
    NSString *folder = [self heroPath];
    NSString *dataPath = [[SPArchivePathManager baseDataFilePath] stringByAppendingPathComponent:@"data.json"];
    
    NSData *data = [NSData dataWithContentsOfFile:dataPath];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSArray *heroes = dict[@"heroes"];
    
    SPLog(@"%d",heroes.count);
    
    NSInteger i = 0;
    
    for (NSDictionary *aHero in heroes) {
        NSString *name = aHero[@"name"];
        NSRange range = [name rangeOfString:@"npc_dota_hero_"];
        if (range.location != NSNotFound) {
            NSString *heroName = [name substringFromIndex:range.location + range.length];
            
            
            // full image
            {
                NSString *url = [NSString stringWithFormat:@"http://cdn.dota2.com/apps/dota2/images/heroes/%@_full.png",heroName];
                NSError *error;
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url] options:nil error:&error];
                
                
                
                NSString *filePath = [folder stringByAppendingPathComponent:name];
                [data writeToFile:filePath atomically:YES];
                if (error) {
                    SPLog(@"%@, error:%@",name,error);
                }
                SPLog(@"%d / %d",++i,heroes.count);
            }
        
            // vert image
            {
                NSString *url = [NSString stringWithFormat:@"http://cdn.dota2.com/apps/dota2/images/heroes/%@_vert.jpg",heroName];
                NSError *error;
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url] options:nil error:&error];
                NSString *filePath = [folder stringByAppendingPathComponent:[name stringByAppendingString:@"_vert"]];
                [data writeToFile:filePath atomically:YES];
                if (error) {
                    SPLog(@"%@, error:%@",name,error);
                }
                SPLog(@"%d / %d",++i,heroes.count);
            }
            
            // icon
            {
                NSString *url = [NSString stringWithFormat:@"http://www.dota2.com.cn/images/heroes/%@_icon.png",heroName];
                NSError *error;
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url] options:nil error:&error];
                NSString *filePath = [folder stringByAppendingPathComponent:[name stringByAppendingString:@"_icon"]];
                [data writeToFile:filePath atomically:YES];
                if (error) {
                    SPLog(@"%@, error:%@",name,error);
                }
                SPLog(@"%d / %d",++i,heroes.count);
            }
        }
    }
    
    SPLog(@"done");
}

@end
