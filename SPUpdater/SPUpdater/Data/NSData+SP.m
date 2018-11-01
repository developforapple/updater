//
//  NSData+SP.m
//  SPUpdater
//
//  Created by Jay on 2017/12/14.
//  Copyright © 2017年 tiny. All rights reserved.
//

#import "NSData+SP.h"

@implementation NSData (SP)

- (BOOL)spSafeWriteToFile:(NSString *)path error:(NSError *__autoreleasing *)errorPtr
{
    NSString *tmp = [path stringByAppendingString:@".tmp"];
    [[NSFileManager defaultManager] removeItemAtPath:tmp error:nil];
    BOOL suc = [self writeToFile:tmp options:NSDataWritingAtomic error:errorPtr];
    if (suc) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        suc = [[NSFileManager defaultManager] moveItemAtPath:tmp toPath:path error:errorPtr];
    }
    return suc;
}

@end
