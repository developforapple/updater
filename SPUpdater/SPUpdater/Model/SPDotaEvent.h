//
//  SPDotaEvent.h
//  ShiPing
//
//  Created by wwwbbat on 2017/8/16.
//  Copyright © 2017年 wwwbbat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPDotaEvent : NSObject
@property (assign, nonatomic) NSInteger id;
@property (copy, nonatomic) NSString *event_id;
@property (copy, nonatomic) NSString *event_name;
@property (copy, nonatomic) NSString *image_name;
@end
