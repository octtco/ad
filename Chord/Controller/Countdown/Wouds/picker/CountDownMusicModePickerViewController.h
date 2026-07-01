//
//  CountDownMusicModePickerViewController.h
//  WeStream
//
//  Created by 刘一夫 on 2025/6/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^CountDownMusicSelectionBlock)(NSString *data);

@interface CountDownMusicModePickerViewController : UIViewController

@property (nonatomic, copy) CountDownMusicSelectionBlock returnBlock;

@end

NS_ASSUME_NONNULL_END
