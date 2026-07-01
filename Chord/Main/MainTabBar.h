//
//  MainTabBar.h
//  Chord
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainTabBar : UITabBar

- (void)setAppearanceWithBackgroundColor:(UIColor *)backgroundColor
                           selectedColor:(UIColor *)selectedColor
                         unselectedColor:(UIColor *)unselectedColor;

@end

NS_ASSUME_NONNULL_END
