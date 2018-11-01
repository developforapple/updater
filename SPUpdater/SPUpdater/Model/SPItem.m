//
//  SPItem.m
//  ShiPing
//
//  Created by wwwbbat on 16/4/14.
//  Copyright © 2016年 wwwbbat. All rights reserved.
//

#import "SPItem.h"
#import <YYModel.h>
#import "SPItemStyle.h"

@interface SPItem () <YYModel>

@end

@implementation SPItem

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper
{
    return @{@"autograph":@"autograph.workshoplink",
             @"lootList":@"static_attributes.treasure loot list.value"};
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic
{
    
    NSDictionary *styles = self.visuals[@"styles"];
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *index in styles) {
        NSDictionary *info = styles[index];
        SPItemStyle *aStyle = [SPItemStyle styleOfInfo:info index:index];
        [array addObject:aStyle];
    }
    self.styles = array;
    
    if (self.used_by_heroes && [self.used_by_heroes isKindOfClass:[NSDictionary class]]) {
        self.heroes = [self.used_by_heroes.allKeys componentsJoinedByString:@"||"];
    }
    
    if (self.bundle && [self.bundle isKindOfClass:[NSDictionary class]]) {
        self.bundleItems = [self.bundle.allKeys componentsJoinedByString:@"||"];
    }
    
    if (self.styles && [self.styles isKindOfClass:[NSArray class]]) {
        self.stylesString = [self.styles yy_modelToJSONString];
    }

    return YES;
}

- (NSString *)item_rarity
{
    if (!_item_rarity) {
        _item_rarity = @"common";
    }
    return _item_rarity;
}

- (NSString *)item_quality
{
    if (!_item_quality) {
        _item_quality = @"base";
    }
    return _item_quality;
}

- (NSString *)item_description
{
    if (!_item_description) {
        _item_description = [_item_name copy];
    }
    return _item_description;
}

@end

@implementation SPItemAutograph

@end
