//
//  SPItemGameData.h
//  ShiPing
//
//  Created by wwwbbat on 16/4/14.
//  Copyright © 2016年 wwwbbat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFNode.h"
#import "SPItem.h"
#import "SPItemRarity.h"
#import "SPItemPrefab.h"
#import "SPItemQuality.h"
#import "SPHero.h"
#import "SPItemSlot.h"
#import "SPItemColor.h"
#import "SPItemSets.h"
#import "SPDotaEvent.h"
#import "SPLootList.h"
#import "SPUpdaterState.h"

@interface SPItemGameModel : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)init:(SPUpdaterState *)state;

@property (strong, nonatomic) NSArray<SPHero *> *heroes;
@property (strong, nonatomic) NSArray<SPDotaEvent *> *events;

@property (strong, nonatomic) NSArray<SPItem *> *items;
@property (strong, nonatomic) NSArray<SPItemRarity *> *rarities;
@property (strong, nonatomic) NSArray<SPItemPrefab *> *prefabs;
@property (strong, nonatomic) NSArray<SPItemQuality *> *qualities;
@property (strong, nonatomic) NSArray<SPItemSlot *> *slots; //player_loadout_slots
@property (strong, nonatomic) NSArray<SPItemColor *> *colors;
@property (strong, nonatomic) NSArray<SPItemSets *> *item_sets;

// key: item name  value: bundle name 集合 一个item可以属于多个包
@property (strong, nonatomic) NSDictionary<NSString *,NSSet<NSString *> *> *item_sets_map;

@property (strong, nonatomic) NSArray<SPLootList *> *loot_list;

@property (strong, nonatomic) NSString *dbPath;

@property (assign, nonatomic) NSInteger addCount;
@property (assign, nonatomic) NSInteger modifyCount;
@property (strong) NSArray *addItemsInfo;

- (BOOL)build:(VDFNode *)root;

- (BOOL)save;

@end
