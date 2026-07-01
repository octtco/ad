//
//  SettingViewController.m
//  Chord
//
//  Created by 蒙俊竹 on 2026/3/16.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@property(nonatomic, strong) UIControl *cacheCard;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGBA(246, 246, 246, 1);
    [self setupNavigationBar];
    [self setupUI];
}

#pragma mark - setupUI

- (void)setupNavigationBar {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Impostare";
    titleLabel.textColor = RGB(51, 51, 51);
    titleLabel.font = KEEPASS_FONT_Medium(18);
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;

    UIImage *backImg = [UIImage imageNamed:@"A_back"];
    if (backImg) {
        UIImage *returnImage = [backImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:returnImage style:UIBarButtonItemStylePlain target:self action:@selector(returnButtonClicked)];
    }
}

- (void)setupUI {
    [self.view addSubview:self.cacheCard];
    [self.cacheCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(ZOOMW(24));
        make.left.right.equalTo(self.view).inset(ZOOMW(16));
        make.height.mas_equalTo(ZOOMW(92));
    }];
}

#pragma mark - events

- (void)returnButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clearCache {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [SVProgressHUD showSuccessWithStatus:@"Successo"];
}

#pragma mark - lazy

- (UIControl *)cacheCard {
    if (!_cacheCard) {
        _cacheCard = [[UIControl alloc] init];
        _cacheCard.backgroundColor = WHITE_COLOR;
        _cacheCard.layer.cornerRadius = ZOOMW(18);
        _cacheCard.clipsToBounds = YES;
        [_cacheCard addTarget:self action:@selector(clearCache) forControlEvents:UIControlEventTouchUpInside];

        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"Cancella la cache";
        titleLabel.textColor = RGB(51, 51, 51);
        titleLabel.font = [UIFont fontWithName:@"PingFang SC-Regular" size:ZOOM(18)];
        [_cacheCard addSubview:titleLabel];

        UIImageView *arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"A_go"]];
        arrowView.contentMode = UIViewContentModeScaleAspectFit;
        [_cacheCard addSubview:arrowView];

        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self->_cacheCard).offset(ZOOMW(24));
            make.centerY.equalTo(self->_cacheCard);
        }];
        [arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self->_cacheCard).offset(-ZOOMW(24));
            make.centerY.equalTo(self->_cacheCard);
            make.width.height.mas_equalTo(ZOOMW(20));
        }];
    }
    return _cacheCard;
}

@end
