//
//  SPVDFResponseSerializer.m
//  ShiPing
//
//  Created by wwwbbat on 16/5/7.
//  Copyright © 2016年 wwwbbat. All rights reserved.
//

#import "SPVDFResponseSerializer.h"
#import "KeyValueParser.h"

@implementation SPVDFResponseSerializer

- (nullable id)responseObjectForResponse:(nullable NSURLResponse *)response
                                    data:(nullable NSData *)data
                                   error:(NSError * _Nullable __autoreleasing *)error
{
    if (data.length > 0) {
        
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"items_game.txt"];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        [string writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        TreeNode *node = [KeyValueParser parseData:data];
        return node;
    }
    return nil;
}

@end
