//
//  SceneDelegate.m
//  Chord
//

#import "SceneDelegate.h"
#import "AppAdManager.h"
#import "AppSplashViewController.h"
#import "MainTabBarController.h"

@interface SceneDelegate ()

@property (nonatomic, assign, getter=hasEnteredBackground) BOOL enteredBackground;
@property (nonatomic, assign, getter=hasPendingHotStartAd) BOOL pendingHotStartAd;

@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setWindowScene:windowScene];

    AppSplashViewController *splashViewController = [[AppSplashViewController alloc] init];
    [self.window setRootViewController:splashViewController];
    [self.window makeKeyAndVisible];

    __weak typeof(self) weakSelf = self;
    [splashViewController startWithCompletion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        MainTabBarController *tabBarController = [[MainTabBarController alloc] init];
        [strongSelf.window setRootViewController:tabBarController];
    }];
}

- (void)sceneDidDisconnect:(UIScene *)scene {
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
    if (self.hasPendingHotStartAd) {
        self.pendingHotStartAd = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showHotStartInterstitialAdIfNeeded];
        });
    }
}

- (void)sceneWillResignActive:(UIScene *)scene {
}

- (void)sceneWillEnterForeground:(UIScene *)scene {
    if (!self.hasEnteredBackground) {
        return;
    }

    self.enteredBackground = NO;
    self.pendingHotStartAd = YES;
}

- (void)sceneDidEnterBackground:(UIScene *)scene {
    self.enteredBackground = YES;
}

- (void)showHotStartInterstitialAdIfNeeded {
    UIViewController *rootViewController = self.window.rootViewController;
    if ([rootViewController isKindOfClass:[AppSplashViewController class]]) {
        return;
    }

    UIViewController *presentingViewController = [self topViewControllerFromViewController:rootViewController];
    if (!presentingViewController) {
        return;
    }

    [[AppAdManager sharedManager] showHotStartAdFromViewController:presentingViewController];
}

- (UIViewController *)topViewControllerFromViewController:(UIViewController *)viewController {
    if (viewController.presentedViewController) {
        return [self topViewControllerFromViewController:viewController.presentedViewController];
    }

    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)viewController;
        return [self topViewControllerFromViewController:navigationController.visibleViewController];
    }

    if ([viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)viewController;
        return [self topViewControllerFromViewController:tabBarController.selectedViewController];
    }

    return viewController;
}


@end
