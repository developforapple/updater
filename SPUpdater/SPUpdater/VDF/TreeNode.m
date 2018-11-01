
#import "TreeNode.h"

@implementation TreeNode

- (id)init
{
    _isleaf = TRUE;
    _data = [NSMutableDictionary dictionary];
    _child = [NSMutableDictionary dictionary];
    
    return self;
}

- (void)clear
{
    [self.data removeAllObjects];
    
    for (NSString *key in self.child) {
        TreeNode *value = self.child[key];
        [value clear];
    }
    self.parent = nil;
}

- (NSString *)description
{
    NSDictionary *data = self.data;
    NSArray *childKeys = [self.child allKeys];
    
    return [NSString stringWithFormat:@"NodeData:\n%@\nNodeChildKeys:\n %@",data,childKeys];
}

@end
