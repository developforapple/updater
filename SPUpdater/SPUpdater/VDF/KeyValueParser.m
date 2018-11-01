
#import "KeyValueParser.h"

@implementation KeyValueParser
+ (TreeNode *)parseData:(NSData *)VDFData
{
    /*      TreeNode结构：
     *          NSMutableDictionary *data;  保存该Node下的key-value值，该值满足没有分支这个条件。
     *          BOOL isleaf;                是否是最终分支
     *          TreeNode *parent;           父节点
     *          NSMutableDictionary *child; 保存所有子节点key-value值。子节点含有分支。
     */
    
    @autoreleasepool {
        TreeNode *result = [[TreeNode alloc] init];
        
        char tempStr[10240];
        char tempK[10240];
        
        memset(tempStr, 0, sizeof(tempStr));
        memset(tempK, 0, sizeof(tempK));
        
        bool isKey = TRUE;          //判断 "abcdefg" 之间的 abcdefg 是一个key还是一个value
        bool startC = FALSE;        //判断遇到 " 时，是一个字符串的开始还是结束。
        TreeNode *curNode = result; //保存当前取得的Node值
        
        NSInteger length = VDFData.length;         //
        Byte *bytes = (Byte *)VDFData.bytes;
        
        bool hadAnEscape = FALSE;   //处理转义字符
        
        for (int i=0; i<length; i++) {                          //遍历所有字符
            UniChar c = bytes[i];
            
            switch (c) {
                case '{':
                {
                    if (startC) {
                        continue;
                    }
                    
                    curNode.isleaf = FALSE;                         // { 代表了一个value的开始，开始新分支。isleaf，为true时代表该Node是最终的叶，没有分支。
                    
                    NSString *temp = [NSString stringWithUTF8String:tempK];
                    
                    TreeNode *childNode = curNode.child[temp];   //  chilaNode将保存{} 内内容。
                    if (!childNode) {
                        childNode = [[TreeNode alloc] init];
                        [curNode.child setObject:childNode forKey:temp];
                    }
                    
                    childNode.parent = curNode;
                    curNode = childNode;
                    isKey = TRUE;                                   //下一个""内的内容将是一个key。
                }
                    break;
                    
                case '}':
                {
                    if (startC) {
                        continue;
                    }
                    
                    curNode = curNode.parent;                       //结束当前节点
                    isKey = TRUE;                                   //下一个""内内容将是一个key
                }
                    break;
                    
                case '\"':
                {
                    //遇到转义字符时 需要忽略一次 "
                    if (hadAnEscape) {
                        hadAnEscape = FALSE;
                        char tempchar[2] = {c,'\0'};
                        strcat(tempStr, tempchar);
                        continue;
                    }
                    
                    startC = !startC;
                    if (startC) {                                    //如果当前" 是字符串的开始。则这个字符串将保存在tempString内
                        memset(tempStr, 0, sizeof(tempStr));
                    }else{
                        if (isKey){
                            strcpy(tempK, tempStr);
                        }
                        else{
                            NSString *v = [NSString stringWithUTF8String:tempStr];
                            NSString *k = [[NSString stringWithUTF8String:tempK] lowercaseString];
                            
                            curNode.data[k] = v;
                        }
                        isKey = !isKey;
                    }
                }
                    break;
                case '\n':{
                    
                }break;
                case '\r':case '\t':{
                    
                }break;
                default:
                {
                    if (hadAnEscape) {
                        hadAnEscape = FALSE;
                    }else if (c == '\\') {
                        hadAnEscape = TRUE;
                    }
                    
                    if (!startC) {
                        continue;
                    }
                    
                    char tempchar[2] = {c,'\0'};
                    strcat(tempStr, tempchar);
                }
                    break;
            }
        }
        return result;
    }
}
@end
