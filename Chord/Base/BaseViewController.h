//
//  BaseViewController.h
//  Chord
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController

- (void)configureNavigationBar;
- (void)showLoading;
- (void)hideLoading;
- (void)showEmptyViewWithMessage:(NSString *)message;
- (void)hideEmptyView;

@end

NS_ASSUME_NONNULL_END
