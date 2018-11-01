//
//  SPHero.h
//  ShiPing
//
//  Created by wwwbbat on 16/5/7.
//  Copyright © 2016年 wwwbbat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPItemSlot;
@class VDFNode;

NS_ASSUME_NONNULL_BEGIN

@interface SPHero : NSObject

// 旧
@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSNumber *position;
@property (strong, nonatomic) NSNumber *type;
@property (strong, nonatomic) NSNumber *subType;




// 新

// npc_dota_hero_earthshaker
@property (strong, nonatomic) NSString *name;
// 1
@property (copy, nonatomic) NSString *HeroID;
// 阵营，分为 Good 和 Bad
@property (copy, nonatomic) NSString *Team;
// 颜色。"120 64 148"
@property (copy, nullable, nonatomic) NSString *HeroGlowColor;
// 别名。逗号分隔。
@property (copy, nullable, nonatomic) NSString *NameAliases;
//
@property (copy, nullable, nonatomic) NSString *workshop_guide_name;

// 主属性：DOTA_ATTRIBUTE_AGILITY
@property (copy, nonatomic) NSString *AttributePrimary;
//@property (assign, nonatomic) float AttributeBaseStrength;
//@property (assign, nonatomic) float AttributeStrengthGain;
//@property (assign, nonatomic) float AttributeBaseIntelligence;
//@property (assign, nonatomic) float AttributeIntelligenceGain;
//@property (assign, nonatomic) float AttributeBaseAgility;
//@property (assign, nonatomic) float AttributeAgilityGain;

// 基础移动速度
//@property (assign, nonatomic) float MovementSpeed;
//// 基础转身速率
//@property (assign, nonatomic) float MovementTurnRate;

// 饰品部位
@property (strong, nonatomic) NSArray<SPItemSlot *> *ItemSlots;

+ (nullable instancetype)hero:(NSString *)name Node:(VDFNode *)node;

@end

NS_ASSUME_NONNULL_END
