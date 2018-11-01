//
//  SPItemColor.h
//  ShiPing
//
//  Created by wwwbbat on 16/4/14.
//  Copyright © 2016年 wwwbbat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDFNode;

@interface SPItemColor : NSObject

// desc_legendary
@property (strong, nonatomic) NSString *name;
// ItemRarityLegendary
@property (strong, nonatomic) NSString *color_name;
// #d32ce6
@property (strong, nonatomic) NSString *hex_color;

+ (instancetype)named:(NSString *)name info:(NSDictionary *)info;
+ (NSArray<SPItemColor *> *)colorsFromArray:(NSArray<VDFNode *> *)array;

@end
