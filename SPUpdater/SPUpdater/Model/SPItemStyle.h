//
//  SPItemStyle.h
//  ShiPing
//
//  Created by wwwbbat on 2017/7/21.
//  Copyright © 2017年 wwwbbat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPItemStyleUnlock;

@interface SPItemStyle : NSObject <NSCoding,NSCopying>

// 序号 0
@property (copy, nonatomic) NSString *index;
// 款式的名称token。可能为空             #wyvern_hatchling_upgrade_style_02
@property (copy, nonatomic) NSString *name;
// 款式的本地化名称。             烈火
@property (copy, nonatomic) NSString *name_loc;
// 款式的本地化标题。可能不存在.  示例：dota_item_wyvern_hatchling_upgrade_style_02 本地化后 小飞龙升级款式 02
@property (copy, nonatomic) NSString *title_loc;
// 解锁方式。可能为空
@property (strong, nonatomic) SPItemStyleUnlock *unlock;

+ (instancetype)styleOfInfo:(NSDictionary *)info index:(NSString *)index;

@end

@interface SPItemStyleUnlock : NSObject <NSCoding,NSCopying>

// 需要解锁工具的工具token
@property (copy, nonatomic) NSString *item_def;

// 需要宝石解锁的
@property (copy, nonatomic) NSString *def_index;
@property (copy, nonatomic) NSString *type_field;
@property (copy, nonatomic) NSString *type_value;
@property (copy, nonatomic) NSString *unlock_field;
@property (copy, nonatomic) NSString *unlock_value;
@end
