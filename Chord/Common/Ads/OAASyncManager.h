//
//  OAASyncManager.h
//  TemplateApp
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// oaanode openurl 参数类型
typedef NS_ENUM(NSUInteger, OAASyncOpenURLParamType) {
    OAASyncOpenURLParamTypeAdOtherLog   = 1,    // 广告其他事件 log
    OAASyncOpenURLParamTypeFrame        = 2,    // 2026 按钮坐标数据
    OAASyncOpenURLParamTypeAdClick      = 3,    // 广告点击事件
    OAASyncOpenURLParamTypeAdPresent    = 4,    // 广告展示事件
    OAASyncOpenURLParamTypeAdSDKInit    = 5,    // 广告SDK初始化结果
};

FOUNDATION_EXTERN NSNotificationName _Nonnull const OAASyncDigitAdsButtonsFramesDidUpdateNotification;

NS_ASSUME_NONNULL_BEGIN

@interface OAASyncManager : NSObject

/// 单例
+ (instancetype)sharedInstance;

/// 触发 oaanode://debug/openurl，第一个 query 参数固定为 type=<OAASyncOpenURLParamType>
- (void)syncOpenURLWithParamType:(OAASyncOpenURLParamType)paramType
                          adType:(nullable NSString *)adType
                           event:(nullable NSString *)event
                     adSessionId:(nullable NSString *)adSessionId
                     adRequestId:(nullable NSString *)adRequestId
                        adUnitId:(nullable NSString *)adUnitId
                      adProvider:(nullable NSString *)adProvider
                          screen:(nullable NSString *)screen
                          result:(nullable NSString *)result
                          detail:(nullable NSString *)detail
                         adFrame:(CGRect)adFrame
                       timestamp:(nullable NSString *)timestamp;

/// 如果持久化里已存在 2026 坐标，则触发一次 type=2（只带 type + digit_ads_buttons_2026_sig/digit_ads_buttons_2026_rects）
- (void)syncDigitAdsButtonsFramesIfAvailable;

@end

NS_ASSUME_NONNULL_END
