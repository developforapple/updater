//
//  SPItemSets.m
//  ShiPing
//
//  Created by wwwbbat on 16/4/14.
//  Copyright © 2016年 wwwbbat. All rights reserved.
//

#import "SPItemSets.h"
#import "VDFNode.h"

@implementation SPItemSets

+ (instancetype)named:(NSString *)name info:(VDFNode *)info
{
    if (!name || !info) return nil;
    
    NSDictionary *infoDict = [info datasDict];
    
    SPItemSets *instance = [SPItemSets new];
    instance.token = name;
    instance.name = infoDict[@"name"];
    instance.store_bundle = infoDict[@"store_bundle"];
    
    NSDictionary *itemsNode = [[info firstChildWithKey:@"items"] datasDict];
    instance.items = [itemsNode allKeys];

    return instance;
}

+ (NSArray<SPItemSets *> *)itemSets:(NSArray<VDFNode *> *)array
{
    NSMutableArray *tmp = [NSMutableArray array];
    for (VDFNode *aNode in array) {
        SPItemSets *instance = [SPItemSets named:aNode.k info:aNode];
        if (instance) {
            [tmp addObject:instance];
        }
    }
    return tmp;
}

@end
