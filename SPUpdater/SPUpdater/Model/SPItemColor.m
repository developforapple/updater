//
//  SPItemColor.m
//  ShiPing
//
//  Created by wwwbbat on 16/4/14.
//  Copyright © 2016年 wwwbbat. All rights reserved.
//

#import "SPItemColor.h"
#import "VDFNode.h"

@implementation SPItemColor

+ (instancetype)named:(NSString *)name info:(NSDictionary *)info
{
    if (!name || !info) return nil;
    
    SPItemColor *instance = [SPItemColor new];
    instance.name = name;
    instance.color_name = info[@"color_name"];
    instance.hex_color = info[@"hex_color"];
    return instance;
}

+ (NSArray<SPItemColor *> *)colorsFromArray:(NSArray<VDFNode *> *)array
{
    NSMutableArray *tmp = [NSMutableArray array];
    for (VDFNode *aNode in array) {
        SPItemColor *color = [SPItemColor named:aNode.k info:[aNode datasDict]];
        if (color) {
            [tmp addObject:color];
        }
    }
    return tmp;
}

@end
