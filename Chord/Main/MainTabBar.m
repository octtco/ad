//
//  MainTabBar.m
//  Chord
//

#import "MainTabBar.h"

@implementation MainTabBar

- (void)setAppearanceWithBackgroundColor:(UIColor *)backgroundColor
                           selectedColor:(UIColor *)selectedColor
                         unselectedColor:(UIColor *)unselectedColor {
    UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = backgroundColor;
    
    appearance.stackedLayoutAppearance.selected.iconColor = selectedColor;
    appearance.stackedLayoutAppearance.selected.titleTextAttributes = @{NSForegroundColorAttributeName: selectedColor};
    appearance.stackedLayoutAppearance.normal.iconColor = unselectedColor;
    appearance.stackedLayoutAppearance.normal.titleTextAttributes = @{NSForegroundColorAttributeName: unselectedColor};
    
    self.standardAppearance = appearance;
    if (@available(iOS 15.0, *)) {
        self.scrollEdgeAppearance = appearance;
    }
}

@end
