//
//  SPItemRarity.m
//  ShiPing
//
//  Created by wwwbbat on 16/4/14.
//  Copyright © 2016年 wwwbbat. All rights reserved.
//

#import "SPItemRarity.h"
#import "VDFNode.h"

@implementation SPItemRarity

+ (instancetype)rarityNamed:(NSString *)name info:(NSDictionary *)info
{
    if (!name || !info) return nil;
    
    SPItemRarity *rarity = [SPItemRarity new];
    rarity.name = name;
    rarity.loc_key = info[@"loc_key"];
    rarity.value = info[@"value"];
    rarity.color = info[@"color"];
    return rarity;
}

+ (NSArray<SPItemRarity *> *)raritiesWithArray:(NSArray<VDFNode *> *)array
{
    NSMutableArray *tmp = [NSMutableArray array];
    for (VDFNode *aNode in array) {
        SPItemRarity *rarity = [SPItemRarity rarityNamed:aNode.k info:[aNode datasDict]];
        if (rarity) {
            [tmp addObject:rarity];
        }
    }
    return tmp;
}

@end
