//
//  VDFParser.m
//  ShiPing
//
//  Created by wwwbbat on 2017/8/6.
//  Copyright © 2017年 wwwbbat. All rights reserved.
//

#import "VDFParser.h"
#import "VDFNode.h"

@interface VDFParser ()
@property (strong, readwrite, nonatomic) NSData *data;
@property (strong, readwrite, nonatomic) VDFNode *root;
@end

@implementation VDFParser

- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        self.data = data;
    }
    return self;
}

+ (VDFNode *)parse:(NSData *)data
{
    VDFParser *tmp = [[VDFParser alloc] initWithData:data];
    [tmp parse];
    return tmp.root;
}

- (void)dealloc
{
    NSLog(@"VDFParser 释放");
}

- (void)parse
{
    @autoreleasepool {
        
        VDFNode *root = [VDFNode new];
        
        char strBuf[10240];
        char keyBuf[10240];
        
        memset(strBuf, 0, sizeof(strBuf));
        memset(keyBuf, 0, sizeof(keyBuf));
        
        // 判断一个token是key还是value
        BOOL isKey = YES;
        // 标记引号“ 是一个字符串的开始还是结束
        BOOL isHead = NO;
        // 标记遇到了转义字符
        BOOL isEscapeC = NO;
        
        // 当前操作的node
        VDFNode *curNode = root;
        
        long long length = self.data.length;
        Byte *bytes = (Byte *)self.data.bytes;
        
        for (long long i = 0; i<length; i++) {
            
            UniChar c = bytes[i];
            
            switch (c) {
                case '{':{
                    
                    // { 是token的内容
                    if (isHead) continue;
                    
                    // 这是一个子node
                    NSString *key = [NSString stringWithUTF8String:keyBuf];
                    VDFNode *child = [VDFNode new];
                    child.k = key;
                    child.parent = curNode;
                    [curNode.children addObject:child];
                    
                    // 开始解析子node
                    curNode = child;
                    isKey = YES;
                    
                }   break;
                case '}':{
                    
                    // } 是token的内容
                    if (isHead) continue;
                    
                    // 子node结束，切换到父node，继续解析
                    curNode = curNode.parent;
                    isKey = YES;
                    
                }   break;
                case '\"':{
                    
                    // 遇到转义"
                    if (isEscapeC) {
                        isEscapeC = NO;
                        char tmp[2] = {c,'\0'};
                        strcat(strBuf, tmp);
                        continue;
                    }
                    
                    isHead = !isHead;
                    
                    if (isHead) {
                        // token的开始，重置buffer
                        memset(strBuf, 0, sizeof(strBuf));
                    }else{
                        // 结束一个token
                        
                        if (isKey) {
                            // token是一个key
                            strcpy(keyBuf, strBuf);
                        }else{
                            
                            NSString *key = [[NSString stringWithUTF8String:keyBuf] lowercaseString];
                            NSString *value = [NSString stringWithUTF8String:strBuf];
                            
                            VDFNode *node = [VDFNode new];
                            node.k = key;
                            node.v = value;
                            node.parent = curNode;
                            [curNode.datas addObject:node];
                        }
                        isKey = !isKey;
                    }
                    
                }   break;
                case '\n':
                case '\r':
                case '\t':{
                    
                    
                }   break;
                default:{
                    
                    if (isEscapeC) {
                        isEscapeC = NO;
                    }else if (c == '\\'){
                        isEscapeC = YES;
                    }
                    
                    if (!isHead) {
                        continue;
                    }
                    
                    char tmp[2] = {c,'\0'};
                    strcat(strBuf, tmp);
                    
                }   break;
                    
            }
            
        }
        
        self.root = root;
    }
}

@end
