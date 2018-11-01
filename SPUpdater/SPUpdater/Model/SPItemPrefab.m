//
//  SPItemPrefab.m
//  ShiPing
//
//  Created by wwwbbat on 16/4/14.
//  Copyright © 2016年 wwwbbat. All rights reserved.
//

#import "SPItemPrefab.h"

@implementation SPItemPrefab

+ (instancetype)named:(NSString *)name info:(NSDictionary *)info
{
    if (!name || !info) return nil;
    
    SPItemPrefab *instance = [SPItemPrefab new];
    instance.name = name;
    instance.item_type_name = info[@"item_type_name"];
    instance.item_name = info[@"item_name"];
    instance.item_slot = info[@"item_slot"];
    instance.player_loadout = info[@"player_loadout"];
    return instance;
}

+ (NSArray<SPItemPrefab *> *)prefabsWithArray:(NSArray<VDFNode *> *)array
{
    NSMutableArray *tmp = [NSMutableArray array];
    for (VDFNode *aNode in array) {
        SPItemPrefab *instance = [SPItemPrefab named:aNode.k info:[aNode datasDict]];
        if (instance) {
            [tmp addObject:instance];
        }
    }
    return tmp;
}

@end
