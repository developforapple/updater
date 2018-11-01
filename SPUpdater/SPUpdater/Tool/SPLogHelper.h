//
//  SPLogHelper.h
//  SPUpdater
//
//  Created by Jay on 2017/12/8.
//  Copyright © 2017年 tiny. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSTextView;

#define SPLog(...)                                                      \
{                                                                       \
    NSString *text = [NSString stringWithFormat: __VA_ARGS__ ];         \
    NSLog(__VA_ARGS__);                                                 \
    [[SPLogHelper helper] log:text];                                    \
}

@interface SPLogHelper : NSObject

+ (instancetype)helper;
- (void)log:(NSString *)text;

+ (void)setLogOutputTextView:(NSTextView *)textView;

@end
