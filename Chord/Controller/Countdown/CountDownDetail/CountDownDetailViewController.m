//
//  CountDownDetailViewController.m
//  CountDown
//
//  Created by 刘一夫 on 2025/7/23.
//

#import "CountDownDetailViewController.h"
#import "CountDownAdd.h"

static UIFont *CountDownDetailSafeRegularFont(CGFloat size) {
    UIFont *font = KEEPASS_FONT_Regular(size);
    return font ?: [UIFont systemFontOfSize:size];
}

static UIFont *CountDownDetailSafeMediumFont(CGFloat size) {
    UIFont *font = KEEPASS_FONT_Medium(size);
    return font ?: [UIFont systemFontOfSize:size weight:UIFontWeightMedium];
}

@interface CountDownDetailViewController ()

@property(nonatomic, strong) UIImageView *backgroundView;
@property(nonatomic, strong) UIButton *backButton;
@property(nonatomic, strong) UILabel *pageTitleLabel;
@property(nonatomic, strong) UIButton *editButton;
@property(nonatomic, strong) UIView *cardView;
@property(nonatomic, strong) UIView *cardHeaderView;
@property(nonatomic, strong) UILabel *cardTitleLabel;
@property(nonatomic, strong) UILabel *daysLabel;
@property(nonatomic, strong) UILabel *timeLabel;
@property(nonatomic, strong) UIView *cardFooterView;
@property(nonatomic, strong) UILabel *targetDateLabel;

@end

@implementation CountDownDetailViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        self.view.backgroundColor = BLACK_COLOR;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self refreshContent];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshContent];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)setCountDown:(CountDownModel *)CountDown {
    _CountDown = CountDown;
}

#pragma mark - Setup UI

- (void)setupUI {
    [self.view addSubview:self.backgroundView];
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.pageTitleLabel];
    [self.view addSubview:self.editButton];
    [self.view addSubview:self.cardView];

    [self.cardView addSubview:self.cardHeaderView];
    [self.cardHeaderView addSubview:self.cardTitleLabel];
    [self.cardView addSubview:self.daysLabel];
    [self.cardView addSubview:self.timeLabel];
    [self.cardView addSubview:self.cardFooterView];
    [self.cardFooterView addSubview:self.targetDateLabel];

    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(ZOOMW(16));
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(ZOOMW(14));
        make.width.height.mas_equalTo(ZOOMW(24));
    }];
    [self.pageTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backButton.mas_right).offset(ZOOMW(16));
        make.centerY.equalTo(self.backButton);
        make.right.lessThanOrEqualTo(self.editButton.mas_left).offset(-ZOOMW(20));
    }];
    [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-ZOOMW(16));
        make.centerY.equalTo(self.backButton);
        make.width.height.mas_equalTo(ZOOMW(24));
    }];
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.pageTitleLabel.mas_bottom).offset(ZOOMW(120));
        make.width.mas_equalTo(ZOOMW(300));
        make.height.mas_equalTo(ZOOMW(280));
    }];
    [self.cardHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.cardView);
        make.height.mas_equalTo(ZOOMW(60));
    }];
    [self.cardTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.cardHeaderView);
    }];
    [self.daysLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.cardView).inset(ZOOMW(20));
        make.top.equalTo(self.cardHeaderView.mas_bottom).offset(ZOOMW(16));
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.cardView);
        make.top.equalTo(self.daysLabel.mas_bottom).offset(ZOOMW(22));
    }];
    [self.cardFooterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.cardView);
        make.height.mas_equalTo(ZOOMW(44));
    }];
    [self.targetDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.cardFooterView);
    }];
}

#pragma mark - Data

- (void)refreshContent {
    [self.CountDown updateRemainingDays];
    self.pageTitleLabel.text = self.CountDown.Title.length > 0 ? self.CountDown.Title : @"--";
    self.daysLabel.attributedText = [self dayTextForCountDown:self.CountDown];
    self.timeLabel.text = [self timeTextForCountDown:self.CountDown];
    self.targetDateLabel.text = [NSString stringWithFormat:@"Data prevista: %@", [self targetDateTextForCountDown:self.CountDown]];
    self.backgroundView.image = [UIImage imageNamed:self.CountDown.BackGroundName.length > 0 ? self.CountDown.BackGroundName : @"A_B1"];
}

- (NSAttributedString *)dayTextForCountDown:(CountDownModel *)model {
    NSInteger days = MAX((NSInteger)model.RemainingDays, 0);
    NSString *unit = days == 1 ? @"giorno" : @"giorni";
    NSString *numberText = [NSString stringWithFormat:@"%ld", (long)days];
    NSString *fullText = [NSString stringWithFormat:@"%@ %@", numberText, unit];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:fullText];
    UIFont *numberFont = CountDownDetailSafeMediumFont(72);
    UIFont *unitFont = CountDownDetailSafeRegularFont(34);
    [text addAttributes:@{
        NSFontAttributeName: numberFont,
        NSForegroundColorAttributeName: RGB(51, 51, 51)
    } range:[fullText rangeOfString:numberText]];
    [text addAttributes:@{
        NSFontAttributeName: unitFont,
        NSForegroundColorAttributeName: RGB(51, 51, 51),
        NSBaselineOffsetAttributeName: @(-10)
    } range:[fullText rangeOfString:unit]];
    return text;
}

- (NSString *)timeTextForCountDown:(CountDownModel *)model {
    if (!model.TargetDate) {
        return @"--: --: --";
    }
    NSTimeInterval interval = fabs([model.TargetDate timeIntervalSinceDate:[NSDate date]]);
    NSInteger totalSeconds = MAX((NSInteger)llround(interval), 0);
    NSInteger hours = (totalSeconds / 3600) % 24;
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger seconds = totalSeconds % 60;
    return [NSString stringWithFormat:@"%02ld: %02ld: %02ld", (long)hours, (long)minutes, (long)seconds];
}

- (NSString *)targetDateTextForCountDown:(CountDownModel *)model {
    if (!model.TargetDate) {
        return @"--";
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"it_IT"];
    formatter.dateFormat = @"dd/MM/yyyy";
    return [formatter stringFromDate:model.TargetDate];
}

#pragma mark - Actions

- (void)dismissSelf {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)gotoEdit {
    CountDownAdd *editVC = [[CountDownAdd alloc] init];
    editVC.editingModel = self.CountDown;
    [self presentViewController:editVC animated:YES completion:nil];
}

#pragma mark - Lazy

- (UIImageView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"A_B1"]];
        _backgroundView.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundView.clipsToBounds = YES;
    }
    return _backgroundView;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"A_returnwhite"] forState:UIControlStateNormal];
        _backButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
        [_backButton addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UILabel *)pageTitleLabel {
    if (!_pageTitleLabel) {
        _pageTitleLabel = [[UILabel alloc] init];
        _pageTitleLabel.textColor = WHITE_COLOR;
        _pageTitleLabel.font = KEEPASS_FONT_Medium(18);
        _pageTitleLabel.numberOfLines = 1;
        _pageTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _pageTitleLabel;
}

- (UIButton *)editButton {
    if (!_editButton) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editButton setImage:[UIImage imageNamed:@"A_goedit"] forState:UIControlStateNormal];
        _editButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
        [_editButton addTarget:self action:@selector(gotoEdit) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editButton;
}

- (UIView *)cardView {
    if (!_cardView) {
        _cardView = [[UIView alloc] init];
        _cardView.backgroundColor = WHITE_COLOR;
        _cardView.layer.cornerRadius = ZOOMW(20);
        _cardView.clipsToBounds = YES;
    }
    return _cardView;
}

- (UIView *)cardHeaderView {
    if (!_cardHeaderView) {
        _cardHeaderView = [[UIView alloc] init];
        _cardHeaderView.backgroundColor = RGBA(245, 117, 64, 1);
    }
    return _cardHeaderView;
}

- (UILabel *)cardTitleLabel {
    if (!_cardTitleLabel) {
        _cardTitleLabel = [[UILabel alloc] init];
        _cardTitleLabel.text = @"Conto alla rovescia";
        _cardTitleLabel.textColor = WHITE_COLOR;
        _cardTitleLabel.font = KEEPASS_FONT_Medium(20);
    }
    return _cardTitleLabel;
}

- (UILabel *)daysLabel {
    if (!_daysLabel) {
        _daysLabel = [[UILabel alloc] init];
        _daysLabel.textAlignment = NSTextAlignmentCenter;
        _daysLabel.numberOfLines = 1;
        _daysLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _daysLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = RGB(51, 51, 51);
        _timeLabel.font = KEEPASS_FONT_Regular(28);
        _timeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _timeLabel;
}

- (UIView *)cardFooterView {
    if (!_cardFooterView) {
        _cardFooterView = [[UIView alloc] init];
        _cardFooterView.backgroundColor = RGBA(241, 241, 241, 1);
    }
    return _cardFooterView;
}

- (UILabel *)targetDateLabel {
    if (!_targetDateLabel) {
        _targetDateLabel = [[UILabel alloc] init];
        _targetDateLabel.textColor = RGB(102, 102, 102);
        _targetDateLabel.font = KEEPASS_FONT_Regular(14);
        _targetDateLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _targetDateLabel;
}

@end
