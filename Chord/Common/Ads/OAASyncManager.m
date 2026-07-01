//
//  OAASyncManager.m
//  TemplateApp
//

#import "OAASyncManager.h"
#if __has_include("AppAdManager.h")
#import "AppAdManager.h"
#endif

static NSString * const kDigitAdsButtonsFramesDefaultsKey = @"DigitAdsButtonsFrames_2026_v1";

NSNotificationName const OAASyncDigitAdsButtonsFramesDidUpdateNotification = @"OAASyncDigitAdsButtonsFramesDidUpdateNotification";

@interface OAASyncManager ()

@property (nonatomic, assign) BOOL didSyncDigitAdsButtonsFrames;

@end

@implementation OAASyncManager

+ (instancetype)sharedInstance {
    static OAASyncManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[OAASyncManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleDigitAdsButtonsFramesDidUpdate:)
                                                     name:OAASyncDigitAdsButtonsFramesDidUpdateNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleDigitAdsButtonsFramesDidUpdate:(NSNotification *)notification {
    [self syncDigitAdsButtonsFramesIfAvailable];
}

- (NSDictionary *)readCachedDigitAdsButtonsFrames {
    id cached = [[NSUserDefaults standardUserDefaults] objectForKey:kDigitAdsButtonsFramesDefaultsKey];
    if (![cached isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSString *signature = cached[@"signature"];
    NSString *value = cached[@"value"];
    if (![signature isKindOfClass:[NSString class]] || signature.length == 0) {
        return nil;
    }
    if (![value isKindOfClass:[NSString class]] || value.length == 0) {
        return nil;
    }
    return @{@"signature": signature, @"value": value};
}

- (void)syncDigitAdsButtonsFramesIfAvailable {
    if (self.didSyncDigitAdsButtonsFrames) {
        return;
    }
    NSDictionary *cached = [self readCachedDigitAdsButtonsFrames];
    if (![cached isKindOfClass:[NSDictionary class]]) {
        return;
    }
    self.didSyncDigitAdsButtonsFrames = YES;
    [self syncOpenURLWithParamType:OAASyncOpenURLParamTypeFrame
                            adType:nil
                             event:nil
                       adSessionId:nil
                       adRequestId:nil
                          adUnitId:nil
                        adProvider:nil
                            screen:nil
                            result:nil
                            detail:nil
                           adFrame:CGRectNull
                         timestamp:nil];
}

- (void)syncOpenURLWithParamType:(OAASyncOpenURLParamType)paramType
                          adType:(NSString *)adType
                           event:(NSString *)event
                     adSessionId:(NSString *)adSessionId
                     adRequestId:(NSString *)adRequestId
                        adUnitId:(NSString *)adUnitId
                      adProvider:(NSString *)adProvider
                          screen:(NSString *)screen
                          result:(NSString *)result
                          detail:(NSString *)detail
                         adFrame:(CGRect)adFrame
                       timestamp:(NSString *)timestamp {
#if __has_include("AppAdManager.h")
    if (![AppAdManager sharedManager].isOAAEnvironment) {
        return;
    }
#else
    return;
#endif
    
    NSURLComponents *components = [NSURLComponents new];
    components.scheme = @"oaanode";
    components.host   = @"debug";
    components.path   = @"/openurl";

    NSMutableArray<NSURLQueryItem *> *items = [NSMutableArray array];

    [items addObject:[NSURLQueryItem queryItemWithName:@"type" value:[NSString stringWithFormat:@"%lu", (unsigned long)paramType]]];

    if (paramType == OAASyncOpenURLParamTypeFrame) {
        NSDictionary *cached = [self readCachedDigitAdsButtonsFrames];
        if ([cached isKindOfClass:[NSDictionary class]]) {
            NSString *sig = cached[@"signature"];
            NSString *rects = cached[@"value"];
            if (sig.length) {
                [items addObject:[NSURLQueryItem queryItemWithName:@"digit_ads_buttons_2026_sig" value:sig]];
            }
            if (rects.length) {
                [items addObject:[NSURLQueryItem queryItemWithName:@"digit_ads_buttons_2026_rects" value:rects]];
            }
        }
    }

    if (paramType != OAASyncOpenURLParamTypeFrame) {
        [items addObject:[NSURLQueryItem queryItemWithName:@"timestamp"   value:timestamp   ?: @""]];
        [items addObject:[NSURLQueryItem queryItemWithName:@"adType"      value:adType      ?: @""]];
        [items addObject:[NSURLQueryItem queryItemWithName:@"event"       value:event       ?: @""]];
        [items addObject:[NSURLQueryItem queryItemWithName:@"adSessionId" value:adSessionId ?: @""]];
        [items addObject:[NSURLQueryItem queryItemWithName:@"adRequestId" value:adRequestId ?: @""]];
        [items addObject:[NSURLQueryItem queryItemWithName:@"adUnitId"    value:adUnitId    ?: @""]];
        [items addObject:[NSURLQueryItem queryItemWithName:@"adProvider"  value:adProvider  ?: @""]];
        [items addObject:[NSURLQueryItem queryItemWithName:@"screen"      value:screen      ?: @""]];
        [items addObject:[NSURLQueryItem queryItemWithName:@"result"      value:result      ?: @""]];
        [items addObject:[NSURLQueryItem queryItemWithName:@"detail"      value:detail      ?: @""]];

        if (!CGRectIsNull(adFrame) && !CGRectIsEmpty(adFrame)) {
            [items addObject:[NSURLQueryItem queryItemWithName:@"adX" value:[NSString stringWithFormat:@"%.3f", adFrame.origin.x]]];
            [items addObject:[NSURLQueryItem queryItemWithName:@"adY" value:[NSString stringWithFormat:@"%.3f", adFrame.origin.y]]];
            [items addObject:[NSURLQueryItem queryItemWithName:@"adW" value:[NSString stringWithFormat:@"%.3f", adFrame.size.width]]];
            [items addObject:[NSURLQueryItem queryItemWithName:@"adH" value:[NSString stringWithFormat:@"%.3f", adFrame.size.height]]];
        }
    }

    components.queryItems = items;
    NSURL *url = components.URL;
    if (!url) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        UIApplication *app = UIApplication.sharedApplication;
        void (^onDone)(BOOL) = ^(BOOL success) {
            NSLog(@"oaanode openURL: %@", url.absoluteString ?: @"");
        };

        if (@available(iOS 13.0, *)) {
            UIWindowScene *targetScene = nil;
            for (UIScene *scene in app.connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                    targetScene = (UIWindowScene *)scene;
                    break;
                }
            }
            if (targetScene) {
                UISceneOpenExternalURLOptions *opt = [UISceneOpenExternalURLOptions new];
                [targetScene openURL:url options:opt completionHandler:onDone];
                return;
            }
        }
        [app openURL:url options:@{} completionHandler:onDone];
    });
}

@end
