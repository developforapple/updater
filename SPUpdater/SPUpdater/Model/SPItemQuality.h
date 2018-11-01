//
//  SPItemQuality.h
//  ShiPing
//
//  Created by wwwbbat on 16/4/14.
//  Copyright © 2016年 wwwbbat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDFNode;

/*
 developer,     Valve
 tournament,    英雄传世
 haunted,       凶煞
 completed,     完整
 autographed,   亲笔签名
 base,          基础
 genuine,       纯正
 frozen,        冻人
 customized,    自定义
 selfmade,      自制
 legacy,        绝版
 favored,       青睐
 lucky,         吉祥
 exalted,       尊享
 community,     社区
 infused,       融合
 vintage,       上古
 strange,       铭刻
 unique,        标准
 corrupted,     冥灵
 ascendant,     传奇
 unusual        独特
 */

@interface SPItemQuality : NSObject
// genuine
@property (copy, nonatomic) NSString *name;
// 1
@property (copy, nonatomic) NSString *value;
// #4D7455
@property (copy, nonatomic) NSString *hexColor;
// 20
@property (copy, nonatomic) NSString *sortPriority;
// #genuine
@property (copy, nonatomic) NSString *displayName;

+ (instancetype)qualityNamed:(NSString *)name info:(NSDictionary *)info;

+ (NSArray<SPItemQuality *> *)qualitiesWithArray:(NSArray<VDFNode *> *)array;


@end
