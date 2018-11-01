//
//  SPItemSlot.m
//  ShiPing
//
//  Created by wwwbbat on 16/4/15.
//  Copyright © 2016年 wwwbbat. All rights reserved.
//

#import "SPItemSlot.h"
#import "VDFNode.h"

@implementation SPItemSlot

+ (instancetype)slotWithNode:(VDFNode *)node
{
    if (!node) {
        return nil;
    }
    
    NSDictionary *data = node.datasDict;
    
    SPItemSlot *slot = [SPItemSlot new];
    slot.SlotIndex = [data[@"slotindex"] intValue];
    slot.SlotText = data[@"slottext"];
    slot.SlotName = data[@"slotname"];
    
    return slot;
}

+ (instancetype)loadoutSlot:(VDFNode *)node
{
    if (!node) {
        return nil;
    }
    
    SPItemSlot *slot = [SPItemSlot new];
    
    slot.SlotIndex = node.k.intValue;
    slot.SlotName = node.v;
    slot.SlotText = [@"LoadoutSlot_" stringByAppendingString:node.v];
    
    return slot;
}

+ (NSArray *)loadoutSlots:(VDFNode *)node
{
    NSMutableArray *list = [NSMutableArray array];
    for (VDFNode *aNode in node.datas) {
        SPItemSlot *aSlot = [SPItemSlot loadoutSlot:aNode];
        if (aSlot) {
            [list addObject:aSlot];
        }
    }
    return list;
}

@end
