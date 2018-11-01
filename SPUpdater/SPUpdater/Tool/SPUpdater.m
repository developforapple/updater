//
//  SPUpdater.m
//  SPUpdater
//
//  Created by Jay on 2017/12/8.
//  Copyright © 2017年 tiny. All rights reserved.
//

#import "SPUpdater.h"
#import "SPLocalMapping.h"
#import "SPPathManager.h"
#import "VDFParser.h"
#import <AFNetworking.h>
#import <AVOSCloud.h>
#import "SPItemGameData.h"
#import "SPLogHelper.h"
#import "SPItemImageDownloader.h"

static ServiceType kNoneType = -1;
static ServiceType kDoneType = 999;

NSString *logStringForServiceType(ServiceType type){
    switch (type) {
        case ServiceTypeOld:    return @"饰品总汇";
        case ServiceTypeAd:     return @"刀塔饰品 ad";
        case ServiceTypePro:    return @"刀塔饰品 pro";
    }
    return nil;
}

NSString *appidForServiceType(ServiceType type){
    switch (type) {
        case ServiceTypeOld:    return @"uy7j0G50gYzI8jOopjxUNPpT-gzGzoHsz";
        case ServiceTypeAd:     return @"K1mtJOrizsvrywTyYq85j3xL-gzGzoHsz";
        case ServiceTypePro:    return @"nyAIoo7OddnRAE0Ch7WOTjRx-gzGzoHsz";
    }
    return nil;
}

NSString *keyForServiceType(ServiceType type){
    switch (type) {
        case ServiceTypeOld:    return @"RkF7f6l3KjnnOKA7jTD1YFn7";
        case ServiceTypeAd:     return @"6VNgktNuzuT7exKg1fTF8x4q";
        case ServiceTypePro:    return @"IVLqzHqTqdjbXch8YekoUEdf";
    }
    return nil;
}

NSString *masterKeyForServiceType(ServiceType type){
    switch (type) {
        case ServiceTypeOld:    return @"";
        case ServiceTypeAd:     return @"WcTv3IdnLVlToQw0eO6NVlFz";
        case ServiceTypePro:    return @"bRJEHiGAEKLVpxXcwb8X9O22";
    }
    return nil;
}

@interface SPUpdater ()

@property (strong, nonatomic) SPLocalMapping *langData;
@property (strong, nonatomic) SPItemGameModel *itemData;

@property (assign, readwrite, getter=isUpdating, nonatomic) BOOL updating;

@property (strong, nonatomic) dispatch_source_t timer;
@property (strong, nonatomic) dispatch_block_t timerBlock;

@property (strong, nonatomic) AFURLSessionManager *manager;
@property (weak, nonatomic) NSTextView *textView;

@end

@implementation SPUpdater

+ (instancetype)updater
{
    static SPUpdater *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [SPUpdater new];
    });
    return instance;
}

- (SPUpdaterState *)state
{
    if (!_state) {
        _state = [SPUpdaterState lastState];
    }
    return _state;
}

- (SPLocalMapping *)langData
{
    if (!_langData) {
        _langData = [[SPLocalMapping alloc] init:self.state lang:kSPLanguageSchinese];
    }
    return _langData;
}

- (SPItemGameModel *)itemData
{
    if (!_itemData) {
        _itemData = [[SPItemGameModel alloc] init:self.state];
    }
    return _itemData;
}

- (void)setLogOutputTextView:(NSTextView *)textView
{
    [SPLogHelper setLogOutputTextView:textView];
}

#pragma mark - Timer
- (void)resetTimer
{
    [self cancelTimer];
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, kUpdateDuration * NSEC_PER_SEC, 0);
    dispatch_block_t block = dispatch_block_create(DISPATCH_BLOCK_BARRIER, ^{
        [self checkUpdate];
    });
    dispatch_source_set_event_handler(timer, block);
    dispatch_resume(timer);
    self.timer = timer;
    self.timerBlock = block;
}

- (void)cancelTimer
{
    if (self.timer) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
    if (self.timerBlock) {
        dispatch_block_cancel(self.timerBlock);
        self.timerBlock = nil;
    }
}

- (void)start
{
    [self resetTimer];
}

- (void)stop
{
    [self cancelTimer];
}

#define NEED_UPDATE 1
#define NOT_UPDATE 0
#define CHECK_FAILED -1

#pragma mark - CheckUpdate
- (void)checkUpdate
{
    SPLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
    SPLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
    SPLog(@"开始检查更新");
    
    _updating = YES;
    
    // Step 1
    // 检查 items_game_url 是否有更新
    
    self.state.lastCheckTime = [[NSDate date] timeIntervalSince1970];
    self.state.nextCheckTime = self.state.lastCheckTime + kUpdateDuration;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        int c1 = [self checkDotaUpdate];
        int c2 = [self checkItemGameURLUpdate];
        
        if (c1 == CHECK_FAILED || c2 == CHECK_FAILED ) {
            // 在其他地方退出了
            return;
        }
        
        if (c1 || c2) {
            SPLog(@"开始更新流程");
            [self beginUpdate];
        }else{
            SPLog(@"不需要更新。等待下次检查");
            [self waitNextCheck];
        }
    });
}

- (int)checkItemGameURLUpdate
{
    NSString *latestURL = [SPUpdaterState latestItemGameURL];
    if (!latestURL || latestURL.length == 0) {
        [self checkUpdateFailed:@"获取items_game_url失败。停止更新。"];
        return CHECK_FAILED;
    }
    
    BOOL needUpdate = ![self.state.url isEqualToString:latestURL];
    self.state.url = latestURL;
    return needUpdate ? NEED_UPDATE : NOT_UPDATE;
}

- (int)checkDotaUpdate
{
    // Step 2
    // 检查游戏版本是否有更新
    long long lastupdate = NSNotFound;
    long long buildid = NSNotFound;
    BOOL ok = [SPUpdaterState latestDotaInfo:&lastupdate buildid:&buildid];
    if (!ok) {
        [self checkUpdateFailed:@"检查游戏版本出错了。更新中断。"];
        return CHECK_FAILED;
    }

    BOOL c1 = lastupdate != self.state.dota2LastUpdated;
    BOOL c2 = buildid != self.state.dota2Buildid;
    
    self.state.dota2Buildid = buildid;
    self.state.dota2LastUpdated = lastupdate;
    
    return (c1 || c2) ? NEED_UPDATE : NOT_UPDATE;
}

- (void)checkUpdateFailed:(NSString *)msg
{
    SPLog(@"%@",msg);
    [self.state reset];
    [self waitNextCheck];
}

- (void)waitNextCheck
{
    [self.state save];
    if (self.stateRefresh) {
        self.stateRefresh(self.state);
    }
    [self clean];
    SPLog(@"等待下次检查更新");
    SPLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    SPLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
}

- (void)clean
{
    _langData = nil;
    _itemData = nil;
    _updating = NO;
}

#pragma mark - Begin Update

- (void)updateFailed:(NSString *)msg
{
    SPLog(@"%@",msg);
    [self.state reset];
    [self waitNextCheck];
}

- (void)updateDone
{
    SPLog(@"全部上传完毕！");
    
    self.state.lastUpdateTime = [[NSDate date] timeIntervalSince1970];
    
    NSString *tmpDir = [SPTmpPathManager workDir];
    NSString *dir = [SPArchivePathManager workDir];
    
    NSString *tmpSafeDir = [SPPathManager randomDir];
    
    NSError *error;
    // 先将旧存档转移到临时目录
    BOOL a = [[NSFileManager defaultManager] moveItemAtPath:dir toPath:tmpSafeDir error:&error];
    // 再将新数据保存为存档目录
    BOOL b = [[NSFileManager defaultManager] moveItemAtPath:tmpDir toPath:dir error:&error];
    // 删除旧存档的临时目录
    BOOL c = [[NSFileManager defaultManager] removeItemAtPath:tmpSafeDir error:&error];
    
    
    // 新增的饰品需要上传图片到七牛
    NSArray *added = self.itemData.addItemsInfo;
    [self uploadImages:added];
    
    [self waitNextCheck];
}

- (void)beginUpdate
{
    // Step 3
    // 开始更新流程
    
    SPLog(@"读取语言文件");
    BOOL langDone = [self.langData update];
    if (!langDone){
        [self updateFailed:@"读取语言文件失败"];
        return;
    }
    
    // 从steam服务器下载饰品数据
    SPLog(@"获取 饰品基础数据 ");

    NSURL *URL = [NSURL URLWithString:self.state.url];
    NSString *name = [URL lastPathComponent];
    
    NSString *path = [SPTmpPathManager itemsGameTxtFilePath:name];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
    if (NO) { // 这里总是下载最新的items_game.txt
        
        SPLog(@"items_game_url 文件已存在，跳过下载过程。开始解析。");
        NSData *data = [NSData dataWithContentsOfFile:path];
        VDFNode *node = [VDFParser parse:data];
        [self parseItemsGameData:node];
        
    }else{
        SPLog(@"准备下载 items_game.txt : %@",URL);
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        [request setValue:@"gzip,deflate" forHTTPHeaderField:@"Accept-Encoding"];
        [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/603.2.4 (KHTML, like Gecko) Version/10.1.1 Safari/603.2.4" forHTTPHeaderField:@"User-Agent"];
        [request setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"SPUpdaterDownloader"];
        config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        config.timeoutIntervalForRequest = 1 * 60;
        config.timeoutIntervalForResource = 1 * 60;
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:config];
        
        __block int lastP = -1;
        __block NSTimeInterval lasttime = [[NSDate date] timeIntervalSince1970];
        __block long long lastdownloaded = 0;
        
        NSURLSessionDownloadTask *task =
        [manager downloadTaskWithRequest:request progress:^(NSProgress *downloadProgress) {
            
            long long total = downloadProgress.totalUnitCount;
            double downloaded = downloadProgress.completedUnitCount;
            int progress = downloaded / total * 100;
            if (lastP != progress) {
                lastP = progress;
                
                NSTimeInterval t = [[NSDate date] timeIntervalSince1970];
                NSTimeInterval interval = t - lasttime;
                long long d = downloaded - lastdownloaded;
                double speed = d / 1024.f / interval;
                
                lasttime = t;
                lastdownloaded = downloaded;
                
                SPLog(@"%d%%\t%.0f\t/\t%lld %.2fkb/s",progress,downloaded,total,speed);
            }
            
        } destination:^NSURL *(NSURL * targetPath, NSURLResponse *response) {
            
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            return [NSURL fileURLWithPath:path];
            
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (error) {
                    [self updateFailed:error.localizedDescription];
                    return;
                }
                
                SPLog(@"下载items_game.txt结束，文件保存到：%@",filePath);
                SPLog(@"读取...");
                NSError *aError;
                NSData *data = [NSData dataWithContentsOfURL:filePath options:NSDataReadingMappedIfSafe error:&aError];
                if (!data || aError) {
                    [self updateFailed:[NSString stringWithFormat:@"读取items_game.txt出错！error:%@",aError]];
                }else{
                    SPLog(@"解析...");
                    VDFNode *node = [VDFParser parse:data];
                    [self parseItemsGameData:node];
                };
            });
            
        }];
        [task resume];
        self.manager = manager;
    }
}

- (void)parseItemsGameData:(VDFNode *)node
{
    self.manager = nil;
    
    SPLog(@"创建数据Model...");
    
    BOOL itemDataDone = [self.itemData build:[node firstChildWithKey:@"items_game"]];
    if (!itemDataDone) {
        [self updateFailed:@"创建数据 Model 出错！中断。"];
        return;
    }
    
    SPLog(@"保存数据...");
    itemDataDone = [self.itemData save];
    if (!itemDataDone) {
        [self updateFailed:@"创建数据文件出错！中断。"];
        return;
    }
    
    SPLog(@"准备上传数据...");
    
    // 将数据库上传到服务器
    // none -> old -> ad -> pro -> 完成
    [self uploadToServiceNextOf:kNoneType];
}

#pragma mark - Upload
- (void)uploadToServiceNextOf:(ServiceType)type
{
    ServiceType next = kNoneType;
    if (type == kNoneType) {
        if (self.state.oldServiceOn) {
            SPLog(@"准备上传数据到 Old Service");
            next = ServiceTypeOld;
        }else{
            SPLog(@"Old Service 开关关闭。跳过。");
            [self uploadToServiceNextOf:ServiceTypeOld];
            return;
        }
    }
    
    if (type == ServiceTypeOld){
        if (self.state.adServiceOn) {
            SPLog(@"准备上传数据到 Ad Service");
            next = ServiceTypeAd;
        }else{
            SPLog(@"Ad Service 开关关闭。跳过。");
            [self uploadToServiceNextOf:ServiceTypeAd];
            return;
        }
    }
    
    
    if (type == ServiceTypeAd){
        if (self.state.proServiceOn) {
            SPLog(@"准备上传数据到 Pro Service");
            next = ServiceTypePro;
        }else{
            SPLog(@"Pro Service 开关关闭。跳过。");
            [self uploadToServiceNextOf:ServiceTypePro];
            return;
        }
    }
    
    
    if (type == ServiceTypePro){
        next = kDoneType;
    }
    
    if (next == kNoneType) return;
    
    if (next == kDoneType) {
        [self updateDone];
        return;
    }
    
    [self uploadToService:next];
}

- (void)uploadToService:(ServiceType)type
{
    SPLog(@"准备上传 %@ 的数据",logStringForServiceType(type));
    
    NSString *appid = appidForServiceType(type);
    NSString *appkey = keyForServiceType(type);
    
    [AVOSCloud setApplicationId:appid clientKey:appkey];
    [AVOSCloud setAllLogsEnabled:NO];
    
    [self upload:type];
}

- (void)upload:(ServiceType)type
{
    [self uploadLangFileTo:type completion:^(ServiceType type2) {
        [self uploadLangPatchFileTo:type2 completion:^(ServiceType type3) {
            [self uploadBaseData:type3];
        }];
    }];
}

- (void)uploadLangFileTo:(ServiceType )type
              completion:(void (^)(ServiceType type))completion
{
    SPLog(@"检查主语言文件是否需要更新");
    
    NSString *lang = kSPLanguageSchinese;
    long long langVersion = 0;
    AVObject *langVersionObject;
    {
        NSError *error;
        AVQuery *query = [AVQuery queryWithClassName:@"Version"];
        [query whereKey:@"name" equalTo:[NSString stringWithFormat:@"lang_version_%@",lang]];
        AVObject *object = [query findObjects:&error].firstObject;
        if (!object || error) {
            [self updateFailed:[NSString stringWithFormat:@"检查主语言文件版本出错！%@",error]];
            return;
        }
        langVersion = [[object objectForKey:@"version"] longLongValue];
        SPLog(@"服务器中的主语言版本： %lld",langVersion);
        langVersionObject = object;
    }
    
    {
        long long curLangVersion = [self.state getLangVersion:lang];
        SPLog(@"当前主语言文件版本:%lld",curLangVersion);
        if (curLangVersion == langVersion) {
            SPLog(@"不需要更新主语言文件");
            if (completion) {
                completion(type);
            }
            return;
        }
        SPLog(@"需要更新主语言文件，准备上传...");
        {
            NSString *langMainFilePath = [SPTmpPathManager langMainZipFilePath:lang version:curLangVersion];
            AVFile *file = [AVFile fileWithName:langMainFilePath.lastPathComponent contentsAtPath:langMainFilePath];
            
            [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if ( !succeeded || error) {
                    [self updateFailed:[NSString stringWithFormat:@"上传主语言文件失败！%@",error]];
                    return;
                }
                
                SPLog(@"上传主语言文件 完成");
                SPLog(@"更新主文件版本号为：%lld",curLangVersion);
                [langVersionObject setObject:@(curLangVersion) forKey:@"version"];
                BOOL suc = [langVersionObject save:&error];
                
                if (!suc || error) {
                    [self updateFailed:[NSString stringWithFormat:@"上传主语言文件版本号失败！%@",error]];
                    return;
                }
                
                SPLog(@"更新主语言文件 结束");
                if (completion) {
                    completion(type);
                }
            } progressBlock:^(NSInteger percentDone) {
                SPLog(@"上传主语言文件：%d%%",(int)percentDone);
            }];
        }
    }
}

- (void)uploadLangPatchFileTo:(ServiceType)type
                   completion:(void(^)(ServiceType type))completion
{
    SPLog(@"检查语言补丁更新");
    
    NSString *lang = kSPLanguageSchinese;
    long long langPatchVersion = 0;
    AVObject *langPatchVersionObject;
    
    {
        NSError *error;
        AVQuery *query = [AVQuery queryWithClassName:@"Version"];
        [query whereKey:@"name" equalTo:[NSString stringWithFormat:@"lang_patch_version_%@",lang]];
        AVObject *object = [query findObjects:&error].firstObject;
        if (!object || error) {
            [self updateFailed:[NSString stringWithFormat:@"检查语言补丁版本出错！%@",error]];
            return;
        }
        langPatchVersion = [[object objectForKey:@"version"] longLongValue];
        SPLog(@"服务器语言补丁版本： %lld",langPatchVersion);
        langPatchVersionObject = object;
    }
    
    {
        long long curLangVersion = [self.state getLangVersion:lang];
        long long curLangPatchVersion = [self.state getPatchVersion:lang];
        SPLog(@"新的语言补丁版本为:%lld",curLangPatchVersion);
        if (curLangPatchVersion == langPatchVersion) {
            SPLog(@"不需要更新语言补丁文件");
            if (completion) {
                completion(type);
            }
            return;
        }
        
        SPLog(@"上传语言补丁文件 开始");
        {
            NSString *langPatchFilePath = [SPTmpPathManager langPatchZipFilePath:lang version:curLangVersion patch:curLangPatchVersion];;
            AVFile *file = [AVFile fileWithName:langPatchFilePath.lastPathComponent contentsAtPath:langPatchFilePath];
            
            [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if ( !succeeded || error) {
                    [self updateFailed:[NSString stringWithFormat:@"上传语言补丁文件失败！%@",error]];
                    return;
                }
                
                SPLog(@"上传语言补丁 完成");
                SPLog(@"更新语言补丁版本号为：%lld",curLangPatchVersion);
                
                [langPatchVersionObject setObject:@(curLangPatchVersion) forKey:@"version"];
                BOOL suc = [langPatchVersionObject save:&error];
                if (!suc || error) {
                    [self updateFailed:[NSString stringWithFormat:@"上传语言补丁文件版本号失败！%@",error]];
                    return;
                }
                
                SPLog(@"更新语言补丁 结束");
                
                
                if (completion) {
                    completion(type);
                }
                
            } progressBlock:^(NSInteger percentDone) {
                SPLog(@"上传语言补丁：%d%%",(int)percentDone);
            }];
            
        }
    }
}

- (void)uploadBaseData:(ServiceType)type
{
    SPLog(@"准备上传基础数据");
    {
        long long version = [self.state baseDataVersion];
        NSString *dataPath = [SPTmpPathManager baseDataZipFilePath:version];
        AVFile *file = [AVFile fileWithName:dataPath.lastPathComponent contentsAtPath:dataPath];
        
        [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if ( !succeeded || error) {
                [self updateFailed:[NSString stringWithFormat:@"上传基础数据文件失败！%@",error]];
                return;
            }
            
            SPLog(@"准备上传基础数据版本");
            {
                AVQuery *query = [AVQuery queryWithClassName:@"Version"];
                [query whereKey:@"name" equalTo:@"base_data_version"];
                AVObject *object = [query findObjects:&error].firstObject;
                if (!object || error) {
                    [self updateFailed:[NSString stringWithFormat:@"获取基础数据版本出错！%@",error]];
                    return;
                }
                
                [object setObject:@(version) forKey:@"version"];
                BOOL suc = [object save:&error];
                if (!suc || error) {
                    [self updateFailed:[NSString stringWithFormat:@"上传基础数据版本出错！%@",error]];
                    return;
                }
                
                SPLog(@"done");
            }
            
            NSString *logString = logStringForServiceType(type);
            SPLog(@"%@ 更新完成！！",logString);
            
            // 发送推送通知
            [self sendNotification:type];
            
            [self uploadToServiceNextOf:type];
            
        } progressBlock:^(NSInteger percentDone) {
            SPLog(@"%d%%",(int)percentDone);
        }];
    }
}

- (void)sendNotification:(ServiceType)type
{
    NSArray *addItemsInfo = self.itemData.addItemsInfo;
    int add = (int)self.itemData.addCount;
    
    NSString *message;
    if (add > 0) {
        // 只有有新增的饰品才发通知
        
        NSMutableArray *names = [NSMutableArray array];
        for (NSDictionary *aItemInfo in addItemsInfo) {
            NSString *item_name = aItemInfo[@"item_name"];
            NSString *name = aItemInfo[@"name"];
            if (item_name && name) {
                NSString *loc = self.langData.langDict[kSPLanguageSchinese][item_name];
                [names addObject:loc ?: name];
            }
        }
        
        if (names.count == 1) {
            message = [NSString stringWithFormat:@"饰品数据库更新：%@",names[0]];
        }else if (names.count == 2){
            message = [NSString stringWithFormat:@"饰品数据库更新：%@、%@",names[0],names[1]];
        }else if (names.count == 3){
            message = [NSString stringWithFormat:@"饰品数据库更新：%@、%@、%@",names[0],names[1],names[2]];
        }else if (names.count > 3 ){
            message = [NSString stringWithFormat:@"饰品数据库更新：%@、%@、%@ 等%d件饰品。",names[0],names[1],names[2],(int)names.count];
        }
    }

    if (!message) return;
    
    NSString *appid = appidForServiceType(type);
    NSString *masterkey = masterKeyForServiceType(type);
    NSString *url = [NSString stringWithFormat:@"https://%@.push.lncld.net/1.1/push",[appid substringToIndex:8]];
    NSDictionary *content = @{@"data":@{@"alert":message},
//                              @"prod":@"dev"
                              };
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    [request addValue:appid forHTTPHeaderField:@"X-LC-Id"];
    [request addValue:[NSString stringWithFormat:@"%@,master",masterkey] forHTTPHeaderField:@"X-LC-Key"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:content options:kNilOptions error:nil];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            SPLog(@"推送失败！error:%@",error);
            NSData *data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            NSString *t = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            SPLog(@"错误内容：%@",t);
        }else{
            SPLog(@"推送成功");
        }
        
    }] resume];
}

- (void)uploadImages:(NSArray *)items
{
    if (items.count == 0) {
        return;
    }
    
    [SPItemImageDownloader downloadAllItems:[SPArchivePathManager baseDataFilePath]];
}

@end
