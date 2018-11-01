//
//  AppDelegate.m
//  SPUpdater
//
//  Created by Jay on 2017/12/5.
//  Copyright © 2017年 tiny. All rights reserved.
//

#import "AppDelegate.h"
#import "SPUpdater.h"
#import "SPLogHelper.h"
#import "SPItemImageDownloader.h"
#import "SPLocalMapping.h"
#import "SPPathManager.h"

@interface AppDelegate () < NSMenuDelegate>
@property (strong) NSStatusItem *statusItem;
@property (weak) IBOutlet NSMenu *statusMenu;
@property (weak) IBOutlet NSMenuItem *basedataItem;
@property (weak) IBOutlet NSMenuItem *langItem;
@property (weak) IBOutlet NSMenuItem *langpatchItem;
@property (weak) IBOutlet NSMenuItem *checkDelayTimeItem;
@property (weak) IBOutlet NSMenuItem *lastCheckTimeItem;
@property (weak) IBOutlet NSMenuItem *nextCheckTimeItem;
@property (weak) IBOutlet NSMenuItem *lastUpdateTimeItem;
@property (weak) IBOutlet NSMenuItem *checkUpdateItem;
@property (weak) IBOutlet NSMenuItem *updateItem;
@property (weak) IBOutlet NSMenuItem *oldServiceItem;
@property (weak) IBOutlet NSMenuItem *adServiceItem;
@property (weak) IBOutlet NSMenuItem *proServiceItem;
@property (weak) IBOutlet NSMenuItem *logItem;
@property (weak) IBOutlet NSMenuItem *curLogItem;
@property (weak) IBOutlet NSMenuItem *quititem;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    SPLog(@"applicationDidFinishLaunching");
    [self initStatusItem];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)initStatusItem
{
    self.statusMenu.delegate = self;
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setImage:[NSImage imageNamed:@"Icon"]];
    self.statusItem.menu = self.statusMenu;
    [self updateServiceMenuItems];
    
    [SPUpdater updater].stateRefresh = ^(SPUpdaterState *state) {
        [self stateDidChanged:state];
    };
}

- (void)stateDidChanged:(SPUpdaterState *)state
{
    [self updateVersionMenuItems];
    [self updateTimeMenuItems];
    [self updateServiceMenuItems];
}

- (void)updateVersionMenuItems
{
    SPUpdaterState *state = [SPUpdater updater].state;
    self.basedataItem.title = [NSString stringWithFormat:@"基础数据：%lld",state.baseDataVersion];
    self.langItem.title = [NSString stringWithFormat:@"主语言：%lld",[state getLangVersion:kSPLanguageSchinese]];
    self.langpatchItem.title = [NSString stringWithFormat:@"主语言：%lld",[state getPatchVersion:kSPLanguageSchinese]];
}

- (void)updateTimeMenuItems
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterMediumStyle;
    formatter.locale = [NSLocale currentLocale];
    
    SPUpdaterState *state = [SPUpdater updater].state;
    self.lastCheckTimeItem.title = [NSString stringWithFormat:@"上次检查：%@",[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:state.lastCheckTime]]];
    self.nextCheckTimeItem.title = [NSString stringWithFormat:@"下次检查：%@",[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:state.nextCheckTime]]];
    self.lastUpdateTimeItem.title = [NSString stringWithFormat:@"上次更新：%@",[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:state.lastUpdateTime]]];
    
    int remain = state.nextCheckTime - [[NSDate date] timeIntervalSince1970];
    int h = remain / 3600;
    int m = remain % 3600 / 60;
    self.checkDelayTimeItem.title = [NSString stringWithFormat:@"距离下次检查：%d小时%d分",h,m];
}

- (void)updateServiceMenuItems
{
    self.oldServiceItem.state = [SPUpdater updater].state.oldServiceOn ? NSControlStateValueOn  : NSControlStateValueOff ;
    self.adServiceItem.state = [SPUpdater updater].state.adServiceOn ? NSControlStateValueOn  : NSControlStateValueOff ;
    self.proServiceItem.state = [SPUpdater updater].state.proServiceOn ? NSControlStateValueOn  : NSControlStateValueOff ;
}

- (void)menuWillOpen:(NSMenu *)menu
{
    [self updateVersionMenuItems];
    [self updateTimeMenuItems];
    [self updateServiceMenuItems];
}

- (BOOL)alertWhenUpdating
{
    if ([SPUpdater updater].isUpdating) {
        SPLog(@"正在更新中...");
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"正在更新中！";
        alert.alertStyle = NSAlertStyleInformational;
        [alert runModal];
        return YES;
    }
    return NO;
}

- (IBAction)checkUpdateAction:(id)sender
{
    SPLog(@"手动检查更新");
    if (![self alertWhenUpdating]) {
        [[SPUpdater updater] start];
    }
}

- (IBAction)updateAction:(id)sender
{
    SPLog(@"手动强制更新");
    if (![self alertWhenUpdating]){
        [[SPUpdater updater] beginUpdate];
    }
}

- (IBAction)oldServiceAction:(id)sender
{
    if (![self alertWhenUpdating]){
        SPUpdaterState *state = [SPUpdater updater].state;
        state.oldServiceOn = !state.oldServiceOn;
        [self updateServiceMenuItems];
        SPLog(@"Old Service turn %@",state.oldServiceOn ? @"ON" : @"OFF");
    }
}

- (IBAction)adServiceAcTION:(id)sender
{
    if (![self alertWhenUpdating]){
        SPUpdaterState *state = [SPUpdater updater].state;
        state.adServiceOn = !state.adServiceOn;
        [self updateServiceMenuItems];
        SPLog(@"AD Service turn %@",state.adServiceOn ? @"ON" : @"OFF");
    }
}

- (IBAction)proServiceAction:(id)sender
{
    if (![self alertWhenUpdating]){
        SPUpdaterState *state = [SPUpdater updater].state;
        state.proServiceOn = !state.proServiceOn;
        [self updateServiceMenuItems];
        SPLog(@"PRO Service turn %@",state.proServiceOn ? @"ON" : @"OFF");
    }
}

- (IBAction)openLogFile:(id)sender
{
    [SPItemImageDownloader downloadAllItems:[SPArchivePathManager itemDatabaseFilePath]];
}

- (IBAction)showCurLog:(id)sender
{
    
}

@end
