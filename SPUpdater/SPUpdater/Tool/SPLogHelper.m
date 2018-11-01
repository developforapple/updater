//
//  SPLogHelper.m
//  SPUpdater
//
//  Created by Jay on 2017/12/8.
//  Copyright © 2017年 tiny. All rights reserved.
//

#import "SPLogHelper.h"
#import <AppKit/NSTextView.h>
#import "SPPathManager.h"

@interface SPLogHelper ()
@property (assign) NSTimeInterval lastCheckLogFileTime;
@property (strong) NSDateFormatter *formatter;
@property (weak, nonatomic) NSTextView *textView;
@property (strong, nonatomic) NSFileHandle *file;
@property (strong) dispatch_queue_t queue;
@end

@implementation SPLogHelper

+ (instancetype)helper
{
    static SPLogHelper *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [SPLogHelper new];
        instance.formatter = [[NSDateFormatter alloc] init];
        instance.formatter.dateStyle = NSDateFormatterMediumStyle;
        instance.formatter.timeStyle = NSDateFormatterMediumStyle;
        instance.formatter.locale = [NSLocale currentLocale];
        instance.lastCheckLogFileTime = [[NSDate date] timeIntervalSince1970];

        instance.queue = dispatch_queue_create("LogFileWriteQueue", NULL);

        NSString *path = [SPPathManager logFilePath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] createFileAtPath:path contents:[NSData data] attributes:nil];
        }
        NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:path];
        [file seekToEndOfFile];
        instance.file = file;
    });
    return instance;
}

- (void)log:(NSString *)text
{
    NSString *time = [self.formatter stringFromDate:[NSDate date]];
    NSString *log = [NSString stringWithFormat:@"%@ : %@\n",time,text];
    
    if (self.textView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *textViewString = [log stringByAppendingString:self.textView.string];
            if (textViewString.length > 1024 * 1024) {
                self.textView.string = [textViewString substringToIndex:1024*1024];
            }else{
                self.textView.string = textViewString;
            }
        });
    }

    dispatch_async(self.queue, ^{
        [self.file writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
    });
}

+ (void)setLogOutputTextView:(NSTextView *)textView
{
    [SPLogHelper helper].textView = textView;
}

@end
