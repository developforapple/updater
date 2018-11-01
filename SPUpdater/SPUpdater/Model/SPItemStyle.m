//
//  SPItemStyle.m
//  ShiPing
//
//  Created by wwwbbat on 2017/7/21.
//  Copyright © 2017年 wwwbbat. All rights reserved.
//

#import "SPItemStyle.h"
#import <YYModel.h>

@implementation SPItemStyle

- (void)encodeWithCoder:(NSCoder *)aCoder { [self yy_modelEncodeWithCoder:aCoder]; }
- (id)initWithCoder:(NSCoder *)aDecoder { self = [super init]; return [self yy_modelInitWithCoder:aDecoder]; }
- (id)copyWithZone:(NSZone *)zone { return [self yy_modelCopy]; }
- (NSUInteger)hash { return [self yy_modelHash]; }
- (BOOL)isEqual:(id)object { return [self yy_modelIsEqual:object]; }

+ (instancetype)styleOfInfo:(NSDictionary *)info index:(NSString *)index
{
    SPItemStyle *style = [SPItemStyle new];
    style.index = index;
    style.name = info[@"name"];
    
    NSDictionary *unlockDict = info[@"unlock"];
    
    if (unlockDict) {

        SPItemStyleUnlock *unlockObj = [SPItemStyleUnlock new];
        
        NSDictionary *gemInfo = unlockDict[@"gem"];
        if (gemInfo) {
            unlockObj.type_field = gemInfo[@"type_field"];
            unlockObj.def_index = gemInfo[@"def_index"];
            unlockObj.unlock_field = gemInfo[@"unlock_field"];
            unlockObj.unlock_value = gemInfo[@"unlock_value"];
            unlockObj.type_value = gemInfo[@"type_value"];
        }else{
            unlockObj.item_def = unlockDict[@"item_def"];
        }
        
        style.unlock = unlockObj;
    }
    return style;
}

@end

@implementation SPItemStyleUnlock
- (void)encodeWithCoder:(NSCoder *)aCoder { [self yy_modelEncodeWithCoder:aCoder]; }
- (id)initWithCoder:(NSCoder *)aDecoder { self = [super init]; return [self yy_modelInitWithCoder:aDecoder]; }
- (id)copyWithZone:(NSZone *)zone { return [self yy_modelCopy]; }
- (NSUInteger)hash { return [self yy_modelHash]; }
- (BOOL)isEqual:(id)object { return [self yy_modelIsEqual:object]; }
@end
