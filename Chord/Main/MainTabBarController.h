//
//  MainTabBarController.h
//  Chord
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainTabBarController : UITabBarController

- (void)registerTabWithViewController:(UIViewController *)viewController
                                title:(NSString *)title
                            imageName:(nullable NSString *)imageName
                    selectedImageName:(nullable NSString *)selectedImageName;

- (void)configureTabs;

@end

NS_ASSUME_NONNULL_END
