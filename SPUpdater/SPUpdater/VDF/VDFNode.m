//
//  VDFNode.m
//  ShiPing
//
//  Created by wwwbbat on 2017/8/6.
//  Copyright © 2017年 wwwbbat. All rights reserved.
//

#import "VDFNode.h"

@implementation VDFNode

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.datas = [NSMutableArray array];
        self.children = [NSMutableArray array];
    }
    return self;
}

- (NSDictionary *)dict
{
    if (self.v) {
        return @{self.k:self.v};
    }
    return @{};
}

- (NSMutableDictionary *)datasDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (VDFNode *aNode in self.datas) {
        dict[aNode.k] = aNode.v;
    }
    return dict;
}

- (NSMutableDictionary *)childrenDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (VDFNode *aNode in self.children) {
        dict[aNode.k] = [aNode allDict];
    }
    return dict;
}

- (NSMutableDictionary *)allDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.dict];
    [dict addEntriesFromDictionary:[self datasDict]];
    [dict addEntriesFromDictionary:[self childrenDict]];
    return dict;
}

- (VDFNode *)firstChildWithKey:(NSString *)k
{
    if (!k) return nil;
    
    for (VDFNode *aNode in self.children) {
        if ([aNode.k isEqualToString:k]) {
            return aNode;
        }
    }
    return nil;
}

- (NSArray *)childrenWithKey:(NSString *)k
{
    if (!k) return nil;
    
    NSMutableArray *array = [NSMutableArray array];
    for (VDFNode *aNode in self.children) {
        if ([aNode.k isEqualToString:k]) {
            [array addObject:aNode];
        }
    }
    return array;
}

@end
