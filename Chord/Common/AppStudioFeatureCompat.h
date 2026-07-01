#import <UIKit/UIKit.h>
#import "AppThemeManager.h"

#define APP_THEME_MANAGER ([AppThemeManager sharedManager])

#define ZOOM(value) ((value) * kScreenHeight / 812.0)

#define GREY_COLOR APP_THEME_MANAGER.textSecondaryColor
#define KEEPASS_COLOR_BLACKMASK RGBA(0, 0, 0, 0.5)
#define KEEPASS_GRAY_03 APP_THEME_MANAGER.textPlaceholderColor
#define KEEPASS_FONT(SIZE) [UIFont fontWithName:@"PingFang SC" size:(SIZE)]
#define KEEPASS_FONT_Medium(SIZE) [UIFont fontWithName:@"PingFangSC-Medium" size:(SIZE)]
#define KEEPASS_FONT_Regular(SIZE) [UIFont fontWithName:@"PingFangSC-Regular" size:(SIZE)]
#define DEEP_COLOR APP_THEME_MANAGER.primaryColor
#define DEEP_COLOR_1 APP_THEME_MANAGER.secondaryColor
#define LIGHT_COLOR APP_THEME_MANAGER.surfaceSecondaryColor
#define BUTTON_COLOR APP_THEME_MANAGER.primaryColor
#define SHADOW_COLOR APP_THEME_MANAGER.shadowColor
#define SHALLOW_COLOR APP_THEME_MANAGER.surfaceColor

#define PR_BG_COLOR APP_THEME_MANAGER.primaryColor
#define PR_LABEL_WHITE_COLOR APP_THEME_MANAGER.textOnPrimaryColor
#define PR_DARK_TEXT_COLOR APP_THEME_MANAGER.textPrimaryColor
#define PR_PLACEHOLDER_COLOR APP_THEME_MANAGER.textPlaceholderColor
#define PR_INPUT_BG_COLOR APP_THEME_MANAGER.inputBackgroundColor
#define PR_CARD_BG_COLOR APP_THEME_MANAGER.cardBackgroundColor
#define PR_RESULT_BG_COLOR APP_THEME_MANAGER.surfaceSecondaryColor
#define PR_PRIMARY_GREEN_COLOR APP_THEME_MANAGER.primaryColor
#define PR_CHIP_BG_COLOR APP_THEME_MANAGER.surfaceColor
#define PR_CHIP_TEXT_COLOR APP_THEME_MANAGER.textPrimaryColor
#define PR_NAV_TEXT_COLOR APP_THEME_MANAGER.navTextColor
#define PR_MUTED_TEXT_COLOR APP_THEME_MANAGER.textSecondaryColor

#define SB_BG_COLOR APP_THEME_MANAGER.appBackgroundColor
#define SB_START_COLOR APP_THEME_MANAGER.primaryColor
#define SB_EXCHANGE_COLOR APP_THEME_MANAGER.secondaryColor
#define SB_DELETE_COLOR APP_THEME_MANAGER.dangerColor
#define SB_TEXT_MAIN_COLOR APP_THEME_MANAGER.textPrimaryColor
#define SB_TEXT_SUB_COLOR APP_THEME_MANAGER.textSecondaryColor
#define SB_BUTTON_BG_WHITE APP_THEME_MANAGER.cardBackgroundColor
#define SB_DIVIDER_COLOR APP_THEME_MANAGER.dividerColor

@interface UIView (AppStudioFeatureCompat)

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
- (void)showClickedAnimation;
- (void)showClickedAnimationWithLevel:(NSUInteger)level;

@end

@interface UIButton (AppStudioFeatureCompat)

@property(nonatomic, assign) UIEdgeInsets hitTestEdgeInsets;

+ (instancetype)buttonWithTitle:(NSString *)title fontSize:(CGFloat)fontSize bold:(BOOL)bold height:(CGFloat)height titleColor:(UIColor *)titleColor backGroundColor:(UIColor *)backgroundColor;

@end

@interface UILabel (AppStudioFeatureCompat)

+ (instancetype)labelWithText:(NSString *)text fontSize:(NSUInteger)size bold:(BOOL)isBold textColor:(UIColor *)textColor;

@end

@interface NSString (AppStudioFeatureCompat)

@property(nonatomic, readonly) NSString *randomElement;
- (instancetype)appendOrInsertToFront:(NSString *)string;

@end
