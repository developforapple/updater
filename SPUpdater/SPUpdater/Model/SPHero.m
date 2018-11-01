//
//  SPHero.m
//  ShiPing
//
//  Created by wwwbbat on 16/5/7.
//  Copyright © 2016年 wwwbbat. All rights reserved.
//

#import "SPHero.h"
#import "VDFNode.h"
#import "SPItemSlot.h"
#import <YYModel.h>

@interface SPHero() <YYModel>

@end

@implementation SPHero

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass
{
    return @{@"slot":[SPItemSlot class]};
}

+ (instancetype)hero:(NSString *)name Node:(VDFNode *)node
{
    if (!name || !node) return nil;
    
    SPHero *hero = [SPHero new];
    hero.name = name;
    
    NSDictionary *data = [node datasDict];
    hero.HeroID = data[@"heroid"];
    hero.Team = data[@"team"];
    hero.HeroGlowColor = data[@"heroglowcolor"];
    hero.NameAliases = data[@"namealiases"];
    hero.workshop_guide_name = data[@"workshop_guide_name"];
    hero.AttributePrimary = data[@"attributeprimary"];
    
    
    NSArray<VDFNode *> *ItemSlots = [node firstChildWithKey:@"ItemSlots"].children;
    NSMutableArray *slots = [NSMutableArray array];
    for (VDFNode *aNode in ItemSlots) {
        SPItemSlot *slot = [SPItemSlot slotWithNode:aNode];
        if (slot && ![slot.SlotName isEqualToString:@"ambient_effects"]) {
            [slots addObject:slot];
        }
    }
    hero.ItemSlots = slots;
    
    return hero;
}

@end
