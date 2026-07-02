//
//  AppAdManager.m
//  Chord
//

#import "AppAdManager.h"
#import "AppAdConfig.h"
#import "AppMockAdProvider.h"
#import "Providers/AdMob/AppAdMobProvider.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <objc/runtime.h>

@interface AppAdManager ()

@property (nonatomic, strong, readwrite, nullable) AppAdConfig *config;
@property (nonatomic, strong, readwrite, nullable) id<AppAdProviderProtocol> provider;
@property (nonatomic, strong) NSMutableDictionary<NSString *, Class> *providerClasses;

@end

@implementation AppAdManager

+ (instancetype)sharedManager {
    static AppAdManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AppAdManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _providerClasses = [NSMutableDictionary dictionary];
        [self registerProviderClass:AppMockAdProvider.class forName:@"mock"];
        [self registerProviderClass:AppAdMobProvider.class forName:@"admob"];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(requestTrackingAuthorizationIfNeeded)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)isReady {
    return self.provider.isReady;
}

- (BOOL)isOAAEnvironment {
    return objc_getClass("OAANodeContext") == Nil;
}

- (void)setupWithConfig:(AppAdConfig *)config {
    self.config = config;
    self.provider = nil;

    if (![config.strategy isEqualToString:@"primary"]) {
#if DEBUG
        NSLog(@"[Ads] Unsupported strategy: %@, fallback to primary", config.strategy);
#endif
    }

    NSString *providerName = config.primaryProvider;
    if (!config.isEnabled || providerName.length == 0 || [providerName isEqualToString:@"none"]) {
#if DEBUG
        NSLog(@"[Ads] Disabled");
#endif
        return;
    }

    NSDictionary *providerConfig = [config providerConfigForName:providerName];
    id providerEnabled = providerConfig[@"enabled"];
    if (![providerEnabled respondsToSelector:@selector(boolValue)] || ![providerEnabled boolValue]) {
#if DEBUG
        NSLog(@"[Ads] Provider disabled: %@", providerName);
#endif
        return;
    }

    Class providerClass = self.providerClasses[providerName];
    if (!providerClass) {
#if DEBUG
        NSLog(@"[Ads] Provider not registered: %@", providerName);
#endif
        return;
    }

    id provider = [[providerClass alloc] init];
    if (![provider conformsToProtocol:@protocol(AppAdProviderProtocol)]) {
#if DEBUG
        NSLog(@"[Ads] Provider does not conform protocol: %@", NSStringFromClass(providerClass));
#endif
        return;
    }

    self.provider = provider;
    [self.provider setupWithConfig:config];
}

- (void)registerProviderClass:(Class)providerClass forName:(NSString *)providerName {
    if (!providerClass || providerName.length == 0) {
        return;
    }
    self.providerClasses[providerName] = providerClass;
}

- (void)showAppOpenAdFromViewController:(UIViewController *)viewController {
    [self showAppOpenAdFromViewController:viewController completion:nil];
}

- (void)showAppOpenAdFromViewController:(UIViewController *)viewController completion:(void (^)(void))completion {
    if ([self.provider respondsToSelector:@selector(showAppOpenAdFromViewController:completion:)]) {
        [self.provider showAppOpenAdFromViewController:viewController completion:completion];
    } else if ([self.provider respondsToSelector:@selector(showAppOpenAdFromViewController:)]) {
        [self.provider showAppOpenAdFromViewController:viewController];
        if (completion) {
            completion();
        }
    } else if (completion) {
        completion();
    }
}

- (void)showBannerAdInViewController:(UIViewController *)viewController {
    if ([self.provider respondsToSelector:@selector(showBannerAdInViewController:)]) {
        [self.provider showBannerAdInViewController:viewController];
    }
}

- (void)showInterstitialAdFromViewController:(UIViewController *)viewController {
    if ([self.provider respondsToSelector:@selector(showInterstitialAdFromViewController:)]) {
        [self.provider showInterstitialAdFromViewController:viewController];
    }
}

- (void)showRewardedAdFromViewController:(UIViewController *)viewController {
    if ([self.provider respondsToSelector:@selector(showRewardedAdFromViewController:)]) {
        [self.provider showRewardedAdFromViewController:viewController];
    }
}

- (void)showSplashAdFromViewController:(UIViewController *)viewController completion:(void (^)(void))completion {
    if (self.isOAAEnvironment) {
        if (completion) {
            completion();
        }
        return;
    }

    [self showAppOpenAdFromViewController:viewController completion:completion];
}

- (void)showHomeBannerAdInViewController:(UIViewController *)viewController {
    if (self.isOAAEnvironment) {
        return;
    }

    [self showBannerAdInViewController:viewController];
}

- (void)showHotStartAdFromViewController:(UIViewController *)viewController {
    if (self.isOAAEnvironment) {
        return;
    }

    [self showInterstitialAdFromViewController:viewController];
}

- (void)showManualButtonAdAtIndex:(NSInteger)index fromViewController:(UIViewController *)viewController {
    if (!self.isOAAEnvironment) {
        return;
    }

    if (index == 0) {
        [self showAppOpenAdFromViewController:viewController];
    } else if (index == 1) {
        [self showBannerAdInViewController:viewController];
    } else if (index == 2) {
        [self showInterstitialAdFromViewController:viewController];
    } else if (index == 3) {
        [self showRewardedAdFromViewController:viewController];
    }
}

- (void)requestTrackingAuthorizationIfNeeded {
    if (!self.config.isEnabled) {
        return;
    }
    
    if (@available(iOS 14, *)) {
        ATTrackingManagerAuthorizationStatus status = ATTrackingManager.trackingAuthorizationStatus;
        NSLog(@"[ATT] Request attempt with status: %ld", (long)status);
        if (status != ATTrackingManagerAuthorizationStatusNotDetermined) {
            return;
        }
        
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"[ATT] Request completed with status: %ld", (long)status);
            });
        }];
    }
}

- (void)applicationDidBecomeActive {
    if ([self.provider respondsToSelector:@selector(applicationDidBecomeActive)]) {
        [self.provider applicationDidBecomeActive];
    }
}

- (void)applicationWillEnterForeground {
    if ([self.provider respondsToSelector:@selector(applicationWillEnterForeground)]) {
        [self.provider applicationWillEnterForeground];
    }
}

- (void)applicationDidEnterBackground {
    if ([self.provider respondsToSelector:@selector(applicationDidEnterBackground)]) {
        [self.provider applicationDidEnterBackground];
    }
}

@end
