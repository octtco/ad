//
//  CountDownMusicModeView.h
//  WePage
//
//  Created by 蒙俊竹 on 2025/2/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CountDownMusicModeView : UIScrollView

@property (strong, nonatomic) NSString *mode;
@property (nonatomic, assign, readonly) NSInteger selectedModeIndex;

@property (nonatomic, strong) UIButton *violinButton;
@property (nonatomic, strong) UIButton *pianoButton;
@property (nonatomic, strong) UIButton *guitarButton;

@property (nonatomic, strong) UIImageView *violinPlayIcon;
@property (nonatomic, strong) UIImageView *pianoPlayIcon;
@property (nonatomic, strong) UIImageView *guitarPlayIcon;

- (NSString *)modeFileAtIndex:(NSInteger)index;
- (void)selectModeAtIndex:(NSInteger)index;
- (void)updatePlaybackState:(BOOL)isPlaying currentIndex:(NSInteger)currentIndex;
- (void)modeShouldUpdate:(UIButton *)button;

@end

NS_ASSUME_NONNULL_END
