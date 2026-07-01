//
//  CountDownMusicModeView.m
//  WePage
//
//  Created by 蒙俊竹 on 2025/2/8.
//

#import "CountDownMusicModeView.h"
#import "PrefixHeader.h"

static NSString * const kCountDownMusicModeSelectionDidChangeNotification = @"CountDownMusicModeSelectionDidChangeNotification";
static NSInteger const kCountDownMusicModeCount = 3;

@interface CountDownMusicModeView () <UIScrollViewDelegate>

@property (nonatomic, assign, readwrite) NSInteger selectedModeIndex;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSArray<UIView *> *cardViews;
@property (nonatomic, strong) NSArray<UIImageView *> *playIcons;
@property (nonatomic, assign) CGFloat cardWidth;
@property (nonatomic, assign) CGFloat cardGap;
@property (nonatomic, assign) CGSize lastLayoutSize;

@end

@implementation CountDownMusicModeView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.delegate = self;
        self.backgroundColor = CLEAR_COLOR;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.alwaysBounceVertical = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self setUpUI];
        [self selectModeAtIndex:0];
        [self updatePlaybackState:NO currentIndex:NSNotFound];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (CGSizeEqualToSize(self.bounds.size, CGSizeZero)) {
        return;
    }
    if (!CGSizeEqualToSize(self.bounds.size, self.lastLayoutSize)) {
        self.lastLayoutSize = self.bounds.size;
        [self updateLayoutFrames];
        [self setContentOffset:CGPointMake([self contentOffsetXForIndex:self.selectedModeIndex], 0) animated:NO];
    } else {
        [self updateCardAppearance];
    }
}

#pragma mark - Public

- (NSString *)modeFileAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
            return @"violin.mp3";
        case 1:
            return @"piano.mp3";
        case 2:
            return @"guitar.mp3";
        default:
            return @"violin.mp3";
    }
}

- (void)selectModeAtIndex:(NSInteger)index {
    NSInteger validIndex = [self validatedIndex:index];
    self.selectedModeIndex = validIndex;
    self.mode = [self modeFileAtIndex:validIndex];
    [self updateCardAppearance];
    if (!CGSizeEqualToSize(self.bounds.size, CGSizeZero)) {
        [self setContentOffset:CGPointMake([self contentOffsetXForIndex:validIndex], 0) animated:YES];
    }
}

- (void)updatePlaybackState:(BOOL)isPlaying currentIndex:(NSInteger)currentIndex {
    [self.playIcons enumerateObjectsUsingBlock:^(UIImageView * _Nonnull iconView, NSUInteger idx, BOOL * _Nonnull stop) {
        iconView.image = [self playbackIconImageIsPlaying:(isPlaying && idx == currentIndex)];
    }];
}

- (void)modeShouldUpdate:(UIButton *)button {
    if (button == self.violinButton) {
        [self selectModeAtIndex:0];
    } else if (button == self.pianoButton) {
        [self selectModeAtIndex:1];
    } else if (button == self.guitarButton) {
        [self selectModeAtIndex:2];
    }
}

#pragma mark - Setup

- (void)setUpUI {
    [self addSubview:self.contentView];

    UIView *violinCard = [self buildCardWithImage:@"A_Violin" button:&_violinButton icon:&_violinPlayIcon];
    UIView *pianoCard = [self buildCardWithImage:@"A_Piano" button:&_pianoButton icon:&_pianoPlayIcon];
    UIView *guitarCard = [self buildCardWithImage:@"A_Guitar" button:&_guitarButton icon:&_guitarPlayIcon];

    self.cardViews = @[violinCard, pianoCard, guitarCard];
    self.playIcons = @[self.violinPlayIcon, self.pianoPlayIcon, self.guitarPlayIcon];

    for (UIView *cardView in self.cardViews) {
        [self.contentView addSubview:cardView];
    }
}

#pragma mark - Layout

- (void)updateLayoutFrames {
    CGFloat viewWidth = CGRectGetWidth(self.bounds);
    CGFloat viewHeight = CGRectGetHeight(self.bounds);
    self.cardGap = ZOOMW(18);
    self.cardWidth = MAX(ZOOMW(280), MIN(viewWidth - ZOOMW(72), ZOOMW(304)));
    CGFloat cardHeight = MIN(viewHeight - ZOOMW(8), self.cardWidth * 0.99);
    CGFloat sideInset = MAX((viewWidth - self.cardWidth) * 0.5, 0);
    CGFloat cardTop = MAX((viewHeight - cardHeight) * 0.5, 0);
    CGFloat contentWidth = self.cardWidth * kCountDownMusicModeCount + self.cardGap * (kCountDownMusicModeCount - 1);
    CGFloat iconSize = ZOOMW(116);

    self.contentInset = UIEdgeInsetsMake(0, sideInset, 0, sideInset);
    self.contentSize = CGSizeMake(contentWidth, viewHeight);
    self.contentView.frame = CGRectMake(0, 0, contentWidth, viewHeight);

    [self.cardViews enumerateObjectsUsingBlock:^(UIView * _Nonnull cardView, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat cardLeft = idx * (self.cardWidth + self.cardGap);
        cardView.frame = CGRectMake(cardLeft, cardTop, self.cardWidth, cardHeight);

        UIImageView *playIcon = self.playIcons[idx];
        playIcon.frame = CGRectMake(0, 0, iconSize, iconSize);
        playIcon.center = CGPointMake(CGRectGetMidX(cardView.bounds), CGRectGetMidY(cardView.bounds));
    }];

    [self updateCardAppearance];
}

- (void)updateCardAppearance {
    if (self.cardViews.count == 0 || CGRectGetWidth(self.bounds) <= 0) {
        return;
    }

    CGFloat viewMidX = self.contentOffset.x + CGRectGetWidth(self.bounds) * 0.5;
    CGFloat itemSpacing = self.cardWidth + self.cardGap;

    [self.cardViews enumerateObjectsUsingBlock:^(UIView * _Nonnull cardView, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat distance = fabs(CGRectGetMidX(cardView.frame) - viewMidX);
        CGFloat progress = MIN(distance / MAX(itemSpacing, 1), 1);
        CGFloat scale = 1.0 - 0.08 * progress;
        CGFloat alpha = 1.0 - 0.22 * progress;
        cardView.transform = CGAffineTransformMakeScale(scale, scale);
        cardView.alpha = alpha;
        cardView.layer.shadowOpacity = (idx == self.selectedModeIndex) ? 0.16 : 0.08;
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateCardAppearance];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSInteger nearestIndex = [self nearestIndexForOffsetX:targetContentOffset->x];
    targetContentOffset->x = [self contentOffsetXForIndex:nearestIndex];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self notifySelectionIfNeeded];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self notifySelectionIfNeeded];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self notifySelectionIfNeeded];
}

#pragma mark - Helpers

- (UIView *)buildCardWithImage:(NSString *)imageName
                        button:(UIButton * __strong *)button
                          icon:(UIImageView * __strong *)icon {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = WHITE_COLOR;
    card.layer.cornerRadius = ZOOMW(34);
    card.layer.masksToBounds = NO;
    card.layer.shadowColor = RGB(0, 0, 0).CGColor;
    card.layer.shadowOffset = CGSizeMake(0, ZOOMW(8));
    card.layer.shadowRadius = ZOOMW(18);
    card.layer.shadowOpacity = 0.12;

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    imageView.frame = card.bounds;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.layer.cornerRadius = card.layer.cornerRadius;
    [card addSubview:imageView];

    UIButton *overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    overlayButton.frame = card.bounds;
    overlayButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [card addSubview:overlayButton];

    UIImageView *playIcon = [[UIImageView alloc] init];
    playIcon.contentMode = UIViewContentModeScaleAspectFit;
    playIcon.userInteractionEnabled = NO;
    [card addSubview:playIcon];

    *button = overlayButton;
    *icon = playIcon;
    return card;
}

- (UIImage *)playbackIconImageIsPlaying:(BOOL)isPlaying {
    CGFloat side = ZOOMW(116);
    CGSize size = CGSizeMake(side, side);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGPoint center = CGPointMake(side * 0.5, side * 0.5);
    CGFloat circleRadius = side * 0.36;
    UIColor *accent = RGBA(255, 91, 25, 1);

    [[UIColor colorWithWhite:1 alpha:0.95] setFill];
    [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(center.x - circleRadius, center.y - circleRadius, circleRadius * 2, circleRadius * 2)] fill];

    if (isPlaying) {
        CGFloat barHeight = side * 0.22;
        CGFloat barWidth = side * 0.07;
        CGFloat gap = side * 0.06;
        UIBezierPath *leftBar = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(center.x - gap - barWidth, center.y - barHeight * 0.5, barWidth, barHeight)
                                                           cornerRadius:barWidth * 0.5];
        UIBezierPath *rightBar = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(center.x + gap, center.y - barHeight * 0.5, barWidth, barHeight)
                                                            cornerRadius:barWidth * 0.5];
        [accent setFill];
        [leftBar fill];
        [rightBar fill];
    } else {
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, center.x - side * 0.07, center.y - side * 0.125);
        CGContextAddLineToPoint(ctx, center.x + side * 0.14, center.y);
        CGContextAddLineToPoint(ctx, center.x - side * 0.07, center.y + side * 0.125);
        CGContextClosePath(ctx);
        CGContextSetFillColorWithColor(ctx, accent.CGColor);
        CGContextFillPath(ctx);
    }

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (NSInteger)validatedIndex:(NSInteger)index {
    return MAX(0, MIN(index, kCountDownMusicModeCount - 1));
}

- (NSInteger)nearestIndexForOffsetX:(CGFloat)offsetX {
    CGFloat sideInset = self.contentInset.left;
    CGFloat itemSpacing = MAX(self.cardWidth + self.cardGap, 1);
    NSInteger index = (NSInteger)llround((offsetX + sideInset) / itemSpacing);
    return [self validatedIndex:index];
}

- (CGFloat)contentOffsetXForIndex:(NSInteger)index {
    CGFloat sideInset = self.contentInset.left;
    CGFloat itemSpacing = self.cardWidth + self.cardGap;
    CGFloat targetOffset = index * itemSpacing - sideInset;
    CGFloat maxOffset = MAX(self.contentSize.width + self.contentInset.right - CGRectGetWidth(self.bounds), -sideInset);
    return MIN(MAX(targetOffset, -sideInset), maxOffset);
}

- (void)notifySelectionIfNeeded {
    NSInteger nearestIndex = [self nearestIndexForOffsetX:self.contentOffset.x];
    BOOL changed = nearestIndex != self.selectedModeIndex;
    self.selectedModeIndex = nearestIndex;
    self.mode = [self modeFileAtIndex:nearestIndex];
    [self updateCardAppearance];
    if (!changed) {
        return;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kCountDownMusicModeSelectionDidChangeNotification
                                                        object:self
                                                      userInfo:@{@"index": @(nearestIndex)}];
}

- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = CLEAR_COLOR;
    }
    return _contentView;
}

@end
