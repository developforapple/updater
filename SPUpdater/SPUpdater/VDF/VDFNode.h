//
//  VDFNode.h
//  ShiPing
//
//  Created by wwwbbat on 2017/8/6.
//  Copyright © 2017年 wwwbbat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VDFNode : NSObject

@property (copy, nonatomic) NSString *k;
@property (copy, nullable, nonatomic) NSString *v;

@property (strong, nonatomic) NSMutableArray<VDFNode *> *datas;
@property (strong, nonatomic) NSMutableArray<VDFNode *> *children;

@property (weak, nullable, nonatomic) VDFNode *parent;

// 数组中k重复的部分将被抛弃
- (NSDictionary *)dict;
- (NSMutableDictionary *)datasDict;
- (NSMutableDictionary *)childrenDict;
- (NSMutableDictionary *)allDict;

- (VDFNode *)firstChildWithKey:(NSString *)k;
- (NSArray *)childrenWithKey:(NSString *)k;

@end

NS_ASSUME_NONNULL_END
