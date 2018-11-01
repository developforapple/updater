/*
 *
 *      从items_game.txt获取数据的类
 *      items_game.txt内容格式为value专有格式，类似于json
 *      返回TreeNode格式数据
 *
 */

#import <Foundation/Foundation.h>
#import "TreeNode.h"

@interface KeyValueParser : NSObject

+ (TreeNode *)parseData:(NSData *)data;

@end
