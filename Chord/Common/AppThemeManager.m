#import "AppThemeManager.h"
#import <SVProgressHUD/SVProgressHUD.h>

static NSString *const kAppThemeResourceName = @"AppThemeConfig";

@interface AppThemeManager ()

@property (nonatomic, strong) NSDictionary *themeDictionary;
@property (nonatomic, strong) UIColor *appBackgroundColor;
@property (nonatomic, strong) UIColor *surfaceColor;
@property (nonatomic, strong) UIColor *surfaceSecondaryColor;
@property (nonatomic, strong) UIColor *primaryColor;
@property (nonatomic, strong) UIColor *secondaryColor;
@property (nonatomic, strong) UIColor *dangerColor;
@property (nonatomic, strong) UIColor *navBackgroundColor;
@property (nonatomic, strong) UIColor *navTextColor;
@property (nonatomic, strong) UIColor *navTintColor;
@property (nonatomic, strong) UIColor *tabbarBackgroundColor;
@property (nonatomic, strong) UIColor *tabActiveColor;
@property (nonatomic, strong) UIColor *tabInactiveColor;
@property (nonatomic, strong) UIColor *textPrimaryColor;
@property (nonatomic, strong) UIColor *textSecondaryColor;
@property (nonatomic, strong) UIColor *textPlaceholderColor;
@property (nonatomic, strong) UIColor *textOnPrimaryColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIColor *dividerColor;
@property (nonatomic, strong) UIColor *cardBackgroundColor;
@property (nonatomic, strong) UIColor *inputBackgroundColor;
@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, assign) CGFloat buttonCornerRadius;
@property (nonatomic, assign) CGFloat cardCornerRadius;
@property (nonatomic, assign) CGFloat inputCornerRadius;
@property (nonatomic, assign) CGFloat buttonHeight;
@property (nonatomic, assign) CGFloat inputHeight;
@property (nonatomic, assign) CGFloat titleFontSize;
@property (nonatomic, assign) CGFloat bodyFontSize;
@property (nonatomic, assign) CGFloat captionFontSize;
@property (nonatomic, assign) CGFloat shadowOpacity;

@end

@interface AppThemeManager (Private)

+ (UIColor *)classDefaultColor:(NSString *)hex;
+ (UIColor *)colorFromValue:(id)value;
+ (UIColor *)colorFromHexString:(NSString *)hexString;
+ (UIColor *)colorFromRGBString:(NSString *)value;

@end

@implementation AppThemeManager

+ (instancetype)sharedManager {
    static AppThemeManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self reloadTheme];
    }
    return self;
}

- (void)reloadTheme {
    NSDictionary *theme = [self loadThemeDictionary];
    self.themeDictionary = theme;
    self.appBackgroundColor = [self resolvedColorForKey:@"appBackgroundColor" fallback:[[self class] classDefaultColor:@"#F7F8FC"]];
    self.surfaceColor = [self resolvedColorForKey:@"surfaceColor" fallback:[[self class] classDefaultColor:@"#FFFFFF"]];
    self.surfaceSecondaryColor = [self resolvedColorForKey:@"surfaceSecondaryColor" fallback:[[self class] classDefaultColor:@"#EEF3FF"]];
    self.primaryColor = [self resolvedColorForKey:@"primaryColor" fallback:[[self class] classDefaultColor:@"#3B82F6"]];
    self.secondaryColor = [self resolvedColorForKey:@"secondaryColor" fallback:[[self class] classDefaultColor:@"#7C9DFF"]];
    self.dangerColor = [self resolvedColorForKey:@"dangerColor" fallback:[[self class] classDefaultColor:@"#FF5A5F"]];
    self.navBackgroundColor = [self resolvedColorForKey:@"navBackgroundColor" fallback:[[self class] classDefaultColor:@"#FFFFFF"]];
    self.navTextColor = [self resolvedColorForKey:@"navTextColor" fallback:[[self class] classDefaultColor:@"#111827"]];
    self.navTintColor = [self resolvedColorForKey:@"navTintColor" fallback:self.navTextColor];
    self.tabbarBackgroundColor = [self resolvedColorForKey:@"tabbarBackgroundColor" fallback:[[self class] classDefaultColor:@"#FFFFFF"]];
    self.tabActiveColor = [self resolvedColorForKey:@"tabActiveColor" fallback:self.primaryColor];
    self.tabInactiveColor = [self resolvedColorForKey:@"tabInactiveColor" fallback:[[self class] classDefaultColor:@"#8A8F98"]];
    self.textPrimaryColor = [self resolvedColorForKey:@"textPrimaryColor" fallback:[[self class] classDefaultColor:@"#111827"]];
    self.textSecondaryColor = [self resolvedColorForKey:@"textSecondaryColor" fallback:[[self class] classDefaultColor:@"#6B7280"]];
    self.textPlaceholderColor = [self resolvedColorForKey:@"textPlaceholderColor" fallback:[[self class] classDefaultColor:@"#9CA3AF"]];
    self.textOnPrimaryColor = [self resolvedColorForKey:@"textOnPrimaryColor" fallback:[[self class] classDefaultColor:@"#FFFFFF"]];
    self.borderColor = [self resolvedColorForKey:@"borderColor" fallback:[[self class] classDefaultColor:@"#E5E7EB"]];
    self.dividerColor = [self resolvedColorForKey:@"dividerColor" fallback:[[self class] classDefaultColor:@"#EDF1F7"]];
    self.cardBackgroundColor = [self resolvedColorForKey:@"cardBackgroundColor" fallback:[[self class] classDefaultColor:@"#FFFFFF"]];
    self.inputBackgroundColor = [self resolvedColorForKey:@"inputBackgroundColor" fallback:[[self class] classDefaultColor:@"#FFFFFF"]];
    self.shadowColor = [self resolvedColorForKey:@"shadowColor" fallback:[[self class] classDefaultColor:@"#1F2937"]];
    self.buttonCornerRadius = [self resolvedFloatForKey:@"buttonCornerRadius" fallback:22.0];
    self.cardCornerRadius = [self resolvedFloatForKey:@"cardCornerRadius" fallback:18.0];
    self.inputCornerRadius = [self resolvedFloatForKey:@"inputCornerRadius" fallback:22.0];
    self.buttonHeight = [self resolvedFloatForKey:@"buttonHeight" fallback:52.0];
    self.inputHeight = [self resolvedFloatForKey:@"inputHeight" fallback:56.0];
    self.titleFontSize = [self resolvedFloatForKey:@"titleFontSize" fallback:20.0];
    self.bodyFontSize = [self resolvedFloatForKey:@"bodyFontSize" fallback:16.0];
    self.captionFontSize = [self resolvedFloatForKey:@"captionFontSize" fallback:14.0];
    self.shadowOpacity = [self resolvedFloatForKey:@"shadowOpacity" fallback:0.12];
}

- (UIColor *)colorForFeature:(NSString *)featureKey key:(NSString *)key fallback:(UIColor *)fallback {
    NSDictionary *featureOverrides = [self featureOverrideDictionaryForKey:featureKey];
    UIColor *resolved = [[self class] colorFromValue:featureOverrides[key]];
    return resolved ?: fallback;
}

- (CGFloat)floatForFeature:(NSString *)featureKey key:(NSString *)key fallback:(CGFloat)fallback {
    NSDictionary *featureOverrides = [self featureOverrideDictionaryForKey:featureKey];
    id value = featureOverrides[key];
    if ([value respondsToSelector:@selector(doubleValue)]) {
        return (CGFloat)[value doubleValue];
    }
    return fallback;
}

- (void)applyThemeToNavigationController:(UINavigationController *)navigationController {
    if (!navigationController) {
        return;
    }
    navigationController.navigationBar.translucent = NO;
    navigationController.navigationBar.tintColor = self.navTintColor;
    NSDictionary *textAttributes = @{NSForegroundColorAttributeName: self.navTextColor};
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = self.navBackgroundColor;
        appearance.shadowColor = self.dividerColor;
        appearance.titleTextAttributes = textAttributes;
        navigationController.navigationBar.standardAppearance = appearance;
        navigationController.navigationBar.scrollEdgeAppearance = appearance;
        navigationController.navigationBar.compactAppearance = appearance;
    } else {
        navigationController.navigationBar.barTintColor = self.navBackgroundColor;
        navigationController.navigationBar.shadowImage = [UIImage new];
        navigationController.navigationBar.titleTextAttributes = textAttributes;
    }
}

- (void)applyThemeToTabBar:(UITabBar *)tabBar {
    if (!tabBar) {
        return;
    }
    NSDictionary *selectedAttributes = @{NSForegroundColorAttributeName: self.tabActiveColor};
    NSDictionary *normalAttributes = @{NSForegroundColorAttributeName: self.tabInactiveColor};
    UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = self.tabbarBackgroundColor;
    appearance.shadowColor = self.dividerColor;
    appearance.stackedLayoutAppearance.selected.iconColor = self.tabActiveColor;
    appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes;
    appearance.stackedLayoutAppearance.normal.iconColor = self.tabInactiveColor;
    appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes;
    tabBar.tintColor = self.tabActiveColor;
    tabBar.unselectedItemTintColor = self.tabInactiveColor;
    tabBar.standardAppearance = appearance;
    if (@available(iOS 15.0, *)) {
        tabBar.scrollEdgeAppearance = appearance;
    }
}

- (void)stylePrimaryButton:(UIButton *)button {
    if (!button) {
        return;
    }
    button.backgroundColor = self.primaryColor;
    [button setTitleColor:self.textOnPrimaryColor forState:UIControlStateNormal];
    button.layer.cornerRadius = self.buttonCornerRadius;
    button.layer.borderWidth = 0;
    button.titleLabel.font = [UIFont systemFontOfSize:self.bodyFontSize weight:UIFontWeightSemibold];
}

- (void)styleSecondaryButton:(UIButton *)button {
    if (!button) {
        return;
    }
    button.backgroundColor = self.surfaceColor;
    [button setTitleColor:self.primaryColor forState:UIControlStateNormal];
    button.layer.cornerRadius = self.buttonCornerRadius;
    button.layer.borderWidth = 1;
    button.layer.borderColor = self.borderColor.CGColor;
    button.titleLabel.font = [UIFont systemFontOfSize:self.bodyFontSize weight:UIFontWeightSemibold];
}

- (void)styleCardView:(UIView *)view {
    if (!view) {
        return;
    }
    view.backgroundColor = self.cardBackgroundColor;
    view.layer.cornerRadius = self.cardCornerRadius;
    view.layer.shadowColor = self.shadowColor.CGColor;
    view.layer.shadowOpacity = self.shadowOpacity;
    view.layer.shadowOffset = CGSizeMake(0, 6);
    view.layer.shadowRadius = 18;
    view.layer.masksToBounds = NO;
}

- (void)styleInputView:(UIView *)view {
    if (!view) {
        return;
    }
    view.backgroundColor = self.inputBackgroundColor;
    view.layer.cornerRadius = self.inputCornerRadius;
    view.layer.borderWidth = 1;
    view.layer.borderColor = self.borderColor.CGColor;
    view.layer.masksToBounds = YES;
}

- (void)configureProgressHUD {
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setBackgroundColor:self.surfaceColor];
    [SVProgressHUD setForegroundColor:self.textPrimaryColor];
    [SVProgressHUD setCornerRadius:self.cardCornerRadius];
}

#pragma mark - Helpers

- (NSDictionary *)loadThemeDictionary {
    NSString *path = [[NSBundle mainBundle] pathForResource:kAppThemeResourceName ofType:@"json"];
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

- (UIColor *)resolvedColorForKey:(NSString *)key fallback:(UIColor *)fallback {
    UIColor *resolved = [[self class] colorFromValue:self.themeDictionary[key]];
    return resolved ?: fallback;
}

- (CGFloat)resolvedFloatForKey:(NSString *)key fallback:(CGFloat)fallback {
    id value = self.themeDictionary[key];
    if ([value respondsToSelector:@selector(doubleValue)]) {
        return (CGFloat)[value doubleValue];
    }
    return fallback;
}

- (NSDictionary *)featureOverrideDictionaryForKey:(NSString *)featureKey {
    NSDictionary *featureOverrides = [self.themeDictionary[@"featureOverrides"] isKindOfClass:[NSDictionary class]] ? self.themeDictionary[@"featureOverrides"] : @{};
    NSDictionary *override = [featureOverrides[featureKey] isKindOfClass:[NSDictionary class]] ? featureOverrides[featureKey] : @{};
    return override;
}

+ (UIColor *)classDefaultColor:(NSString *)hex {
    return [self colorFromValue:hex] ?: UIColor.whiteColor;
}

+ (UIColor *)colorFromValue:(id)value {
    if (![value isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSString *raw = [(NSString *)value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (raw.length == 0) {
        return nil;
    }
    NSString *lowered = [raw lowercaseString];
    if ([lowered isEqualToString:@"clearcolor"] || [lowered isEqualToString:@"transparent"] || [lowered isEqualToString:@"none"]) {
        return UIColor.clearColor;
    }
    if ([raw hasPrefix:@"#"]) {
        return [self colorFromHexString:raw];
    }
    if ([lowered hasPrefix:@"rgb"]) {
        return [self colorFromRGBString:raw];
    }
    return nil;
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    NSString *raw = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if (raw.length == 3) {
        NSMutableString *expanded = [NSMutableString stringWithCapacity:6];
        for (NSUInteger index = 0; index < raw.length; index++) {
            unichar ch = [raw characterAtIndex:index];
            [expanded appendFormat:@"%C%C", ch, ch];
        }
        raw = expanded;
    }
    if (raw.length != 6 && raw.length != 8) {
        return nil;
    }
    unsigned int hexValue = 0;
    if (![[NSScanner scannerWithString:raw] scanHexInt:&hexValue]) {
        return nil;
    }
    CGFloat alpha = 1.0;
    if (raw.length == 8) {
        alpha = ((hexValue >> 24) & 0xFF) / 255.0;
    }
    CGFloat red = ((hexValue >> (raw.length == 8 ? 16 : 16)) & 0xFF) / 255.0;
    CGFloat green = ((hexValue >> (raw.length == 8 ? 8 : 8)) & 0xFF) / 255.0;
    CGFloat blue = (hexValue & 0xFF) / 255.0;
    if (raw.length == 8) {
        red = ((hexValue >> 16) & 0xFF) / 255.0;
        green = ((hexValue >> 8) & 0xFF) / 255.0;
        blue = (hexValue & 0xFF) / 255.0;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *)colorFromRGBString:(NSString *)value {
    NSString *raw = [[value lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange startRange = [raw rangeOfString:@"("];
    NSRange endRange = [raw rangeOfString:@")" options:NSBackwardsSearch];
    if (startRange.location == NSNotFound || endRange.location == NSNotFound || endRange.location <= startRange.location) {
        return nil;
    }
    NSString *inside = [raw substringWithRange:NSMakeRange(startRange.location + 1, endRange.location - startRange.location - 1)];
    NSArray<NSString *> *parts = [inside componentsSeparatedByString:@","];
    if (parts.count < 3) {
        return nil;
    }
    CGFloat red = parts[0].doubleValue / 255.0;
    CGFloat green = parts[1].doubleValue / 255.0;
    CGFloat blue = parts[2].doubleValue / 255.0;
    CGFloat alpha = 1.0;
    if ([raw hasPrefix:@"rgba"] && parts.count > 3) {
        alpha = parts[3].doubleValue;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
