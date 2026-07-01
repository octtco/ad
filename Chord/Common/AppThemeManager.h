#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppThemeManager : NSObject

@property (nonatomic, strong, readonly) NSDictionary *themeDictionary;
@property (nonatomic, strong, readonly) UIColor *appBackgroundColor;
@property (nonatomic, strong, readonly) UIColor *surfaceColor;
@property (nonatomic, strong, readonly) UIColor *surfaceSecondaryColor;
@property (nonatomic, strong, readonly) UIColor *primaryColor;
@property (nonatomic, strong, readonly) UIColor *secondaryColor;
@property (nonatomic, strong, readonly) UIColor *dangerColor;
@property (nonatomic, strong, readonly) UIColor *navBackgroundColor;
@property (nonatomic, strong, readonly) UIColor *navTextColor;
@property (nonatomic, strong, readonly) UIColor *navTintColor;
@property (nonatomic, strong, readonly) UIColor *tabbarBackgroundColor;
@property (nonatomic, strong, readonly) UIColor *tabActiveColor;
@property (nonatomic, strong, readonly) UIColor *tabInactiveColor;
@property (nonatomic, strong, readonly) UIColor *textPrimaryColor;
@property (nonatomic, strong, readonly) UIColor *textSecondaryColor;
@property (nonatomic, strong, readonly) UIColor *textPlaceholderColor;
@property (nonatomic, strong, readonly) UIColor *textOnPrimaryColor;
@property (nonatomic, strong, readonly) UIColor *borderColor;
@property (nonatomic, strong, readonly) UIColor *dividerColor;
@property (nonatomic, strong, readonly) UIColor *cardBackgroundColor;
@property (nonatomic, strong, readonly) UIColor *inputBackgroundColor;
@property (nonatomic, strong, readonly) UIColor *shadowColor;
@property (nonatomic, assign, readonly) CGFloat buttonCornerRadius;
@property (nonatomic, assign, readonly) CGFloat cardCornerRadius;
@property (nonatomic, assign, readonly) CGFloat inputCornerRadius;
@property (nonatomic, assign, readonly) CGFloat buttonHeight;
@property (nonatomic, assign, readonly) CGFloat inputHeight;
@property (nonatomic, assign, readonly) CGFloat titleFontSize;
@property (nonatomic, assign, readonly) CGFloat bodyFontSize;
@property (nonatomic, assign, readonly) CGFloat captionFontSize;
@property (nonatomic, assign, readonly) CGFloat shadowOpacity;

+ (instancetype)sharedManager;

- (void)reloadTheme;
- (UIColor *)colorForFeature:(NSString *)featureKey key:(NSString *)key fallback:(UIColor *)fallback;
- (CGFloat)floatForFeature:(NSString *)featureKey key:(NSString *)key fallback:(CGFloat)fallback;
- (void)applyThemeToNavigationController:(nullable UINavigationController *)navigationController;
- (void)applyThemeToTabBar:(nullable UITabBar *)tabBar;
- (void)stylePrimaryButton:(UIButton *)button;
- (void)styleSecondaryButton:(UIButton *)button;
- (void)styleCardView:(UIView *)view;
- (void)styleInputView:(UIView *)view;
- (void)configureProgressHUD;

@end

NS_ASSUME_NONNULL_END
