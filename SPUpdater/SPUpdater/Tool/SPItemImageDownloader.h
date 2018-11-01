//
//  SPItemImageDownloader.h
//  ShiPing
//
//  Created by wwwbbat on 2017/7/17.
//  Copyright © 2017年 wwwbbat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPItemImageDownloader : NSObject

+ (void)downloadAllItems:(NSString *)dbPath;
+ (void)downloadItems:(NSArray *)items;


+ (void)compressImages;

@end
