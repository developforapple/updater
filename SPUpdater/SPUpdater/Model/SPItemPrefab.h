//
//  SPItemPrefab.h
//  ShiPing
//
//  Created by wwwbbat on 16/4/14.
//  Copyright © 2016年 wwwbbat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPItemPrefab : NSObject

// courier
@property (copy, nonatomic) NSString *name;
// #DOTA_WearableType_Courier 需要本地化时，以这个为准
@property (copy, nonatomic) NSString *item_type_name;
// #DOTA_Wearable_Courier。没啥用
@property (copy, nonatomic) NSString *item_name;
// courier    没有时为 "none"
@property (copy, nullable, nonatomic) NSString *item_slot;
// 1   没有时为nil
@property (copy, nullable, nonatomic) NSString *player_loadout;

+ (instancetype)named:(NSString *)name info:(NSDictionary *)info;
+ (NSArray<SPItemPrefab *> *)prefabsWithArray:(NSArray<VDFNode *> *)array;

@end

NS_ASSUME_NONNULL_END
