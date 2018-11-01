//
//  SPItemSlot.h
//  ShiPing
//
//  Created by wwwbbat on 16/4/15.
//  Copyright © 2016年 wwwbbat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDFNode;

@interface SPItemSlot : NSObject

// 2
@property (assign, nonatomic) int SlotIndex;
// armor
@property (copy, nonatomic) NSString *SlotName;
// #LoadoutSlot_Armor
@property (copy, nonatomic) NSString *SlotText;

// 英雄的槽位
+ (instancetype)slotWithNode:(VDFNode *)node;
// 用户的槽位
+ (instancetype)loadoutSlot:(VDFNode *)node;
//
+ (NSArray *)loadoutSlots:(VDFNode *)node;

@end
