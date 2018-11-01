//
//  SPItemQuality.m
//  ShiPing
//
//  Created by wwwbbat on 16/4/14.
//  Copyright © 2016年 wwwbbat. All rights reserved.
//

#import "SPItemQuality.h"
#import "VDFNode.h"

@implementation SPItemQuality

+ (instancetype)qualityNamed:(NSString *)name info:(NSDictionary *)info
{
    if (!name || !info) return nil;
    
    SPItemQuality *quality = [SPItemQuality new];
    quality.name = name;
    quality.hexColor = info[@"hexcolor"];
    quality.value = info[@"value"];
    quality.sortPriority = info[@"sortpriority"];
    quality.displayName = info[@"displayname"];
    return quality;
}

+ (NSArray<SPItemQuality *> *)qualitiesWithArray:(NSArray<VDFNode *> *)array
{
    NSMutableArray *tmp = [NSMutableArray array];
    for (VDFNode *aNode in array) {
        SPItemQuality *rarity = [SPItemQuality qualityNamed:aNode.k info:[aNode datasDict]];
        if (rarity) {
            [tmp addObject:rarity];
        }
    }
    return tmp;
}

@end
