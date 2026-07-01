//
//  ScoreboardTeamView.m
//  JiFen
//
//  Created by 蒙俊竹 on 2024/10/10.
//

#import "ScoreboardTeamView.h"
#import "PrefixHeader.h"

@interface ScoreboardTeamView ()

@property(nonatomic, strong) UIButton *increaseButton;
@property(nonatomic, strong) UIButton *decreaseButton;

@end

@implementation ScoreboardTeamView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.score = 0;
        [self setUpUI];
        self.accentColor = RGBA(210, 124, 43, 1);
    }
    return self;
}

#pragma mark - UI

- (void)setUpUI {
    self.backgroundColor = CLEAR_COLOR;

    [self addSubview:self.name];
    [self addSubview:self.scoreBackView];
    [self.scoreBackView addSubview:self.scoreLabel];
    [self.scoreBackView addSubview:self.increaseButton];
    [self.scoreBackView addSubview:self.decreaseButton];

    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.mas_equalTo(ZOOMW(28));
    }];
    [self.scoreBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.name.mas_bottom).offset(ZOOMW(14));
        make.left.right.bottom.equalTo(self);
    }];
    [self.scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scoreBackView).offset(ZOOMW(22));
        make.centerY.equalTo(self.scoreBackView);
    }];
    [self.increaseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scoreBackView).offset(ZOOMW(42));
        make.right.equalTo(self.scoreBackView).offset(-ZOOMW(18));
        make.width.height.mas_equalTo(ZOOMW(40));
    }];
    [self.decreaseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.increaseButton.mas_bottom).offset(ZOOMW(16));
        make.centerX.equalTo(self.increaseButton);
        make.width.height.equalTo(self.increaseButton);
    }];
}

#pragma mark - actions

- (void)increaseScore:(UIButton *)sender {
    [sender showClickedAnimationWithLevel:2];
    if (self.score < 99) {
        self.score++;
        self.scoreLabel.text = [NSString stringWithFormat:@"%02d", self.score];
    }
}

- (void)decreaseScore:(UIButton *)sender {
    [sender showClickedAnimationWithLevel:2];
    if (self.score > 0) {
        self.score--;
        self.scoreLabel.text = [NSString stringWithFormat:@"%02d", self.score];
    }
}

#pragma mark - lazy

- (UILabel *)name {
    if (_name == nil) {
        _name = [[UILabel alloc] init];
        _name.text = @"Squadra 1";
        _name.font = KEEPASS_FONT_Regular(16);
        _name.textColor = RGB(51, 51, 51);
        _name.textAlignment = NSTextAlignmentLeft;
        _name.userInteractionEnabled = YES;
    }
    return _name;
}

- (UIImageView *)scoreBackView {
    if (_scoreBackView == nil) {
        _scoreBackView = [[UIImageView alloc] init];
        _scoreBackView.backgroundColor = WHITE_COLOR;
        _scoreBackView.layer.cornerRadius = ZOOMW(18);
        _scoreBackView.clipsToBounds = YES;
        _scoreBackView.userInteractionEnabled = YES;
    }
    return _scoreBackView;
}

- (UILabel *)scoreLabel {
    if (_scoreLabel == nil) {
        _scoreLabel = [[UILabel alloc] init];
        _scoreLabel.text = @"00";
        _scoreLabel.font = KEEPASS_FONT_Medium(64);
        _scoreLabel.textColor = RGBA(210, 124, 43, 1);
        _scoreLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _scoreLabel;
}

- (UIButton *)increaseButton {
    if (_increaseButton == nil) {
        _increaseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _increaseButton.backgroundColor = RGBA(237, 237, 237, 1);
        _increaseButton.layer.cornerRadius = ZOOMW(20);
        _increaseButton.clipsToBounds = YES;
        _increaseButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        [_increaseButton addTarget:self action:@selector(increaseScore:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _increaseButton;
}

- (UIButton *)decreaseButton {
    if (_decreaseButton == nil) {
        _decreaseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _decreaseButton.backgroundColor = RGBA(237, 237, 237, 1);
        _decreaseButton.layer.cornerRadius = ZOOMW(20);
        _decreaseButton.clipsToBounds = YES;
        _decreaseButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        [_decreaseButton addTarget:self action:@selector(decreaseScore:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _decreaseButton;
}

- (void)setAccentColor:(UIColor *)accentColor {
    _accentColor = accentColor ?: RGBA(210, 124, 43, 1);
    self.scoreLabel.textColor = _accentColor;
    [self updateButtonImages];
}

- (void)updateButtonImages {
    [self.increaseButton setImage:[self scoreGlyphImageWithType:YES] forState:UIControlStateNormal];
    [self.decreaseButton setImage:[self scoreGlyphImageWithType:NO] forState:UIControlStateNormal];
}

- (UIImage *)scoreGlyphImageWithType:(BOOL)isIncrease {
    CGSize size = CGSizeMake(ZOOMW(18), ZOOMW(18));
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    UIColor *accent = self.accentColor ?: RGBA(210, 124, 43, 1);
    CGFloat lineWidth = MAX(2.2, size.width * 0.14);
    CGFloat inset = size.width * 0.18;
    CGFloat midX = size.width * 0.5;
    CGFloat midY = size.height * 0.5;

    UIBezierPath *horizontalPath = [UIBezierPath bezierPath];
    horizontalPath.lineWidth = lineWidth;
    horizontalPath.lineCapStyle = kCGLineCapRound;
    [horizontalPath moveToPoint:CGPointMake(inset, midY)];
    [horizontalPath addLineToPoint:CGPointMake(size.width - inset, midY)];
    [accent setStroke];
    [horizontalPath stroke];

    if (isIncrease) {
        UIBezierPath *verticalPath = [UIBezierPath bezierPath];
        verticalPath.lineWidth = lineWidth;
        verticalPath.lineCapStyle = kCGLineCapRound;
        [verticalPath moveToPoint:CGPointMake(midX, inset)];
        [verticalPath addLineToPoint:CGPointMake(midX, size.height - inset)];
        [accent setStroke];
        [verticalPath stroke];
    }

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
