//
//  AppDelegate.m
//  Chord
//

#import "AppDelegate.h"
#import "AppAdConfig.h"
#import "AppAdManager.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupAds];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[AppAdManager sharedManager] applicationDidBecomeActive];
//    NSLog(@"applicationDidBecomeActive");
//    [self requestTrackingAuthorizationIfNeeded];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[AppAdManager sharedManager] applicationWillEnterForeground];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[AppAdManager sharedManager] applicationDidEnterBackground];
}

- (void)setupAds {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"AppAdConfig" ofType:@"json"];
    if (path.length == 0) {
        return;
    }

    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) {
        return;
    }

    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error || ![dictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }

    AppAdConfig *config = [AppAdConfig configWithDictionary:dictionary];
    [[AppAdManager sharedManager] setupWithConfig:config];
}

//- (void)requestTrackingAuthorizationIfNeeded {
//    if (![AppAdManager sharedManager].config.isEnabled) {
//        return;
//    }
//    if (@available(iOS 14, *)) {
//        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
//        }];
//    }
//}

@end
