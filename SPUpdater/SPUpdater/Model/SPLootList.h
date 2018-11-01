//
//  SPLootList.h
//  ShiPing
//
//  Created by wwwbbat on 2017/8/6.
//  Copyright © 2017年 wwwbbat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFNode.h"

@interface SPLootList : NSObject

@property (copy, nonatomic) NSString *token;
@property (strong, nonatomic) NSArray<NSString *> *lootList;           //固定掉落 可能是饰品也可能是其他掉落列表
@property (strong, nonatomic) NSArray<NSString *> *additional;    //额外掉落

+ (instancetype)lootListNamed:(NSString *)token info:(VDFNode *)node;
+ (NSArray<SPLootList *> *)lootList:(NSArray<VDFNode *> *)array;

@end
