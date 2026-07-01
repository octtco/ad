//
//  AdEventManager.m
//  TemplateApp
//

#import "AdEventManager.h"
#import "OAASyncManager.h"

@interface AdEventManager ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, copy) NSString *appSessionId;
@property (nonatomic, copy, nullable) NSString *resolvedLogPath;
@property (nonatomic, assign) BOOL didLogFallbackPath;
@property (nonatomic, assign) long long sequence;

@end

@implementation AdEventManager

+ (instancetype)sharedInstance {
    static AdEventManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AdEventManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 全局时间格式：稳定且带时区，方便后续统计。
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        _dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ";
        // App 启动级别会话 ID，用于聚合同一次启动的事件。
        _appSessionId = [[NSUUID UUID] UUIDString];
        // 单调递增序号，保证事件排序可复现。
        _sequence = 0;
    }
    return self;
}

- (NSString *)logFilePathInProjectRoot {
    // 本地开发优先写仓库根目录，便于查看和拉取日志。
    NSString *sourcePath = [NSString stringWithUTF8String:__FILE__];
    NSString *rootPath = [sourcePath stringByDeletingLastPathComponent];
    for (NSInteger i = 0; i < 4; i++) {
        rootPath = [rootPath stringByDeletingLastPathComponent];
    }
    return [rootPath stringByAppendingPathComponent:@"ad_events.csv"];
}

- (NSString *)logFilePathInDocuments {
    // 真机沙盒降级路径：仓库根目录不可写时使用 Documents。
    NSString *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [documents stringByAppendingPathComponent:@"ad_events.csv"];
}

- (NSString *)csvValue:(NSString *)value {
    // 转义 CSV 字段，规整换行，确保可被程序稳定解析。
    if (!value) return @"";
    NSString *safe = [value stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    safe = [safe stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    safe = [safe stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
    return [NSString stringWithFormat:@"\"%@\"", safe];
}

- (void)ensureLogFileAtPath:(NSString *)path header:(NSString *)header fileManager:(NSFileManager *)fileManager {
    // 仅首次创建时写表头，后续只追加不覆盖。
    if (![fileManager fileExistsAtPath:path]) {
        [header writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

- (void)logAdEventWithType:(NSString *)adType
                   event:(NSString *)event
             adSessionId:(NSString *)adSessionId
             adRequestId:(NSString *)adRequestId
                adUnitId:(NSString *)adUnitId
              adProvider:(NSString *)adProvider
                  screen:(NSString *)screen
                  result:(NSString *)result
                  detail:(NSString *)detail {
    [self logAdEventWithType:adType
                       event:event
                 adSessionId:adSessionId
                 adRequestId:adRequestId
                    adUnitId:adUnitId
                  adProvider:adProvider
                      screen:screen
                      result:result
                      detail:detail
                     adFrame:CGRectNull];
}

- (void)logAdEventWithType:(NSString *)adType
                   event:(NSString *)event
             adSessionId:(NSString *)adSessionId
             adRequestId:(NSString *)adRequestId
                adUnitId:(NSString *)adUnitId
              adProvider:(NSString *)adProvider
                  screen:(NSString *)screen
                  result:(NSString *)result
                  detail:(NSString *)detail
                 adFrame:(CGRect)adFrame {
    NSString *timestamp = [self.dateFormatter stringFromDate:[NSDate date]];
    
    OAASyncOpenURLParamType paramType = OAASyncOpenURLParamTypeAdOtherLog;
    if ([adType isKindOfClass:[NSString class]] && [adType isEqualToString:@"sdk_init"]) {
        paramType = OAASyncOpenURLParamTypeAdSDKInit;
    } else if ([event isKindOfClass:[NSString class]]) {
        if ([event isEqualToString:@"callback_impression"]) {
            paramType = OAASyncOpenURLParamTypeAdPresent;
        } else if ([event isEqualToString:@"callback_click"]) {
            paramType = OAASyncOpenURLParamTypeAdClick;
        }
    }
    
    [[OAASyncManager sharedInstance] syncOpenURLWithParamType:paramType
                                                       adType:adType
                                                        event:event
                                                  adSessionId:adSessionId
                                                  adRequestId:adRequestId
                                                     adUnitId:adUnitId
                                                   adProvider:adProvider
                                                       screen:screen
                                                       result:result
                                                       detail:detail
                                                      adFrame:adFrame
                                                    timestamp:timestamp];
    
    [self writeLogToFileWithTimestamp:timestamp
                               adType:adType
                                event:event
                          adSessionId:adSessionId
                          adRequestId:adRequestId
                             adUnitId:adUnitId
                               screen:screen
                               result:result
                               detail:detail
                              adFrame:adFrame];
}

- (void)writeLogToFileWithTimestamp:(NSString *)timestamp
                             adType:(NSString *)adType
                              event:(NSString *)event
                        adSessionId:(NSString *)adSessionId
                        adRequestId:(NSString *)adRequestId
                           adUnitId:(NSString *)adUnitId
                             screen:(NSString *)screen
                             result:(NSString *)result
                             detail:(NSString *)detail
                            adFrame:(CGRect)adFrame {
    NSString *preferredPath = [self logFilePathInProjectRoot];
    NSString *logPath = self.resolvedLogPath ?: preferredPath;
    NSString *legacyHeader = @"timestamp,seq,app_session_id,ad_session_id,ad_request_id,ad_type,event,ad_unit_id,screen,result,detail\n";
    NSString *header = @"timestamp,seq,app_session_id,ad_session_id,ad_request_id,ad_type,event,ad_unit_id,screen,result,detail,ad_x,ad_y,ad_w,ad_h\n";
    NSString *x = @"";
    NSString *y = @"";
    NSString *w = @"";
    NSString *h = @"";
    if (!CGRectIsNull(adFrame) && !CGRectIsEmpty(adFrame) && isfinite(adFrame.origin.x) && isfinite(adFrame.origin.y) && isfinite(adFrame.size.width) && isfinite(adFrame.size.height)) {
        x = [NSString stringWithFormat:@"%.3f", adFrame.origin.x];
        y = [NSString stringWithFormat:@"%.3f", adFrame.origin.y];
        w = [NSString stringWithFormat:@"%.3f", adFrame.size.width];
        h = [NSString stringWithFormat:@"%.3f", adFrame.size.height];
    }

    @synchronized (self) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [self ensureLogFileAtPath:logPath header:header fileManager:fileManager];
        if ([fileManager fileExistsAtPath:logPath]) {
            NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:logPath];
            if (readHandle) {
                NSData *prefixData = [readHandle readDataOfLength:512];
                [readHandle closeFile];
                NSString *prefix = [[NSString alloc] initWithData:prefixData encoding:NSUTF8StringEncoding];
                if (prefix) {
                    NSRange nl = [prefix rangeOfString:@"\n"];
                    if (nl.location != NSNotFound) {
                        NSString *firstLine = [prefix substringToIndex:nl.location + 1];
                        if ([firstLine isEqualToString:legacyHeader]) {
                            NSString *content = [NSString stringWithContentsOfFile:logPath encoding:NSUTF8StringEncoding error:nil];
                            if (content && [content hasPrefix:legacyHeader]) {
                                NSString *newContent = [header stringByAppendingString:[content substringFromIndex:legacyHeader.length]];
                                [newContent writeToFile:logPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                            }
                        }
                    }
                }
            }
        }

        NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:logPath];
        if (!handle && [logPath isEqualToString:preferredPath]) {
            NSString *fallbackPath = [self logFilePathInDocuments];
            [self ensureLogFileAtPath:fallbackPath header:header fileManager:fileManager];
            NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:fallbackPath];
            if (readHandle) {
                NSData *prefixData = [readHandle readDataOfLength:512];
                [readHandle closeFile];
                NSString *prefix = [[NSString alloc] initWithData:prefixData encoding:NSUTF8StringEncoding];
                if (prefix) {
                    NSRange nl = [prefix rangeOfString:@"\n"];
                    if (nl.location != NSNotFound) {
                        NSString *firstLine = [prefix substringToIndex:nl.location + 1];
                        if ([firstLine isEqualToString:legacyHeader]) {
                            NSString *content = [NSString stringWithContentsOfFile:fallbackPath encoding:NSUTF8StringEncoding error:nil];
                            if (content && [content hasPrefix:legacyHeader]) {
                                NSString *newContent = [header stringByAppendingString:[content substringFromIndex:legacyHeader.length]];
                                [newContent writeToFile:fallbackPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                            }
                        }
                    }
                }
            }

            handle = [NSFileHandle fileHandleForWritingAtPath:fallbackPath];
            logPath = fallbackPath;
            self.resolvedLogPath = logPath;
            if (!self.didLogFallbackPath) {
                NSLog(@"广告事件记录文件改写入沙盒路径：%@", logPath);
                self.didLogFallbackPath = YES;
            }
        }
        if (!handle) {
            return;
        }

        self.sequence += 1;
        NSString *line = [NSString stringWithFormat:@"%@,%lld,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@\n",
                          [self csvValue:timestamp],
                          self.sequence,
                          [self csvValue:self.appSessionId],
                          [self csvValue:adSessionId ?: @""],
                          [self csvValue:adRequestId ?: @""],
                          [self csvValue:adType ?: @""],
                          [self csvValue:event ?: @""],
                          [self csvValue:adUnitId ?: @""],
                          [self csvValue:screen ?: @""],
                          [self csvValue:result ?: @""],
                          [self csvValue:detail ?: @""],
                          [self csvValue:x],
                          [self csvValue:y],
                          [self csvValue:w],
                          [self csvValue:h]];
        @try {
            [handle seekToEndOfFile];
            [handle writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
        } @catch (__unused NSException *exception) {
        } @finally {
            [handle closeFile];
        }
    }
}

@end
