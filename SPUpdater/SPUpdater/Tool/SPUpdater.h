//
//  SPUpdater.h
//  SPUpdater
//
//  Created by Jay on 2017/12/8.
//  Copyright © 2017年 tiny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPUpdaterState.h"

@class NSTextView;

// 检查更新间隔 2小时一次
#define kUpdateDuration (2*60*60)
// 超时时间 5分钟
#define kTimeout (5*60)

typedef NS_ENUM(NSInteger, ServiceType) {
    ServiceTypeOld,
    ServiceTypePro,
    ServiceTypeAd,
};

@interface SPUpdater : NSObject

+ (instancetype)updater;

@property (strong, nonatomic) SPUpdaterState *state;

// 启动
- (void)start;
// 关闭
- (void)stop;

- (void)beginUpdate;

// 是否正在更新
@property (assign, readonly, getter=isUpdating, nonatomic) BOOL updating;

- (void)setLogOutputTextView:(NSTextView *)textView;

@property (copy) void (^stateRefresh)(SPUpdaterState *state);

- (void)sendNotification:(ServiceType)type;

@end
