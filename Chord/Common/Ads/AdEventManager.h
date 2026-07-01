//
//  AdEventManager.h
//  TemplateApp
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdEventManager : NSObject

/// 单例：负责统一写广告事件日志。
+ (instancetype)sharedInstance;

/// 记录一条广告事件到 CSV。
/// - Parameters:
///   - adType: 广告类型，例如 app_open、interstitial、rewarded、banner。
///   - event: 事件名，例如 load_start、show_present_called、callback_impression。
///   - adSessionId: 本次广告展示流程的会话 ID（同一条广告贯穿所有事件）。
///   - adRequestId: 本次广告请求的 ID（一次加载请求对应一个）。
///   - adUnitId: 广告位 ID。
///   - adProvider: 广告商，例如 admob、meta_an、mock。
///   - screen: 触发事件时的页面类名。
///   - result: 事件结果语义（start/success/fail/skip/timeout 等）。
///   - detail: 详细信息（错误描述、状态组合等）。
- (void)logAdEventWithType:(NSString *)adType
                   event:(NSString *)event
             adSessionId:(NSString *)adSessionId
             adRequestId:(NSString *)adRequestId
                adUnitId:(NSString *)adUnitId
              adProvider:(NSString *)adProvider
                  screen:(NSString *)screen
                  result:(NSString *)result
                  detail:(NSString *)detail;

- (void)logAdEventWithType:(NSString *)adType
                   event:(NSString *)event
             adSessionId:(NSString *)adSessionId
             adRequestId:(NSString *)adRequestId
                adUnitId:(NSString *)adUnitId
              adProvider:(NSString *)adProvider
                  screen:(NSString *)screen
                  result:(NSString *)result
                  detail:(NSString *)detail
                 adFrame:(CGRect)adFrame;

@end

NS_ASSUME_NONNULL_END
