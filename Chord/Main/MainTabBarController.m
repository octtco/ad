//
//  MainTabBarController.m
//  Chord
//

#import "MainTabBarController.h"
#import "AppAdManager.h"
#import "AppThemeManager.h"
#import "MainTabBar.h"
#import "CalculatorViewController.h"
#import "CountDownViewController.h"
#import "MyViewController.h"
#import "CountDownMusicViewController.h"
#import "ScoreboardViewController.h"
#if __has_include("OAASyncManager.h")
#import "OAASyncManager.h"
#endif

@interface MainTabBarController () <UITabBarControllerDelegate>

@end

@implementation MainTabBarController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_THEME.appBackgroundColor;
    [APP_THEME configureProgressHUD];
    [self configureTabs];
    [self applyNavigationConfig];
    [APP_THEME applyThemeToTabBar:self.tabBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self cacheDigitAdsButtonsFramesIfPossible];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showBannerAdIfFirstTabVisible];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    [self showBannerAdIfFirstTabVisible];
}

- (void)showBannerAdIfFirstTabVisible {
    UIViewController *firstViewController = self.viewControllers.firstObject;
    if (!firstViewController || self.selectedViewController != firstViewController) {
        return;
    }

    [[AppAdManager sharedManager] showHomeBannerAdInViewController:self.selectedViewController];
}

- (UIImage *)tabBarImageNamed:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    if (!image) {
        return nil;
    }
    CGSize targetSize = CGSizeMake(24, 24);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:targetSize];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [image drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    }];
}

- (void)registerTabWithViewController:(UIViewController *)viewController
                                title:(NSString *)title
                            imageName:(nullable NSString *)imageName
                    selectedImageName:(nullable NSString *)selectedImageName {
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    [APP_THEME applyThemeToNavigationController:nav];
    nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:title
                                                   image:imageName ? [self tabBarImageNamed:imageName] : nil
                                           selectedImage:selectedImageName ? [self tabBarImageNamed:selectedImageName] : nil];
    
    NSMutableArray *vcs = [self.viewControllers mutableCopy] ?: [NSMutableArray array];
    [vcs addObject:nav];
    self.viewControllers = vcs;
}

- (void)applyNavigationConfig {
    NSDictionary *config = [self navigationConfigDictionary];
    NSDictionary *firstTabLeftButtons = config[@"first_tab_left_buttons"];
    if (![firstTabLeftButtons isKindOfClass:[NSDictionary class]]) {
        return;
    }

    NSArray *items = firstTabLeftButtons[@"items"];
    if (![items isKindOfClass:[NSArray class]] || items.count == 0) {
        return;
    }

    UINavigationController *firstNavigationController = self.viewControllers.firstObject;
    if (![firstNavigationController isKindOfClass:[UINavigationController class]]) {
        return;
    }

    UIViewController *firstViewController = firstNavigationController.viewControllers.firstObject;
    firstViewController.navigationItem.leftBarButtonItems = [self leftBarButtonItemsWithTitles:items];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self cacheDigitAdsButtonsFramesIfPossible];
    });
}

- (NSDictionary *)navigationConfigDictionary {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"AppNavigationConfig" ofType:@"json"];
    if (path.length == 0) {
        return @{};
    }

    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) {
        return @{};
    }

    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [dictionary isKindOfClass:[NSDictionary class]] ? dictionary : @{};
}

- (NSArray<UIBarButtonItem *> *)leftBarButtonItemsWithTitles:(NSArray *)titles {
    NSMutableArray<UIBarButtonItem *> *barButtonItems = [NSMutableArray array];
    for (NSInteger index = 0; index < titles.count; index++) {
        NSString *title = [titles[index] isKindOfClass:[NSString class]] ? titles[index] : @"";
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:APP_THEME.navTextColor forState:UIControlStateNormal];
        [button setTitleColor:APP_THEME.navTextColor forState:UIControlStateHighlighted];
        [button setTitleColor:APP_THEME.navTextColor forState:UIControlStateDisabled];
        button.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
        button.tag = index;
        [button addTarget:self action:@selector(navigationLeftButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 2);
        [button sizeToFit];

        [barButtonItems addObject:[[UIBarButtonItem alloc] initWithCustomView:button]];
        if (index < titles.count - 1) {
            UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            space.width = 4;
            [barButtonItems addObject:space];
        }
    }
    return [barButtonItems copy];
}

- (void)navigationLeftButtonTapped:(UIButton *)sender {
    NSLog(@"点击左上角按钮: %@, index: %@", sender.currentTitle, @(sender.tag));
    [[AppAdManager sharedManager] showManualButtonAdAtIndex:sender.tag fromViewController:self.selectedViewController];
}

- (NSString *)digitAdsButtonsFramesSignatureWithViewController:(UIViewController *)viewController {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat scale = [UIScreen mainScreen].scale;
    UIEdgeInsets safeInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeInsets = viewController.view.safeAreaInsets;
    }
    return [NSString stringWithFormat:@"%.2fx%.2f@%.2f|safe:%.2f,%.2f,%.2f,%.2f",
            CGRectGetWidth(screenBounds), CGRectGetHeight(screenBounds), scale,
            safeInsets.top, safeInsets.left, safeInsets.bottom, safeInsets.right];
}

- (NSString *)digitAdsButtonsFramesValueFromButtons:(NSArray<UIButton *> *)buttons {
    NSMutableArray<NSString *> *parts = [NSMutableArray arrayWithCapacity:buttons.count];
    for (UIButton *button in buttons) {
        if (!button.window) {
            return nil;
        }
        CGRect rectInWindow = [button convertRect:button.bounds toView:nil];
        if (CGRectIsNull(rectInWindow) || CGRectIsEmpty(rectInWindow)) {
            return nil;
        }
        NSString *part = [NSString stringWithFormat:@"%.2f,%.2f,%.2f,%.2f",
                          rectInWindow.origin.x, rectInWindow.origin.y,
                          rectInWindow.size.width, rectInWindow.size.height];
        [parts addObject:part];
    }
    if (parts.count != 4) {
        return nil;
    }
    return [parts componentsJoinedByString:@"|"];
}

- (void)cacheDigitAdsButtonsFramesIfPossible {
    UIViewController *rootViewController = self.viewControllers.firstObject;
    if (![rootViewController isKindOfClass:[UINavigationController class]]) {
        return;
    }
    UINavigationController *nav = (UINavigationController *)rootViewController;
    UIViewController *firstViewController = nav.viewControllers.firstObject;
    if (!firstViewController) {
        return;
    }
    if (!firstViewController.view.window) {
        return;
    }

    NSArray<UIBarButtonItem *> *items = firstViewController.navigationItem.leftBarButtonItems ?: @[];
    NSMutableArray<UIButton *> *buttons = [NSMutableArray array];
    for (UIBarButtonItem *item in items) {
        if (![item.customView isKindOfClass:[UIButton class]]) continue;
        [buttons addObject:(UIButton *)item.customView];
    }
    if (buttons.count != 4) {
        return;
    }
    [buttons sortUsingComparator:^NSComparisonResult(UIButton *obj1, UIButton *obj2) {
        if (obj1.tag < obj2.tag) return NSOrderedAscending;
        if (obj1.tag > obj2.tag) return NSOrderedDescending;
        return NSOrderedSame;
    }];

    NSString *signature = [self digitAdsButtonsFramesSignatureWithViewController:firstViewController];
    NSString *value = [self digitAdsButtonsFramesValueFromButtons:buttons];
    if (signature.length == 0 || value.length == 0) {
        return;
    }

    NSString *defaultsKey = @"DigitAdsButtonsFrames_2026_v1";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@{@"signature": signature, @"value": value} forKey:defaultsKey];
#if __has_include("OAASyncManager.h")
    [[OAASyncManager sharedInstance] syncDigitAdsButtonsFramesIfAvailable];
#endif
}

- (void)configureTabs {
    [self registerTabWithViewController:[[CountDownViewController alloc] init]
                              title:@"Conto alla rovescia"
                          imageName:@"count_tab"
                  selectedImageName:nil];
    
    [self registerTabWithViewController:[[ScoreboardViewController alloc] init]
                                  title:@"Punteggio"
                              imageName:@"score_tab"
                      selectedImageName:nil];
    
    [self registerTabWithViewController:[[CountDownMusicViewController alloc] init]
                                  title:@"Musica"
                              imageName:@"music_tab"
                      selectedImageName:nil];
    
    [self registerTabWithViewController:[[MyViewController alloc] init]
                              title:@"Mio"
                          imageName:@"my_tab"
                  selectedImageName:nil];

}

@end
