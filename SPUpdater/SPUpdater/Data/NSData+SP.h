//
//  NSData+SP.h
//  SPUpdater
//
//  Created by Jay on 2017/12/14.
//  Copyright © 2017年 tiny. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (SP)

- (BOOL)spSafeWriteToFile:(NSString *)path error:(NSError *__autoreleasing *)errorPtr;

@end
