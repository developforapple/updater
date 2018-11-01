//
//  SPItemSets.h
//  ShiPing
//
//  Created by wwwbbat on 16/4/14.
//  Copyright © 2016年 wwwbbat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFNode.h"

@interface SPItemSets : NSObject

// key
@property (copy, nonatomic) NSString *token;  //"abaddon_anointed_ruination"

// data
@property (copy, nonatomic) NSString *name;   //"#DOTA_Set_Anointed_Armor_of_Ruination"
@property (copy, nonatomic) NSString *store_bundle; //"Anointed Armor of Ruination"

// child

/*
 {
 "armor of the narcissistic leech" = 1;
 "belt of the narcissistic leech" = 1;
 "cape of the narcissistic leech" = 1;
 "scepter of the narcissistic leech" = 1;
 "skull of the narcissistic leech" = 1;
 "sleeves of the narcissistic leech" = 1;
 }
 */
@property (strong, nonatomic) NSArray<NSString *> *items;

+ (instancetype)named:(NSString *)name info:(VDFNode *)info;
+ (NSArray<SPItemSets *> *)itemSets:(NSArray<VDFNode *> *)array;

@end
