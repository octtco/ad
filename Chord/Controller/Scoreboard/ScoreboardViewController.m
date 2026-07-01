//
//  ScoreboardViewController.m
//  JiFen
//
//  Created by 蒙俊竹 on 2024/10/10.
//

#import "ScoreboardViewController.h"
#import "PrefixHeader.h"
#import "ScoreboardTeamView.h"
#import "ScoreboardTimerView.h"
#import "FeedbackViewController.h"


@interface ScoreboardViewController ()


@property(strong, nonatomic) ScoreboardTimerView *timeView;
@property(strong, nonatomic) ScoreboardTeamView *teamView_left;
@property(strong, nonatomic) ScoreboardTeamView *teamView_right;
@property(strong, nonatomic) UIView *scorePanelView;
@property(strong, nonatomic) UIImageView *imageVS;
@property(strong, nonatomic) UIButton *changeScoreButton;
@property(strong, nonatomic) UIButton *timeButton;
@property(strong, nonatomic) UIButton *resetButton;
@property(assign, nonatomic) BOOL isTiming;
@property(assign, nonatomic) BOOL hasStartedOnce;

@end


@implementation ScoreboardViewController

- (instancetype)init {
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = RGBA(246, 246, 246, 1);
    [self setUpUI];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
    [self bindRenameEvents];
}



#pragma mark - setup

- (void)setUpUI {
    [self addAllSubviews];
    [self addAllConstraints];

}

- (void)addAllSubviews {
    [self.view addSubview:self.timeView];
    [self.view addSubview:self.teamView_left];
    [self.view addSubview:self.teamView_right];
    [self.view addSubview:self.changeScoreButton];
    [self.view addSubview:self.timeButton];
    [self.view addSubview:self.resetButton];
}

- (void)addAllConstraints {
    [_timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(ZOOMW(16));
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(ZOOMW(62));
        make.width.mas_equalTo(ZOOMW(286));
    }];

    [_teamView_left mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timeView.mas_bottom).offset(ZOOMW(8));
        make.left.equalTo(self.view).offset(ZOOMW(16));
        make.width.mas_equalTo(ZOOMW(163.5));
        make.height.mas_equalTo(ZOOMW(218));
    }];
    
    [_teamView_right mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.teamView_left);
        make.right.equalTo(self.view).offset(-ZOOMW(16));
        make.width.height.equalTo(self.teamView_left);
    }];
    
    [_timeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).inset(ZOOMW(16));
        make.bottom.equalTo(self.changeScoreButton.mas_top).offset(-ZOOMW(16));
        make.height.mas_equalTo(ZOOMW(50));
    }];
    
    [_changeScoreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(self.timeButton);
        make.bottom.equalTo(self.resetButton.mas_top).offset(-ZOOMW(16));
    }];
    
    [_resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.timeButton);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-ZOOMW(20));
        make.height.mas_equalTo(ZOOMW(50));
    }];
}


#pragma mark - UIEvent

- (void)timeButtonTapped:(UIButton *)sender {
    [sender showClickedAnimationWithLevel:2];
    if (!self.isTiming) {
        [self.timeView startTiming];
        self.hasStartedOnce = YES;
        [self applyRunningButtonStyle];
    } else {
        [self.timeView pauseTiming];
        [self applyStoppedButtonStyle];
    }
    self.isTiming = !self.isTiming;
}

- (void)changeScoreButtonTapped:(UIButton *)sender {
    [sender showClickedAnimationWithLevel:2];
    int temp = self.teamView_left.score;
    self.teamView_left.score = self.teamView_right.score;
    self.teamView_right.score = temp;
    
    self.teamView_left.scoreLabel.text = [NSString stringWithFormat:@"%02d", self.teamView_left.score];
    self.teamView_right.scoreLabel.text = [NSString stringWithFormat:@"%02d", self.teamView_right.score];
}

- (void)resetButtonTapped:(UIButton *)sender {
    [sender showClickedAnimationWithLevel:2];
    [self.timeView resetTiming];
    if (self.isTiming) {
        [self.timeView pauseTiming];
        self.isTiming = NO;
    }
    [self applyStoppedButtonStyle];

    self.teamView_left.score = 0;
    self.teamView_right.score = 0;
    self.teamView_left.scoreLabel.text = [NSString stringWithFormat:@"%02d", self.teamView_left.score];
    self.teamView_right.scoreLabel.text = [NSString stringWithFormat:@"%02d", self.teamView_right.score];
}

#pragma mark - private

- (void)setupNavigationBar {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Punteggio";
    titleLabel.textColor = RGB(51, 51, 51);
    titleLabel.font = KEEPASS_FONT_Medium(18);
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;

    UIButton *musicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [musicButton setImage:[UIImage imageNamed:@"A_CountDown_icon"] forState:UIControlStateNormal];
    musicButton.frame = CGRectMake(0, 0, ZOOMW(24), ZOOMW(24));
    [musicButton addTarget:self action:@selector(gotoFeedback) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:musicButton];
}

- (void)bindRenameEvents {
    self.teamView_left.name.text = @"Squadra 1";
    self.teamView_right.name.text = @"Squadra 2";
    self.teamView_right.accentColor = RGBA(255, 91, 25, 1);

    UITapGestureRecognizer *leftTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(renameLeftTeam)];
    UITapGestureRecognizer *rightTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(renameRightTeam)];
    [self.teamView_left.name addGestureRecognizer:leftTap];
    [self.teamView_right.name addGestureRecognizer:rightTap];
    [self applyStoppedButtonStyle];
}

- (void)renameLeftTeam {
    [self promptRenameForLabel:self.teamView_left.name fallback:@"Squadra 1"];
}

- (void)renameRightTeam {
    [self promptRenameForLabel:self.teamView_right.name fallback:@"Squadra 2"];
}

- (void)promptRenameForLabel:(UILabel *)label fallback:(NSString *)fallback {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = label.text;
        textField.placeholder = fallback;
    }];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"Annulla" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Confermare" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = alert.textFields.firstObject;
        NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        label.text = text.length > 0 ? text : fallback;
        [weakSelf.view endEditing:YES];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)applyRunningButtonStyle {
    self.timeButton.backgroundColor = WHITE_COLOR;
    [self.timeButton setTitle:@"Pause" forState:UIControlStateNormal];
    [self.timeButton setTitleColor:RGBA(255, 91, 25, 1) forState:UIControlStateNormal];
    self.timeButton.layer.borderWidth = ZOOMW(1);
    self.timeButton.layer.borderColor = RGBA(255, 91, 25, 1).CGColor;
    [self.changeScoreButton setTitle:@"Exchange" forState:UIControlStateNormal];
}

- (void)applyStoppedButtonStyle {
    self.timeButton.backgroundColor = RGBA(255, 91, 25, 1);
    [self.timeButton setTitle:self.hasStartedOnce ? @"Start" : @"Inizio" forState:UIControlStateNormal];
    [self.timeButton setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
    self.timeButton.layer.borderWidth = 0;
    [self.changeScoreButton setTitle:self.hasStartedOnce ? @"Exchange" : @"Scambio" forState:UIControlStateNormal];
}

- (void)gotoMusicTab {
    self.tabBarController.selectedIndex = 2;
}

- (void)gotoFeedback {
    FeedbackViewController *feedbackVC = [[FeedbackViewController alloc] init];
    feedbackVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:feedbackVC animated:YES];
}


#pragma mark - 懒加载

- (ScoreboardTimerView *)timeView {
    if (_timeView == nil) {
        _timeView = [[ScoreboardTimerView alloc] init];
    }
    return _timeView;
}

- (ScoreboardTeamView *)teamView_left {
    if (_teamView_left == nil) {
        _teamView_left = [[ScoreboardTeamView alloc] init];
    }
    return _teamView_left;
}

- (ScoreboardTeamView *)teamView_right {
    if (_teamView_right == nil) {
        _teamView_right = [[ScoreboardTeamView alloc] init];
    }
    return _teamView_right;
}

- (UIView *)scorePanelView {
    if (_scorePanelView == nil) {
        _scorePanelView = [[UIView alloc] init];
        _scorePanelView.backgroundColor = CLEAR_COLOR;
        _scorePanelView.layer.cornerRadius = ZOOM(2);
        _scorePanelView.layer.masksToBounds = YES;

        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"A_Score_panel_bg"]];
        bgImageView.contentMode = UIViewContentModeScaleToFill;
        bgImageView.clipsToBounds = YES;
        [_scorePanelView addSubview:bgImageView];
        [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_scorePanelView);
        }];
    }
    return _scorePanelView;
}

- (UIImageView *)imageVS {
    if (_imageVS == nil) {
        _imageVS = [[UIImageView alloc] init];
        _imageVS.backgroundColor = CLEAR_COLOR;
    }
    return _imageVS;
}

- (UIButton *)timeButton {
    if (_timeButton == nil) {
        _timeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _timeButton.backgroundColor = RGBA(255, 91, 25, 1);
        [_timeButton setTitle:@"Inizio" forState:UIControlStateNormal];
        [_timeButton setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
        _timeButton.titleLabel.font = KEEPASS_FONT_Medium(18);
        _timeButton.layer.cornerRadius = ZOOMW(28);
        _timeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, 0, -10, 0);
        [_timeButton addTarget:self action:@selector(timeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _timeButton;
}

- (UIButton *)changeScoreButton {
    if (_changeScoreButton == nil) {
        _changeScoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeScoreButton.backgroundColor = RGBA(211, 124, 43, 1);
        [_changeScoreButton setTitle:@"Scambio" forState:UIControlStateNormal];
        [_changeScoreButton setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
        _changeScoreButton.titleLabel.font = KEEPASS_FONT_Medium(18);
        _changeScoreButton.layer.cornerRadius = ZOOMW(28);
        _changeScoreButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, 0, -10, 0);
        [_changeScoreButton addTarget:self action:@selector(changeScoreButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeScoreButton;
}

- (UIButton *)resetButton {
    if (_resetButton == nil) {
        _resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _resetButton.backgroundColor = WHITE_COLOR;
        _resetButton.layer.borderColor = RGBA(242, 94, 94, 1).CGColor;
        _resetButton.layer.borderWidth = ZOOMW(1);
        [_resetButton setTitle:@"Eliminare" forState:UIControlStateNormal];
        [_resetButton setTitleColor:RGBA(242, 94, 94, 1) forState:UIControlStateNormal];
        _resetButton.titleLabel.font = KEEPASS_FONT_Medium(18);
        _resetButton.layer.cornerRadius = ZOOMW(28);
        _resetButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, 0, -10, 0);
        [_resetButton addTarget:self action:@selector(resetButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetButton;
}

@end
