//
//  AppAdProviderProtocol.h
//  Chord
//

#import <Foundation/Foundation.h>

@class AppAdConfig;
@class UIViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol AppAdProviderProtocol <NSObject>

@property (nonatomic, assign, readonly, getter=isReady) BOOL ready;

- (void)setupWithConfig:(AppAdConfig *)config;

@optional
- (void)showAppOpenAdFromViewController:(UIViewController *)viewController;
- (void)showAppOpenAdFromViewController:(UIViewController *)viewController completion:(void (^ _Nullable)(void))completion;
- (void)showBannerAdInViewController:(UIViewController *)viewController;
- (void)showInterstitialAdFromViewController:(UIViewController *)viewController;
- (void)showRewardedAdFromViewController:(UIViewController *)viewController;
- (void)applicationDidBecomeActive;
- (void)applicationWillEnterForeground;
- (void)applicationDidEnterBackground;

@end

NS_ASSUME_NONNULL_END
