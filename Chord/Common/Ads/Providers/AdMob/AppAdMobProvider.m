//
//  AppAdMobProvider.m
//  TemplateApp
//

#import "AppAdMobProvider.h"
#import "AppAdConfig.h"
#import "AdEventManager.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface AppAdMobProvider () <GADFullScreenContentDelegate, GADBannerViewDelegate>

@property (nonatomic, assign, readwrite, getter=isReady) BOOL ready;
@property (nonatomic, strong) AppAdConfig *config;
@property (nonatomic, strong) GADAppOpenAd *appOpenAd;
@property (nonatomic, strong) NSDate *appOpenAdLoadTime;
@property (nonatomic, copy, nullable) void (^appOpenAdCompletion)(void);
@property (nonatomic, strong) GADBannerView *bannerView;
@property (nonatomic, strong) GADInterstitialAd *interstitialAd;
@property (nonatomic, weak) UIViewController *pendingInterstitialViewController;
@property (nonatomic, strong) GADRewardedAd *rewardedAd;
@property (nonatomic, weak) UIViewController *pendingRewardedViewController;
@property (nonatomic, assign, getter=isLoadingAppOpenAd) BOOL loadingAppOpenAd;
@property (nonatomic, assign, getter=isShowingAppOpenAd) BOOL showingAppOpenAd;
@property (nonatomic, assign, getter=isLoadingInterstitialAd) BOOL loadingInterstitialAd;
@property (nonatomic, assign, getter=isShowingInterstitialAd) BOOL showingInterstitialAd;
@property (nonatomic, assign, getter=isLoadingRewardedAd) BOOL loadingRewardedAd;
@property (nonatomic, assign, getter=isShowingRewardedAd) BOOL showingRewardedAd;

// 广告事件日志 - session/request ID
@property (nonatomic, copy) NSString *appOpenAdSessionId;
@property (nonatomic, copy) NSString *appOpenAdRequestId;
@property (nonatomic, copy) NSString *interstitialAdSessionId;
@property (nonatomic, copy) NSString *interstitialAdRequestId;
@property (nonatomic, copy) NSString *rewardedAdSessionId;
@property (nonatomic, copy) NSString *rewardedAdRequestId;
@property (nonatomic, copy) NSString *bannerAdSessionId;
@property (nonatomic, copy) NSString *bannerAdRequestId;

@end

@implementation AppAdMobProvider

- (void)setupWithConfig:(AppAdConfig *)config {
    self.config = config;
    NSDictionary *providerConfig = [config activeProviderConfig];
    id enabled = providerConfig[@"enabled"];
    if (!config.isEnabled || ![enabled respondsToSelector:@selector(boolValue)] || ![enabled boolValue]) {
        self.ready = NO;
        return;
    }

    [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status) {
        self.ready = YES;
        [self logAdEventWithType:@"sdk_init" event:@"init_success" adSessionId:@"" adRequestId:@"" adUnitId:@"" result:@"success" detail:@""];
#if DEBUG
        NSLog(@"[Ads] AdMob initialized: %@", status.adapterStatusesByClassName);
#endif
        // App Open 绑定启动页生命周期，避免预加载完成后拿已下线的启动页展示。
        [self loadInterstitialAdWithCompletion:nil];
        [self loadRewardedAdWithCompletion:nil];
    }];
}

- (void)showAppOpenAdFromViewController:(UIViewController *)viewController {
    [self showAppOpenAdFromViewController:viewController completion:nil];
}

- (void)showAppOpenAdFromViewController:(UIViewController *)viewController completion:(void (^)(void))completion {
    if (self.isShowingAppOpenAd) {
#if DEBUG
        NSLog(@"[Ads] AdMob app open is already showing");
#endif
        [self logAdEventWithType:@"app_open" event:@"show_skip_already_showing" adSessionId:[self ensureAppOpenAdSessionId] adRequestId:[self ensureAppOpenAdRequestId] adUnitId:[self appOpenAdUnitID] result:@"skip" detail:@""];
        if (completion) {
            completion();
        }
        return;
    }

    self.appOpenAdCompletion = completion;
    [self ensureAppOpenAdSessionId];
    [self ensureAppOpenAdRequestId];
    [self logAdEventWithType:@"app_open" event:@"show_attempt" adSessionId:self.appOpenAdSessionId adRequestId:self.appOpenAdRequestId adUnitId:[self appOpenAdUnitID] result:@"attempt" detail:@""];

    if (self.appOpenAd && [self isAppOpenAdAvailable]) {
        [self presentAppOpenAdFromViewController:viewController];
        return;
    }

    self.appOpenAd = nil;
    self.appOpenAdLoadTime = nil;
    [self loadAppOpenAdWithCompletion:^{
        [self presentAppOpenAdFromViewController:viewController];
    }];
}

- (void)loadAppOpenAdWithCompletion:(void (^)(void))completion {
    if (self.isLoadingAppOpenAd) {
        [self logAdEventWithType:@"app_open" event:@"load_skip" adSessionId:[self ensureAppOpenAdSessionId] adRequestId:[self ensureAppOpenAdRequestId] adUnitId:[self appOpenAdUnitID] result:@"skip" detail:@"already_loading"];
        return;
    }

    NSString *adUnitID = [self appOpenAdUnitID];
    if (adUnitID.length == 0) {
#if DEBUG
        NSLog(@"[Ads] AdMob app open ad unit id is empty");
#endif
        [self logAdEventWithType:@"app_open" event:@"load_skip" adSessionId:[self ensureAppOpenAdSessionId] adRequestId:[self ensureAppOpenAdRequestId] adUnitId:@"" result:@"skip" detail:@"empty_unit_id"];
        [self completeAppOpenAdIfNeeded];
        return;
    }

    [self ensureAppOpenAdSessionId];
    [self ensureAppOpenAdRequestId];
    NSString *sessionId = self.appOpenAdSessionId;
    NSString *requestId = [[NSUUID UUID] UUIDString];
    self.appOpenAdRequestId = requestId;
    [self logAdEventWithType:@"app_open" event:@"load_start" adSessionId:sessionId adRequestId:requestId adUnitId:adUnitID result:@"start" detail:@""];

    self.loadingAppOpenAd = YES;
    // 10秒超时兜底：防止 GAD 回调永不触发导致 loading 标记死锁
    __block BOOL didTimeout = NO;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf.loadingAppOpenAd) {
            didTimeout = YES;
            weakSelf.loadingAppOpenAd = NO;
#if DEBUG
            NSLog(@"[Ads] AdMob app open load timeout");
#endif
            [weakSelf completeAppOpenAdIfNeeded];
        }
    });
    [GADAppOpenAd loadWithAdUnitID:adUnitID request:[GADRequest request] completionHandler:^(GADAppOpenAd *appOpenAd, NSError *error) {
        if (didTimeout) {
            return;
        }
        self.loadingAppOpenAd = NO;
        if (error) {
#if DEBUG
            NSLog(@"[Ads] AdMob app open load failed: %@", error);
#endif
            [self logAdEventWithType:@"app_open" event:@"load_fail" adSessionId:sessionId adRequestId:requestId adUnitId:adUnitID result:@"fail" detail:error.localizedDescription ?: @"unknown"];
            [self completeAppOpenAdIfNeeded];
            return;
        }

        self.appOpenAd = appOpenAd;
        self.appOpenAdLoadTime = [NSDate date];
        self.appOpenAd.fullScreenContentDelegate = self;
        [self logAdEventWithType:@"app_open" event:@"load_success" adSessionId:sessionId adRequestId:requestId adUnitId:adUnitID result:@"success" detail:@""];
#if DEBUG
        NSLog(@"[Ads] AdMob app open loaded");
#endif
        if (completion) {
            completion();
        }
    }];
}

- (void)presentAppOpenAdFromViewController:(UIViewController *)viewController {
    if (!viewController.view.window) {
        [self logAdEventWithType:@"app_open" event:@"show_fail_view_not_visible" adSessionId:self.appOpenAdSessionId ?: @"" adRequestId:self.appOpenAdRequestId ?: @"" adUnitId:[self appOpenAdUnitID] result:@"fail" detail:@"view_controller_not_visible"];
        [self completeAppOpenAdIfNeeded];
        return;
    }

    if (!self.appOpenAd) {
        [self logAdEventWithType:@"app_open" event:@"show_fail_no_ad" adSessionId:self.appOpenAdSessionId ?: @"" adRequestId:self.appOpenAdRequestId ?: @"" adUnitId:[self appOpenAdUnitID] result:@"fail" detail:@"ad_is_nil"];
        [self completeAppOpenAdIfNeeded];
        return;
    }

    NSError *error = nil;
    if (![self.appOpenAd canPresentFromRootViewController:viewController error:&error]) {
#if DEBUG
        NSLog(@"[Ads] AdMob app open can not present: %@", error);
#endif
        [self logAdEventWithType:@"app_open" event:@"show_fail_can_present" adSessionId:self.appOpenAdSessionId ?: @"" adRequestId:self.appOpenAdRequestId ?: @"" adUnitId:[self appOpenAdUnitID] result:@"fail" detail:error.localizedDescription ?: @"unknown"];
        self.appOpenAd = nil;
        self.appOpenAdLoadTime = nil;
        [self completeAppOpenAdIfNeeded];
        return;
    }

    [self logAdEventWithType:@"app_open" event:@"show_present_called" adSessionId:self.appOpenAdSessionId ?: @"" adRequestId:self.appOpenAdRequestId ?: @"" adUnitId:[self appOpenAdUnitID] result:@"success" detail:@""];
    [self.appOpenAd presentFromRootViewController:viewController];
}

- (void)showInterstitialAdFromViewController:(UIViewController *)viewController {
    if (self.isShowingInterstitialAd) {
#if DEBUG
        NSLog(@"[Ads] AdMob interstitial is already showing");
#endif
        [self logAdEventWithType:@"interstitial" event:@"show_skip_already_showing" adSessionId:[self ensureInterstitialAdSessionId] adRequestId:[self ensureInterstitialAdRequestId] adUnitId:[self interstitialAdUnitID] result:@"skip" detail:@""];
        return;
    }

    [self ensureInterstitialAdSessionId];
    [self ensureInterstitialAdRequestId];
    [self logAdEventWithType:@"interstitial" event:@"show_attempt" adSessionId:self.interstitialAdSessionId adRequestId:self.interstitialAdRequestId adUnitId:[self interstitialAdUnitID] result:@"attempt" detail:@""];

    if (self.interstitialAd) {
        [self presentInterstitialAdFromViewController:viewController];
        return;
    }

    if (self.isLoadingInterstitialAd) {
        self.pendingInterstitialViewController = viewController;
        return;
    }

    [self loadInterstitialAdWithCompletion:^{
        [self presentInterstitialAdFromViewController:viewController];
    }];
}

- (void)loadInterstitialAdWithCompletion:(void (^)(void))completion {
    if (self.isLoadingInterstitialAd) {
        [self logAdEventWithType:@"interstitial" event:@"load_skip" adSessionId:[self ensureInterstitialAdSessionId] adRequestId:[self ensureInterstitialAdRequestId] adUnitId:[self interstitialAdUnitID] result:@"skip" detail:@"already_loading"];
        return;
    }

    NSString *adUnitID = [self interstitialAdUnitID];
    if (adUnitID.length == 0) {
#if DEBUG
        NSLog(@"[Ads] AdMob interstitial ad unit id is empty");
#endif
        [self logAdEventWithType:@"interstitial" event:@"load_skip" adSessionId:[self ensureInterstitialAdSessionId] adRequestId:[self ensureInterstitialAdRequestId] adUnitId:@"" result:@"skip" detail:@"empty_unit_id"];
        return;
    }

    [self ensureInterstitialAdSessionId];
    [self ensureInterstitialAdRequestId];
    NSString *sessionId = self.interstitialAdSessionId;
    NSString *requestId = [[NSUUID UUID] UUIDString];
    self.interstitialAdRequestId = requestId;
    [self logAdEventWithType:@"interstitial" event:@"load_start" adSessionId:sessionId adRequestId:requestId adUnitId:adUnitID result:@"start" detail:@""];

    self.loadingInterstitialAd = YES;
    // 10秒超时兜底：防止 GAD 回调永不触发导致 loading 标记死锁
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf.loadingInterstitialAd) {
            weakSelf.loadingInterstitialAd = NO;
            weakSelf.pendingInterstitialViewController = nil;
#if DEBUG
            NSLog(@"[Ads] AdMob interstitial load timeout");
#endif
        }
    });
    [GADInterstitialAd loadWithAdUnitID:adUnitID request:[GADRequest request] completionHandler:^(GADInterstitialAd *interstitialAd, NSError *error) {
        self.loadingInterstitialAd = NO;
        if (error) {
            self.pendingInterstitialViewController = nil;
#if DEBUG
            NSLog(@"[Ads] AdMob interstitial load failed: %@", error);
#endif
            [self logAdEventWithType:@"interstitial" event:@"load_fail" adSessionId:sessionId adRequestId:requestId adUnitId:adUnitID result:@"fail" detail:error.localizedDescription ?: @"unknown"];
            return;
        }

        self.interstitialAd = interstitialAd;
        self.interstitialAd.fullScreenContentDelegate = self;
        [self logAdEventWithType:@"interstitial" event:@"load_success" adSessionId:sessionId adRequestId:requestId adUnitId:adUnitID result:@"success" detail:@""];
#if DEBUG
        NSLog(@"[Ads] AdMob interstitial loaded");
#endif
        UIViewController *pendingViewController = self.pendingInterstitialViewController;
        self.pendingInterstitialViewController = nil;
        if (pendingViewController) {
            [self presentInterstitialAdFromViewController:pendingViewController];
            return;
        }
        if (completion) {
            completion();
        }
    }];
}

- (void)presentInterstitialAdFromViewController:(UIViewController *)viewController {
    NSString *blocker = [self adPresentationBlockerForViewController:viewController];
    if (blocker.length > 0) {
        [self logAdEventWithType:@"interstitial" event:@"show_skip_not_ready" adSessionId:self.interstitialAdSessionId ?: @"" adRequestId:self.interstitialAdRequestId ?: @"" adUnitId:[self interstitialAdUnitID] result:@"skip" detail:blocker];
        return;
    }

    if (!self.interstitialAd) {
        [self logAdEventWithType:@"interstitial" event:@"show_fail_no_ad" adSessionId:self.interstitialAdSessionId ?: @"" adRequestId:self.interstitialAdRequestId ?: @"" adUnitId:[self interstitialAdUnitID] result:@"fail" detail:@"ad_is_nil"];
        return;
    }

    NSError *error = nil;
    if (![self.interstitialAd canPresentFromRootViewController:viewController error:&error]) {
#if DEBUG
        NSLog(@"[Ads] AdMob interstitial can not present: %@", error);
#endif
        [self logAdEventWithType:@"interstitial" event:@"show_fail_can_present" adSessionId:self.interstitialAdSessionId ?: @"" adRequestId:self.interstitialAdRequestId ?: @"" adUnitId:[self interstitialAdUnitID] result:@"fail" detail:error.localizedDescription ?: @"unknown"];
        self.interstitialAd = nil;
        return;
    }

    [self logAdEventWithType:@"interstitial" event:@"show_present_called" adSessionId:self.interstitialAdSessionId ?: @"" adRequestId:self.interstitialAdRequestId ?: @"" adUnitId:[self interstitialAdUnitID] result:@"success" detail:@""];
    [self.interstitialAd presentFromRootViewController:viewController];
}

- (void)showRewardedAdFromViewController:(UIViewController *)viewController {
    if (self.isShowingRewardedAd) {
#if DEBUG
        NSLog(@"[Ads] AdMob rewarded is already showing");
#endif
        [self logAdEventWithType:@"rewarded" event:@"show_skip_already_showing" adSessionId:[self ensureRewardedAdSessionId] adRequestId:[self ensureRewardedAdRequestId] adUnitId:[self rewardedAdUnitID] result:@"skip" detail:@""];
        return;
    }

    [self ensureRewardedAdSessionId];
    [self ensureRewardedAdRequestId];
    [self logAdEventWithType:@"rewarded" event:@"show_attempt" adSessionId:self.rewardedAdSessionId adRequestId:self.rewardedAdRequestId adUnitId:[self rewardedAdUnitID] result:@"attempt" detail:@""];

    if (self.rewardedAd) {
        [self presentRewardedAdFromViewController:viewController];
        return;
    }

    if (self.isLoadingRewardedAd) {
        self.pendingRewardedViewController = viewController;
        return;
    }

    [self loadRewardedAdWithCompletion:^{
        [self presentRewardedAdFromViewController:viewController];
    }];
}

- (void)loadRewardedAdWithCompletion:(void (^)(void))completion {
    if (self.isLoadingRewardedAd) {
        [self logAdEventWithType:@"rewarded" event:@"load_skip" adSessionId:[self ensureRewardedAdSessionId] adRequestId:[self ensureRewardedAdRequestId] adUnitId:[self rewardedAdUnitID] result:@"skip" detail:@"already_loading"];
        return;
    }

    NSString *adUnitID = [self rewardedAdUnitID];
    if (adUnitID.length == 0) {
#if DEBUG
        NSLog(@"[Ads] AdMob rewarded ad unit id is empty");
#endif
        [self logAdEventWithType:@"rewarded" event:@"load_skip" adSessionId:[self ensureRewardedAdSessionId] adRequestId:[self ensureRewardedAdRequestId] adUnitId:@"" result:@"skip" detail:@"empty_unit_id"];
        return;
    }

    [self ensureRewardedAdSessionId];
    [self ensureRewardedAdRequestId];
    NSString *sessionId = self.rewardedAdSessionId;
    NSString *requestId = [[NSUUID UUID] UUIDString];
    self.rewardedAdRequestId = requestId;
    [self logAdEventWithType:@"rewarded" event:@"load_start" adSessionId:sessionId adRequestId:requestId adUnitId:adUnitID result:@"start" detail:@""];

    self.loadingRewardedAd = YES;
    // 10秒超时兜底：防止 GAD 回调永不触发导致 loading 标记死锁
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf.loadingRewardedAd) {
            weakSelf.loadingRewardedAd = NO;
            weakSelf.pendingRewardedViewController = nil;
#if DEBUG
            NSLog(@"[Ads] AdMob rewarded load timeout");
#endif
        }
    });
    [GADRewardedAd loadWithAdUnitID:adUnitID request:[GADRequest request] completionHandler:^(GADRewardedAd *rewardedAd, NSError *error) {
        self.loadingRewardedAd = NO;
        if (error) {
            self.pendingRewardedViewController = nil;
#if DEBUG
            NSLog(@"[Ads] AdMob rewarded load failed: %@", error);
#endif
            [self logAdEventWithType:@"rewarded" event:@"load_fail" adSessionId:sessionId adRequestId:requestId adUnitId:adUnitID result:@"fail" detail:error.localizedDescription ?: @"unknown"];
            return;
        }

        self.rewardedAd = rewardedAd;
        self.rewardedAd.fullScreenContentDelegate = self;
        [self logAdEventWithType:@"rewarded" event:@"load_success" adSessionId:sessionId adRequestId:requestId adUnitId:adUnitID result:@"success" detail:@""];
#if DEBUG
        NSLog(@"[Ads] AdMob rewarded loaded");
#endif
        UIViewController *pendingViewController = self.pendingRewardedViewController;
        self.pendingRewardedViewController = nil;
        if (pendingViewController) {
            [self presentRewardedAdFromViewController:pendingViewController];
            return;
        }
        if (completion) {
            completion();
        }
    }];
}

- (void)presentRewardedAdFromViewController:(UIViewController *)viewController {
    NSString *blocker = [self adPresentationBlockerForViewController:viewController];
    if (blocker.length > 0) {
        [self logAdEventWithType:@"rewarded" event:@"show_skip_not_ready" adSessionId:self.rewardedAdSessionId ?: @"" adRequestId:self.rewardedAdRequestId ?: @"" adUnitId:[self rewardedAdUnitID] result:@"skip" detail:blocker];
        return;
    }

    if (!self.rewardedAd) {
        [self logAdEventWithType:@"rewarded" event:@"show_fail_no_ad" adSessionId:self.rewardedAdSessionId ?: @"" adRequestId:self.rewardedAdRequestId ?: @"" adUnitId:[self rewardedAdUnitID] result:@"fail" detail:@"ad_is_nil"];
        return;
    }

    [self logAdEventWithType:@"rewarded" event:@"show_present_called" adSessionId:self.rewardedAdSessionId ?: @"" adRequestId:self.rewardedAdRequestId ?: @"" adUnitId:[self rewardedAdUnitID] result:@"success" detail:@""];
    [self.rewardedAd presentFromRootViewController:viewController userDidEarnRewardHandler:^{
        GADAdReward *reward = self.rewardedAd.adReward;
#if DEBUG
        NSLog(@"[Ads] AdMob rewarded earned reward: %@ %@", reward.amount, reward.type);
#endif
        [self logAdEventWithType:@"rewarded" event:@"reward_earned" adSessionId:self.rewardedAdSessionId ?: @"" adRequestId:self.rewardedAdRequestId ?: @"" adUnitId:[self rewardedAdUnitID] result:@"success" detail:[NSString stringWithFormat:@"amount=%@,type=%@", reward.amount, reward.type]];
    }];
}

- (void)showBannerAdInViewController:(UIViewController *)viewController {
    NSString *adUnitID = [self bannerAdUnitID];
    if (adUnitID.length == 0) {
#if DEBUG
        NSLog(@"[Ads] AdMob banner ad unit id is empty");
#endif
        [self logAdEventWithType:@"banner" event:@"show_skip" adSessionId:[self ensureBannerAdSessionId] adRequestId:[self ensureBannerAdRequestId] adUnitId:@"" result:@"skip" detail:@"empty_unit_id"];
        return;
    }

    [self ensureBannerAdSessionId];
    [self ensureBannerAdRequestId];
    NSString *requestId = [[NSUUID UUID] UUIDString];
    self.bannerAdRequestId = requestId;
    [self logAdEventWithType:@"banner" event:@"load_start" adSessionId:self.bannerAdSessionId adRequestId:requestId adUnitId:adUnitID result:@"start" detail:@""];

    if (!self.bannerView) {
        self.bannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeBanner];
        self.bannerView.delegate = self;
    }

    self.bannerView.adUnitID = adUnitID;
    self.bannerView.rootViewController = viewController;

    if (self.bannerView.superview != viewController.view) {
        [self.bannerView removeFromSuperview];
        self.bannerView.translatesAutoresizingMaskIntoConstraints = NO;
        [viewController.view addSubview:self.bannerView];
        [NSLayoutConstraint activateConstraints:@[
            [self.bannerView.centerXAnchor constraintEqualToAnchor:viewController.view.centerXAnchor],
            [self.bannerView.bottomAnchor constraintEqualToAnchor:viewController.view.safeAreaLayoutGuide.bottomAnchor]
        ]];
    }

    [viewController.view bringSubviewToFront:self.bannerView];
    [self.bannerView loadRequest:[GADRequest request]];
}

- (BOOL)isAppOpenAdAvailable {
    if (!self.appOpenAd || !self.appOpenAdLoadTime) {
        return NO;
    }

    NSTimeInterval maxCacheDuration = 4 * 60 * 60;
    return [[NSDate date] timeIntervalSinceDate:self.appOpenAdLoadTime] < maxCacheDuration;
}

- (NSString *)adPresentationBlockerForViewController:(UIViewController *)viewController {
    if (!viewController) {
        return @"view_controller_nil";
    }

    if (UIApplication.sharedApplication.applicationState != UIApplicationStateActive) {
        return @"app_not_active";
    }

    if (!viewController.view.window) {
        return @"view_controller_not_visible";
    }

    if (viewController.presentedViewController) {
        return @"view_controller_already_presenting";
    }

    return @"";
}

- (void)completeAppOpenAdIfNeeded {
    if (!self.appOpenAdCompletion) {
        return;
    }

    void (^completion)(void) = self.appOpenAdCompletion;
    self.appOpenAdCompletion = nil;
    completion();
}

- (NSString *)appOpenAdUnitID {
    NSDictionary *providerConfig = [self.config activeProviderConfig];
    NSDictionary *slots = providerConfig[@"slots"];
    NSString *splash = [slots isKindOfClass:[NSDictionary class]] ? slots[@"splash"] : @"";
    return [splash isKindOfClass:[NSString class]] ? splash : @"";
}

- (NSString *)bannerAdUnitID {
    NSDictionary *providerConfig = [self.config activeProviderConfig];
    NSDictionary *slots = providerConfig[@"slots"];
    NSString *banner = [slots isKindOfClass:[NSDictionary class]] ? slots[@"banner"] : @"";
    return [banner isKindOfClass:[NSString class]] ? banner : @"";
}

- (NSString *)interstitialAdUnitID {
    NSDictionary *providerConfig = [self.config activeProviderConfig];
    NSDictionary *slots = providerConfig[@"slots"];
    NSString *interstitial = [slots isKindOfClass:[NSDictionary class]] ? slots[@"interstitial"] : @"";
    return [interstitial isKindOfClass:[NSString class]] ? interstitial : @"";
}

- (NSString *)rewardedAdUnitID {
    NSDictionary *providerConfig = [self.config activeProviderConfig];
    NSDictionary *slots = providerConfig[@"slots"];
    NSString *rewarded = [slots isKindOfClass:[NSDictionary class]] ? slots[@"rewarded"] : @"";
    return [rewarded isKindOfClass:[NSString class]] ? rewarded : @"";
}

#pragma mark - Event Logging Helpers

- (NSString *)currentScreenName {
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        vc = window.rootViewController;
                        break;
                    }
                }
                break;
            }
        }
    }
    while (vc) {
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        } else if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController *)vc).visibleViewController;
        } else if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController *)vc).selectedViewController;
        } else {
            break;
        }
    }
    return vc ? NSStringFromClass([vc class]) : @"";
}

- (NSString *)ensureAppOpenAdSessionId {
    if (!self.appOpenAdSessionId) {
        self.appOpenAdSessionId = [[NSUUID UUID] UUIDString];
    }
    return self.appOpenAdSessionId;
}

- (NSString *)ensureAppOpenAdRequestId {
    if (!self.appOpenAdRequestId) {
        self.appOpenAdRequestId = [[NSUUID UUID] UUIDString];
    }
    return self.appOpenAdRequestId;
}

- (NSString *)ensureInterstitialAdSessionId {
    if (!self.interstitialAdSessionId) {
        self.interstitialAdSessionId = [[NSUUID UUID] UUIDString];
    }
    return self.interstitialAdSessionId;
}

- (NSString *)ensureInterstitialAdRequestId {
    if (!self.interstitialAdRequestId) {
        self.interstitialAdRequestId = [[NSUUID UUID] UUIDString];
    }
    return self.interstitialAdRequestId;
}

- (NSString *)ensureRewardedAdSessionId {
    if (!self.rewardedAdSessionId) {
        self.rewardedAdSessionId = [[NSUUID UUID] UUIDString];
    }
    return self.rewardedAdSessionId;
}

- (NSString *)ensureRewardedAdRequestId {
    if (!self.rewardedAdRequestId) {
        self.rewardedAdRequestId = [[NSUUID UUID] UUIDString];
    }
    return self.rewardedAdRequestId;
}

- (NSString *)ensureBannerAdSessionId {
    if (!self.bannerAdSessionId) {
        self.bannerAdSessionId = [[NSUUID UUID] UUIDString];
    }
    return self.bannerAdSessionId;
}

- (NSString *)ensureBannerAdRequestId {
    if (!self.bannerAdRequestId) {
        self.bannerAdRequestId = [[NSUUID UUID] UUIDString];
    }
    return self.bannerAdRequestId;
}

- (void)logAdEventWithType:(NSString *)adType
                     event:(NSString *)event
               adSessionId:(NSString *)adSessionId
               adRequestId:(NSString *)adRequestId
                  adUnitId:(NSString *)adUnitId
                    result:(NSString *)result
                    detail:(NSString *)detail {
    [[AdEventManager sharedInstance] logAdEventWithType:adType
                                                  event:event
                                            adSessionId:adSessionId
                                            adRequestId:adRequestId
                                               adUnitId:adUnitId
                                              adProvider:@"admob"
                                                 screen:[self currentScreenName]
                                                 result:result
                                                 detail:detail];
}

- (void)logAdEventWithType:(NSString *)adType
                     event:(NSString *)event
               adSessionId:(NSString *)adSessionId
               adRequestId:(NSString *)adRequestId
                  adUnitId:(NSString *)adUnitId
                    result:(NSString *)result
                    detail:(NSString *)detail
                   adFrame:(CGRect)adFrame {
    [[AdEventManager sharedInstance] logAdEventWithType:adType
                                                  event:event
                                            adSessionId:adSessionId
                                            adRequestId:adRequestId
                                               adUnitId:adUnitId
                                              adProvider:@"admob"
                                                 screen:[self currentScreenName]
                                                 result:result
                                                 detail:detail
                                                adFrame:adFrame];
}

#pragma mark - GADBannerViewDelegate

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    bannerView.alpha = 0;
    [UIView animateWithDuration:1.0 animations:^{
        bannerView.alpha = 1;
    }];
    [self logAdEventWithType:@"banner" event:@"load_success" adSessionId:self.bannerAdSessionId ?: @"" adRequestId:self.bannerAdRequestId ?: @"" adUnitId:[self bannerAdUnitID] result:@"success" detail:@""];
#if DEBUG
    NSLog(@"[Ads] AdMob banner loaded");
#endif
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    [self logAdEventWithType:@"banner" event:@"load_fail" adSessionId:self.bannerAdSessionId ?: @"" adRequestId:self.bannerAdRequestId ?: @"" adUnitId:[self bannerAdUnitID] result:@"fail" detail:error.localizedDescription ?: @"unknown"];
#if DEBUG
    NSLog(@"[Ads] AdMob banner load failed: %@", error);
#endif
}

- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView {
    [self logAdEventWithType:@"banner" event:@"callback_impression" adSessionId:self.bannerAdSessionId ?: @"" adRequestId:self.bannerAdRequestId ?: @"" adUnitId:[self bannerAdUnitID] result:@"impression" detail:@"" adFrame:bannerView.frame];
#if DEBUG
    NSLog(@"[Ads] AdMob banner recorded an impression");
#endif
}

- (void)bannerViewDidRecordClick:(GADBannerView *)bannerView {
    [self logAdEventWithType:@"banner" event:@"callback_click" adSessionId:self.bannerAdSessionId ?: @"" adRequestId:self.bannerAdRequestId ?: @"" adUnitId:[self bannerAdUnitID] result:@"click" detail:@""];
#if DEBUG
    NSLog(@"[Ads] AdMob banner recorded a click");
#endif
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView {
#if DEBUG
    NSLog(@"[Ads] AdMob banner will present screen");
#endif
}

- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView {
#if DEBUG
    NSLog(@"[Ads] AdMob banner will dismiss screen");
#endif
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView {
#if DEBUG
    NSLog(@"[Ads] AdMob banner did dismiss screen");
#endif
}

#pragma mark - GADFullScreenContentDelegate

- (void)adDidRecordImpression:(id<GADFullScreenPresentingAd>)ad {
    [self logFullScreenAdEvent:@"callback_impression" result:@"impression" ad:ad detail:@"" adFrame:UIScreen.mainScreen.bounds];
#if DEBUG
    NSLog(@"[Ads] AdMob %@ recorded an impression", [self fullScreenAdName:ad]);
#endif
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad {
    [self logFullScreenAdEvent:@"callback_click" result:@"click" ad:ad];
#if DEBUG
    NSLog(@"[Ads] AdMob %@ recorded a click", [self fullScreenAdName:ad]);
#endif
}

- (void)adWillPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
    [self logFullScreenAdEvent:@"callback_will_present" result:@"will_present" ad:ad];
    if (ad == self.appOpenAd) {
        self.showingAppOpenAd = YES;
    } else if (ad == self.interstitialAd) {
        self.showingInterstitialAd = YES;
    } else if (ad == self.rewardedAd) {
        self.showingRewardedAd = YES;
    }
#if DEBUG
    NSLog(@"[Ads] AdMob %@ will present", [self fullScreenAdName:ad]);
#endif
}

- (void)adWillDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
    [self logFullScreenAdEvent:@"callback_will_dismiss" result:@"will_dismiss" ad:ad];
#if DEBUG
    NSLog(@"[Ads] AdMob %@ will dismiss", [self fullScreenAdName:ad]);
#endif
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
    [self logFullScreenAdEvent:@"callback_did_dismiss" result:@"did_dismiss" ad:ad];
    if (ad == self.appOpenAd) {
        self.showingAppOpenAd = NO;
        self.appOpenAd = nil;
        self.appOpenAdLoadTime = nil;
        self.appOpenAdSessionId = nil;
        self.appOpenAdRequestId = nil;
        [self completeAppOpenAdIfNeeded];
    } else if (ad == self.interstitialAd) {
        self.showingInterstitialAd = NO;
        self.interstitialAd = nil;
        self.interstitialAdSessionId = nil;
        self.interstitialAdRequestId = nil;
        // 补充预加载：dismiss 后立即加载下一条，下次秒出
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self loadInterstitialAdWithCompletion:nil];
        });
    } else if (ad == self.rewardedAd) {
        self.showingRewardedAd = NO;
        self.rewardedAd = nil;
        self.rewardedAdSessionId = nil;
        self.rewardedAdRequestId = nil;
        // 补充预加载：dismiss 后立即加载下一条，下次秒出
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self loadRewardedAdWithCompletion:nil];
        });
    }
#if DEBUG
    NSLog(@"[Ads] AdMob %@ dismissed", [self fullScreenAdName:ad]);
#endif
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
    [self logFullScreenAdEvent:@"callback_fail_to_present" result:@"fail_to_present" ad:ad detail:error.localizedDescription ?: @"unknown"];
#if DEBUG
    NSLog(@"[Ads] AdMob %@ present failed: %@", [self fullScreenAdName:ad], error);
#endif
    if (ad == self.appOpenAd) {
        self.showingAppOpenAd = NO;
        self.appOpenAd = nil;
        self.appOpenAdLoadTime = nil;
        self.appOpenAdSessionId = nil;
        self.appOpenAdRequestId = nil;
        [self completeAppOpenAdIfNeeded];
    } else if (ad == self.interstitialAd) {
        self.showingInterstitialAd = NO;
        self.interstitialAd = nil;
        self.interstitialAdSessionId = nil;
        self.interstitialAdRequestId = nil;
    } else if (ad == self.rewardedAd) {
        self.showingRewardedAd = NO;
        self.rewardedAd = nil;
        self.rewardedAdSessionId = nil;
        self.rewardedAdRequestId = nil;
    }
}

- (void)logFullScreenAdEvent:(NSString *)event result:(NSString *)result ad:(id<GADFullScreenPresentingAd>)ad {
    [self logFullScreenAdEvent:event result:result ad:ad detail:@""];
}

- (void)logFullScreenAdEvent:(NSString *)event result:(NSString *)result ad:(id<GADFullScreenPresentingAd>)ad detail:(NSString *)detail {
    [self logFullScreenAdEvent:event result:result ad:ad detail:detail adFrame:CGRectNull];
}

- (void)logFullScreenAdEvent:(NSString *)event result:(NSString *)result ad:(id<GADFullScreenPresentingAd>)ad detail:(NSString *)detail adFrame:(CGRect)adFrame {
    NSString *adType = [self fullScreenAdName:ad];
    NSString *sessionId = @"";
    NSString *requestId = @"";
    NSString *adUnitId = @"";
    if (ad == self.appOpenAd) {
        sessionId = self.appOpenAdSessionId ?: @"";
        requestId = self.appOpenAdRequestId ?: @"";
        adUnitId = [self appOpenAdUnitID];
    } else if (ad == self.interstitialAd) {
        sessionId = self.interstitialAdSessionId ?: @"";
        requestId = self.interstitialAdRequestId ?: @"";
        adUnitId = [self interstitialAdUnitID];
    } else if (ad == self.rewardedAd) {
        sessionId = self.rewardedAdSessionId ?: @"";
        requestId = self.rewardedAdRequestId ?: @"";
        adUnitId = [self rewardedAdUnitID];
    }
    if (detail.length > 0) {
        [[AdEventManager sharedInstance] logAdEventWithType:adType event:event adSessionId:sessionId adRequestId:requestId adUnitId:adUnitId adProvider:@"admob" screen:[self currentScreenName] result:result detail:detail adFrame:adFrame];
    } else if (!CGRectIsNull(adFrame)) {
        [[AdEventManager sharedInstance] logAdEventWithType:adType event:event adSessionId:sessionId adRequestId:requestId adUnitId:adUnitId adProvider:@"admob" screen:[self currentScreenName] result:result detail:detail adFrame:adFrame];
    } else {
        [[AdEventManager sharedInstance] logAdEventWithType:adType event:event adSessionId:sessionId adRequestId:requestId adUnitId:adUnitId adProvider:@"admob" screen:[self currentScreenName] result:result detail:detail];
    }
}

- (NSString *)fullScreenAdName:(id<GADFullScreenPresentingAd>)ad {
    if (ad == self.appOpenAd) {
        return @"app open";
    }
    if (ad == self.interstitialAd) {
        return @"interstitial";
    }
    if (ad == self.rewardedAd) {
        return @"rewarded";
    }
    return @"full screen ad";
}

@end
