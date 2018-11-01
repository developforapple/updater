//
//  VDFParser.h
//  ShiPing
//
//  Created by wwwbbat on 2017/8/6.
//  Copyright © 2017年 wwwbbat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFNode.h"

@interface VDFParser : NSObject

- (instancetype)initWithData:(NSData *)data;

@property (strong, readonly, nonatomic) NSData *data;

@property (strong, readonly, nonatomic) VDFNode *root;

- (void)parse;
+ (VDFNode *)parse:(NSData *)data;

@end
