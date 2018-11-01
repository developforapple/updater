//
//  SPLootList.m
//  ShiPing
//
//  Created by wwwbbat on 2017/8/6.
//  Copyright © 2017年 wwwbbat. All rights reserved.
//

#import "SPLootList.h"

@implementation SPLootList

+ (instancetype)lootListNamed:(NSString *)token info:(VDFNode *)node
{
    if (!token || !node || ![node isKindOfClass:[VDFNode class]]) return nil;
    
    SPLootList *instance = [SPLootList new];
    instance.token = token;
    
    NSArray *items = [node datasDict].allKeys;
    instance.lootList = items;
    
    NSMutableArray *add = [NSMutableArray array];
    for (VDFNode *aNode in node.children) {
        
        NSDictionary *dict = [aNode datasDict];
        NSString *addItem = dict[@"item"];
        NSString *addLootlist = dict[@"loot_list"];
        
        if (addItem) {
            [add addObject:addItem];
        }
        if (addLootlist) {
            [add addObject:addLootlist];
        }
    }
    instance.additional = add;
    
    return instance;
}

+ (NSArray<SPLootList *> *)lootList:(NSArray<VDFNode *> *)array
{
    NSMutableArray *tmp = [NSMutableArray array];
    for (VDFNode *aNode in array) {
        SPLootList *lootlist = [SPLootList lootListNamed:aNode.k info:aNode];
        if (lootlist) {
            [tmp addObject:lootlist];
        }
    }
    return tmp;
}

@end
