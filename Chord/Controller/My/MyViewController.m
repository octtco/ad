//
//  MyViewController.m
//  Chord
//
//  Created by 蒙俊竹 on 2026/3/16.
//

#import "MyViewController.h"
#import "FeedbackViewController.h"
#import "SettingViewController.h"

@interface MySettingIconView : UIView
@end

@implementation MySettingIconView {
    CAShapeLayer *_hexagonLayer;
    CAShapeLayer *_dotLayer;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _hexagonLayer = [CAShapeLayer layer];
        _hexagonLayer.fillColor = UIColor.clearColor.CGColor;
        _hexagonLayer.strokeColor = RGB(51, 51, 51).CGColor;
        _hexagonLayer.lineWidth = ZOOMW(2.6);
        [self.layer addSublayer:_hexagonLayer];

        _dotLayer = [CAShapeLayer layer];
        _dotLayer.fillColor = UIColor.clearColor.CGColor;
        _dotLayer.strokeColor = RGB(51, 51, 51).CGColor;
        _dotLayer.lineWidth = ZOOMW(2.2);
        [self.layer addSublayer:_dotLayer];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat side = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    CGFloat radius = side * 0.45;
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));

    UIBezierPath *hexagonPath = [UIBezierPath bezierPath];
    for (NSInteger idx = 0; idx < 6; idx++) {
        CGFloat angle = -M_PI_2 + idx * M_PI / 3.0;
        CGPoint point = CGPointMake(center.x + radius * cos(angle), center.y + radius * sin(angle));
        if (idx == 0) {
            [hexagonPath moveToPoint:point];
        } else {
            [hexagonPath addLineToPoint:point];
        }
    }
    [hexagonPath closePath];
    _hexagonLayer.path = hexagonPath.CGPath;

    CGFloat dotRadius = side * 0.12;
    UIBezierPath *dotPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(center.x - dotRadius, center.y - dotRadius, dotRadius * 2, dotRadius * 2)];
    _dotLayer.path = dotPath.CGPath;
}

@end

@interface MyViewController ()

@property(nonatomic, strong) UIControl *feedbackCard;
@property(nonatomic, strong) UIControl *settingCard;

@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGBA(246, 246, 246, 1);
    [self setupNavigationBar];
    [self setupUI];
}

#pragma mark - setupUI

- (void)setupNavigationBar {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Mio";
    titleLabel.textColor = RGB(51, 51, 51);
    titleLabel.font = KEEPASS_FONT_Medium(18);
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
}

- (void)setupUI {
    [self.view addSubview:self.feedbackCard];
    [self.view addSubview:self.settingCard];

    [self.feedbackCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(ZOOMW(24));
        make.left.equalTo(self.view).offset(ZOOMW(16));
        make.height.mas_equalTo(ZOOMW(112));
    }];
    [self.settingCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.width.equalTo(self.feedbackCard);
        make.left.equalTo(self.feedbackCard.mas_right).offset(ZOOMW(12));
        make.right.equalTo(self.view).offset(-ZOOMW(16));
    }];
}

#pragma mark - events

- (void)feedbackCardTapped {
    FeedbackViewController *feedbackVC = [[FeedbackViewController alloc] init];
    feedbackVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:feedbackVC animated:YES];
}

- (void)settingCardTapped {
    SettingViewController *settingVC = [[SettingViewController alloc] init];
    settingVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:settingVC animated:YES];
}

#pragma mark - builders

- (UIControl *)feedbackCard {
    if (!_feedbackCard) {
        _feedbackCard = [self buildCardWithTitle:@"Feedback" iconView:[self buildFeedbackIcon] action:@selector(feedbackCardTapped)];
    }
    return _feedbackCard;
}

- (UIControl *)settingCard {
    if (!_settingCard) {
        _settingCard = [self buildCardWithTitle:@"Impostare" iconView:[self buildSettingIcon] action:@selector(settingCardTapped)];
    }
    return _settingCard;
}

- (UIControl *)buildCardWithTitle:(NSString *)title iconView:(UIView *)iconView action:(SEL)action {
    UIControl *card = [[UIControl alloc] init];
    card.backgroundColor = WHITE_COLOR;
    card.layer.cornerRadius = ZOOMW(18);
    card.clipsToBounds = YES;
    [card addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.textColor = RGB(51, 51, 51);
    titleLabel.font = KEEPASS_FONT_Regular(16);
    [card addSubview:iconView];
    [card addSubview:titleLabel];

    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(card).offset(ZOOMW(18));
        make.centerY.equalTo(card);
        make.width.height.mas_equalTo(ZOOMW(36));
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconView.mas_right).offset(ZOOMW(10));
        make.centerY.equalTo(card);
        make.right.lessThanOrEqualTo(card).offset(-ZOOMW(10));
    }];
    titleLabel.lineBreakMode = NSLineBreakByClipping;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 0.92;
    return card;
}

- (UIView *)buildFeedbackIcon {
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"A_CountDown_icon"]];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    return iconView;
}

- (UIView *)buildSettingIcon {
    MySettingIconView *iconView = [[MySettingIconView alloc] init];
    return iconView;
}

@end
