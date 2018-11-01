/*
 *          定义items_game.txt解析后的数据格式
 */
#import <Foundation/Foundation.h>

@interface TreeNode : NSObject

@property (nonatomic) NSMutableDictionary<NSString *,id > *data;                // 保存该Node下的key-value值，该值满足没有分支这个条件。
@property (nonatomic)  BOOL isleaf;                             //是否是最终分支
@property (nonatomic) TreeNode *parent;                         //父节点
@property (nonatomic) NSMutableDictionary<NSString *, TreeNode *> *child;               //保存所有子节点key-value值。子节点含有分支。

- (void)clear;

@end
