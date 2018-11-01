//
//  SPLocalMapping.h
//  ShiPing
//
//  Created by wwwbbat on 16/4/13.
//  Copyright © 2016年 wwwbbat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPUpdaterState.h"

extern const long long kMagicNumber ;

// Dota2 游戏目录下的本地化数据

@interface SPLocalMapping : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)init:(SPUpdaterState *)state
                lang:(NSString *)lang;

@property (strong) NSMutableDictionary<NSString *,NSDictionary *> *langDict;

// 做的事情：
// 1：从游戏目录中提取指定语言的全部本地化文件
// 2：如果主文件不存在，创建主文件，创建空补丁文件
// 3：如果主文件存在，比较差异，创建补丁文件
- (BOOL)update;

@end


FOUNDATION_EXTERN NSString *const kSPLanguageSchinese;  //简体中文
FOUNDATION_EXTERN NSString *const kSPLanguageEnglish;   //英文
