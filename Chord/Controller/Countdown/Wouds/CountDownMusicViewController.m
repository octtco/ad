//
//  CountDownMusicViewController.m
//  WePage
//
//  Created by 蒙俊竹 on 2025/2/8.
//

#import "CountDownMusicViewController.h"
#import "CountDownMusicPlayView.h"
#import "FeedbackViewController.h"
#import "PrefixHeader.h"

@interface CountDownMusicViewController ()

@property (nonatomic, strong) CountDownMusicPlayView *playView;

@end

@implementation CountDownMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGBA(246, 246, 246, 1);
    [self setupNavigationBar];
    [self setupUI];
}

#pragma mark - Setup

- (void)setupNavigationBar {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Musica";
    titleLabel.textColor = RGB(51, 51, 51);
    titleLabel.font = KEEPASS_FONT_Medium(18);
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;

    UIButton *headsetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [headsetButton setImage:[UIImage imageNamed:@"A_CountDown_icon"] forState:UIControlStateNormal];
    headsetButton.frame = CGRectMake(0, 0, ZOOMW(24), ZOOMW(24));
    [headsetButton addTarget:self action:@selector(gotoFeedback) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:headsetButton];
}

- (void)setupUI {
    [self.view addSubview:self.playView];
    [self.playView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(ZOOMW(22));
        make.left.right.bottom.equalTo(self.view);
    }];
}

#pragma mark - Lazy

- (CountDownMusicPlayView *)playView {
    if (_playView == nil) {
        _playView = [[CountDownMusicPlayView alloc] init];
        _playView.backgroundColor = CLEAR_COLOR;
    }
    return _playView;
}

- (void)gotoFeedback {
    FeedbackViewController *feedbackVC = [[FeedbackViewController alloc] init];
    feedbackVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:feedbackVC animated:YES];
}

@end
