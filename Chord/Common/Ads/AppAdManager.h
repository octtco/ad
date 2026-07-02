//
//  AppAdManager.h
//  Chord
//

#import <Foundation/Foundation.h>
#import "AppAdProviderProtocol.h"

@class AppAdConfig;
@class UIViewController;

NS_ASSUME_NONNULL_BEGIN

@interface AppAdManager : NSObject

@property (nonatomic, strong, readonly, nullable) AppAdConfig *config;
@property (nonatomic, strong, readonly, nullable) id<AppAdProviderProtocol> provider;
@property (nonatomic, assign, readonly, getter=isReady) BOOL ready;
@property (nonatomic, assign, readonly, getter=isOAAEnvironment) BOOL OAAEnvironment;
@property (nonatomic, copy, readonly) NSString *idfa;

+ (instancetype)sharedManager;

- (void)setupWithConfig:(AppAdConfig *)config;
- (void)registerProviderClass:(Class)providerClass forName:(NSString *)providerName;
- (void)showAppOpenAdFromViewController:(UIViewController *)viewController;
- (void)showAppOpenAdFromViewController:(UIViewController *)viewController completion:(void (^ _Nullable)(void))completion;
- (void)showBannerAdInViewController:(UIViewController *)viewController;
- (void)showInterstitialAdFromViewController:(UIViewController *)viewController;
- (void)showRewardedAdFromViewController:(UIViewController *)viewController;

- (void)showSplashAdFromViewController:(UIViewController *)viewController completion:(void (^ _Nullable)(void))completion;
- (void)showHomeBannerAdInViewController:(UIViewController *)viewController;
- (void)showHotStartAdFromViewController:(UIViewController *)viewController;
- (void)showManualButtonAdAtIndex:(NSInteger)index fromViewController:(UIViewController *)viewController;

- (void)applicationDidBecomeActive;
- (void)applicationWillEnterForeground;
- (void)applicationDidEnterBackground;

@end

NS_ASSUME_NONNULL_END
