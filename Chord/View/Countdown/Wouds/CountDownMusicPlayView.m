//
//  CountDownMusicPlayView.m
//  WePage
//
//  Created by 蒙俊竹 on 2025/2/8.
//

#import "CountDownMusicPlayView.h"
#import "CountDownMusicModeView.h"
#import "PrefixHeader.h"

static NSInteger const kCountDownMusicModeCount = 3;
static NSString * const kCountDownMusicGuideShownKey = @"ChordMusicGuideShown";
static NSString * const kCountDownMusicModeSelectionDidChangeNotification = @"CountDownMusicModeSelectionDidChangeNotification";

@interface CountDownMusicGuideAlertView : UIView

@property (nonatomic, copy) dispatch_block_t confirmBlock;

@end

@implementation CountDownMusicGuideAlertView {
    UIView *_contentView;
}

- (instancetype)init {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.48];

        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = WHITE_COLOR;
        _contentView.layer.cornerRadius = ZOOMW(18);
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];

        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"Suggerimenti";
        titleLabel.textColor = RGB(51, 51, 51);
        titleLabel.font = KEEPASS_FONT_Medium(22);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [_contentView addSubview:titleLabel];

        UILabel *messageLabel = [[UILabel alloc] init];
        messageLabel.text = @"Utilizzando questa funzione,\nl'audio verrà riprodotto\ncontinuamente in\nbackground.";
        messageLabel.textColor = RGB(51, 51, 51);
        messageLabel.font = KEEPASS_FONT_Regular(18);
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.numberOfLines = 0;
        [_contentView addSubview:messageLabel];

        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = RGBA(230, 230, 230, 1);
        [_contentView addSubview:lineView];

        UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [confirmButton setTitle:@"Confermare" forState:UIControlStateNormal];
        [confirmButton setTitleColor:RGBA(255, 91, 25, 1) forState:UIControlStateNormal];
        confirmButton.titleLabel.font = KEEPASS_FONT_Medium(18);
        [confirmButton addTarget:self action:@selector(confirmButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:confirmButton];

        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.left.equalTo(self).offset(ZOOMW(32));
            make.right.equalTo(self).offset(-ZOOMW(32));
        }];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_contentView).offset(ZOOMW(26));
            make.left.right.equalTo(_contentView).inset(ZOOMW(18));
        }];
        [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel.mas_bottom).offset(ZOOMW(24));
            make.left.equalTo(_contentView).offset(ZOOMW(28));
            make.right.equalTo(_contentView).offset(-ZOOMW(28));
        }];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(messageLabel.mas_bottom).offset(ZOOMW(28));
            make.left.right.equalTo(_contentView);
            make.height.mas_equalTo(1);
        }];
        [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lineView.mas_bottom);
            make.left.right.bottom.equalTo(_contentView);
            make.height.mas_equalTo(ZOOMW(64));
        }];
    }
    return self;
}

- (void)confirmButtonTapped {
    if (self.confirmBlock) {
        self.confirmBlock();
    }
    [self removeFromSuperview];
}

@end

@interface CountDownMusicPlayView ()

@property (nonatomic, strong) CountDownMusicModeView *modeView;
@property (nonatomic, strong) UILabel *currentModeNameLabel;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) id timeObserverToken;
@property (nonatomic, assign) NSInteger currentModeIndex;
@property (nonatomic, assign) NSInteger playingModeIndex;

@end

@implementation CountDownMusicPlayView

- (NSArray<NSString *> *)modeDisplayNames {
    return @[@"Violino", @"Pianoforte", @"Chitarra"];
}

- (void)dealloc {
    [self tearDownPlayerObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentModeIndex = 0;
        _playingModeIndex = NSNotFound;
        [self setUpUI];
        [self setUpEvents];
        [self.modeView selectModeAtIndex:0];
        [self.modeView updatePlaybackState:NO currentIndex:_playingModeIndex];
        [self updateCurrentModeName];
    }
    return self;
}

#pragma mark - UI Events

- (void)handleModeButtonTapped:(UIButton *)sender {
    NSInteger tappedIndex = [self indexForModeButton:sender];
    if (tappedIndex == NSNotFound) {
        return;
    }

    self.currentModeIndex = tappedIndex;
    [self.modeView selectModeAtIndex:tappedIndex];
    [self updateCurrentModeName];

    if (self.playingModeIndex == tappedIndex) {
        [self togglePlayPause];
        return;
    }

    [self beginPlaybackFlow];
}

- (void)togglePlayPause {
    if (self.player == nil || self.player.currentItem == nil || self.playingModeIndex == NSNotFound) {
        [self beginPlaybackFlow];
        return;
    }

    if (self.player.rate > 0.0) {
        [self.player pause];
    } else {
        [self prepareAudioSessionIfNeeded];
        [self.player play];
    }
    [self syncPlaybackState];
}

- (void)handleModeSelectionDidChange:(NSNotification *)notification {
    NSNumber *indexNumber = notification.userInfo[@"index"];
    if (![indexNumber isKindOfClass:[NSNumber class]]) {
        return;
    }

    NSInteger index = indexNumber.integerValue;
    if (index == self.currentModeIndex) {
        return;
    }

    self.currentModeIndex = index;
    [self updateCurrentModeName];
}

#pragma mark - Setup

- (void)setUpUI {
    self.backgroundColor = CLEAR_COLOR;
    [self addSubview:self.modeView];
    [self addSubview:self.currentModeNameLabel];

    [self.modeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(ZOOMW(18));
        make.left.right.equalTo(self);
        make.height.mas_equalTo(ZOOMW(336));
    }];

    [self.currentModeNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.modeView.mas_bottom).offset(ZOOMW(28));
        make.centerX.equalTo(self);
        make.left.greaterThanOrEqualTo(self).offset(ZOOMW(24));
        make.right.lessThanOrEqualTo(self).offset(-ZOOMW(24));
    }];
}

- (void)setUpEvents {
    [self.modeView.violinButton addTarget:self action:@selector(handleModeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.modeView.pianoButton addTarget:self action:@selector(handleModeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.modeView.guitarButton addTarget:self action:@selector(handleModeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleModeSelectionDidChange:)
                                                 name:kCountDownMusicModeSelectionDidChangeNotification
                                               object:self.modeView];
}

- (NSInteger)indexForModeButton:(UIButton *)button {
    if (button == self.modeView.violinButton) {
        return 0;
    }
    if (button == self.modeView.pianoButton) {
        return 1;
    }
    if (button == self.modeView.guitarButton) {
        return 2;
    }
    return NSNotFound;
}

#pragma mark - Playback

- (void)beginPlaybackFlow {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kCountDownMusicGuideShownKey]) {
        [self playCurrentMode];
        return;
    }

    CountDownMusicGuideAlertView *alertView = [[CountDownMusicGuideAlertView alloc] init];
    __weak typeof(self) weakSelf = self;
    alertView.confirmBlock = ^{
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kCountDownMusicGuideShownKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [weakSelf playCurrentMode];
    };

    UIView *hostView = [self alertHostView];
    alertView.frame = hostView.bounds;
    alertView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [hostView addSubview:alertView];
}

- (void)prepareAudioSessionIfNeeded {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
        [audioSession setActive:YES error:nil];
    });
}

- (void)playCurrentMode {
    NSString *fileName = [self.modeView modeFileAtIndex:self.currentModeIndex];
    NSURL *url = [[NSBundle mainBundle] URLForResource:fileName withExtension:nil];
    if (url == nil) {
        return;
    }

    [self prepareAudioSessionIfNeeded];
    [self replacePlayerItemWithURL:url];
    self.playingModeIndex = self.currentModeIndex;
    [self.player play];
    [self syncPlaybackState];
}

- (void)replacePlayerItemWithURL:(NSURL *)url {
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    if (self.player == nil) {
        self.player = [AVPlayer playerWithPlayerItem:item];
        [self installPlayerObserverIfNeeded];
    } else {
        [self.player replaceCurrentItemWithPlayerItem:item];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(runLoopTheMovie:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:item];
}

- (void)playNextMode {
    self.currentModeIndex = (self.currentModeIndex + 1) % kCountDownMusicModeCount;
    [self.modeView selectModeAtIndex:self.currentModeIndex];
    [self updateCurrentModeName];
    [self playCurrentMode];
}

- (void)runLoopTheMovie:(NSNotification *)notification {
    __weak typeof(self) weakSelf = self;
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        if (!finished) {
            return;
        }
        [weakSelf.player play];
        [weakSelf syncPlaybackState];
    }];
}

- (void)installPlayerObserverIfNeeded {
    if (self.player == nil || self.timeObserverToken != nil) {
        return;
    }

    __weak typeof(self) weakSelf = self;
    self.timeObserverToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 5)
                                                                       queue:dispatch_get_main_queue()
                                                                  usingBlock:^(CMTime time) {
        [weakSelf syncPlaybackState];
    }];
}

- (void)tearDownPlayerObserver {
    if (self.player != nil && self.timeObserverToken != nil) {
        [self.player removeTimeObserver:self.timeObserverToken];
        self.timeObserverToken = nil;
    }
}

- (void)syncPlaybackState {
    BOOL isPlaying = self.player != nil && self.player.rate > 0.0 && self.player.error == nil;
    [self.modeView updatePlaybackState:isPlaying currentIndex:self.playingModeIndex];
}

#pragma mark - Helpers

- (void)updateCurrentModeName {
    NSInteger safeIndex = MAX(0, MIN(self.currentModeIndex, self.modeDisplayNames.count - 1));
    self.currentModeNameLabel.text = self.modeDisplayNames[safeIndex];
}

- (UIView *)alertHostView {
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (![scene isKindOfClass:[UIWindowScene class]]) {
                continue;
            }
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            for (UIWindow *window in windowScene.windows) {
                if (window.isKeyWindow) {
                    return window;
                }
            }
        }
    }
    return self.window ?: self;
}

- (CountDownMusicModeView *)modeView {
    if (_modeView == nil) {
        _modeView = [[CountDownMusicModeView alloc] init];
    }
    return _modeView;
}

- (UILabel *)currentModeNameLabel {
    if (_currentModeNameLabel == nil) {
        _currentModeNameLabel = [[UILabel alloc] init];
        _currentModeNameLabel.textAlignment = NSTextAlignmentCenter;
        _currentModeNameLabel.font = KEEPASS_FONT_Medium(18);
        _currentModeNameLabel.textColor = RGB(51, 51, 51);
    }
    return _currentModeNameLabel;
}

@end
