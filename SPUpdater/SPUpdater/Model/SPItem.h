//
//  SPItem.h
//  ShiPing
//
//  Created by wwwbbat on 16/4/14.
//  Copyright © 2016年 wwwbbat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPItemStyle.h"
#import <YYModel.h>

FOUNDATION_EXTERN NSMutableSet *kItemKeys;

@class SPItemChild;
@class SPItemAutograph;

@interface SPItem : NSObject

// key
@property (strong, nonatomic) NSNumber *token;  // 20818

// data
@property (strong, nonatomic) NSString *creation_date;      //2015-05-20
@property (strong, nonatomic) NSString *image_inventory;    //econ/loading_screens/storm_spring_loadingscreen
@property (strong, nonatomic) NSString *item_description;   //#DOTA_Item_Desc_Sizzling_Charge
@property (strong, nonatomic) NSString *item_name;          //#DOTA_Item_Sizzling_Charge
@property (strong, nonatomic) NSString *item_rarity;        //rare
@property (strong, nonatomic) NSString *name;               //Sizzling Charge
@property (strong, nonatomic) NSString *prefab;             //bundle
@property (strong, nonatomic) NSString *item_type_name;     //#DOTA_WearableType_Sword
@property (strong, nonatomic) NSString *image_banner;       //econ/leagues/subscriptions_vietnams2_ingame
@property (strong, nonatomic) NSString *tournament_url;     //http://esportsviet.vn/vecl
@property (strong, nonatomic) NSString *item_slot;          //neck
@property (strong, nonatomic) NSString *item_quality;       //genuine
@property (strong, nonatomic) NSNumber *hidden;             //hidden

@property (strong, nonatomic) NSString *purchase_requirement_prompt_text;   //db name: prpt
@property (strong, nonatomic) NSString *purchase_requires_owning_league_id; //db name: proli
@property (strong, nonatomic) NSString *purchase_requirement_prompt_ok_text; //db name: prpot
@property (strong, nonatomic) NSString *purchase_requirement_prompt_ok_event;//db name: prpoe
@property (strong, nonatomic) NSString *purchase_through_event;              //db name: pte

@property (strong, nonatomic) NSString *override_attack_attachments; //覆盖攻击 //db name: oaa
@property (strong, nonatomic) NSString *event_id;       //DOTA_EventName_International2014
@property (strong, nonatomic) NSString *expiration_date;//结束时间
@property (strong, nonatomic) NSString *player_loadout;
@property (strong, nonatomic) NSString *associated_item;
@property (strong, nonatomic) NSString *item_class;

// YYModel生成
//只保存一个 workshoplink 比如pc cold的亲笔签名 281702591
@property (strong, nonatomic) NSString *autograph;
// 箱子的掉落列表, 对应txt的  static_attributes.treasure loot list.value
@property (strong, nonatomic) NSString *lootList;

// 需要手动生成
// 饰品所属英雄。使用 || 分隔    npc_dota_hero_centaur|npc_dota_hero_centaur
@property (strong, nonatomic) NSString *heroes; 
// 捆绑包中的饰品 使用 || 分隔
@property (strong, nonatomic) NSString *bundleItems;
// 饰品所属的捆绑包，使用 || 分隔
@property (strong, nonatomic) NSString *bundles;

@property (strong, nonatomic) NSString *image_inventory_large;

/*
 {
 "armor of sizzling charge" = 1;
 "hat of sizzling charge" = 1;
 "pauldrons of sizzling charge" = 1;
 "sizzling charge loading screen" = 1;
 }
 */
@property (strong, nonatomic) NSDictionary *bundle;

@property (strong, nonatomic) NSDictionary *static_attributes;

@property (strong, nonatomic) NSDictionary *additional_info;

/*
 {
 "npc_dota_hero_storm_spirit" = 1;
 }
 */
@property (strong, nonatomic) NSDictionary *used_by_heroes; //可能是字典

@property (strong, nonatomic) NSDictionary *visuals;

// 存在于 visuals/styles下
@property (strong, nonatomic) NSArray<SPItemStyle *> *styles;
// json格式
@property (copy, nonatomic) NSString *stylesString;

//
///*
// {
// "is_weapon" = 1;
// }
// */
//@property (strong, nonatomic) NSDictionary *tags;
//
///*
// {
// type = "league_view_pass";
// "use_string" = "#ConsumeItem";
// }
// child keys: usage
// */
//@property (strong, nonatomic) NSDictionary *tool;

@end

@interface SPItemAutograph : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *workshoplink;
@property (strong, nonatomic) NSNumber *language;
@property (strong, nonatomic) NSNumber *filename_override;
@property (strong, nonatomic) NSString *icon_path;
@end
