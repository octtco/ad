//
//  CountDownWhiteNoiseViewController.m
//  WePage
//
//  Created by 蒙俊竹 on 2025/2/8.
//

#import "CountDownWhiteNoiseViewController.h"
#import "CountDownWhiteNoisePlayView.h"
#import "PrefixHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface ShowHeaderView : UIView

@property (strong, nonatomic) UIButton *returnButton;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *editButton;

- (void)showAppearAnimation;

@end

NS_ASSUME_NONNULL_END

@interface CountDownWhiteNoiseViewController ()

@property(strong, nonatomic) CountDownWhiteNoisePlayView *playView;

@property (nonatomic, strong) ShowHeaderView *headerView;

@end

@implementation CountDownWhiteNoiseViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        // 设置modal出来的模式是占满全屏幕
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    [self setUpUI];
    
    // 创建一个 UIView，并设置其为渐变背景色
    UIView *gradientView = [[UIView alloc] initWithFrame:self.view.bounds];
    gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = gradientView.bounds;
    gradientLayer.colors = @[
        (__bridge id)SB_BG_COLOR.CGColor,
        (__bridge id)SB_BG_COLOR.CGColor
    ];
    gradientLayer.startPoint = CGPointMake(0.5, 0);
    gradientLayer.endPoint = CGPointMake(0.5, 1);

    // 将 gradientLayer 添加到 gradientView 的 layer 中
    [gradientView.layer insertSublayer:gradientLayer atIndex:0];
    
    // 将这个带有渐变色的 UIView 添加到 view 的最底层
    [self.view insertSubview:gradientView atIndex:0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_headerView showAppearAnimation];
}


#pragma mark - setUpUI
- (void)setUpUI {
    self.view.backgroundColor = SB_BG_COLOR;
    
    [self.view addSubview:self.playView];//这里不能是_tableview，要是self才会去懒加载
    [self.view addSubview:self.headerView];
    
    [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(ZOOM(-724));
    }];
    
    [_playView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom).offset(ZOOM(10));
        make.bottom.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
}

#pragma mark - 懒加载

- (CountDownWhiteNoisePlayView *)playView {
    if (_playView == nil) {
        _playView = [[CountDownWhiteNoisePlayView alloc] init];
        _playView.backgroundColor = SB_BG_COLOR;
    }
    return _playView;
}

- (ShowHeaderView *)headerView {
    if (_headerView == nil) {
        _headerView = [[ShowHeaderView alloc] init];
        _headerView.titleLabel.text = NSLocalizedString(@"白噪音", nil);
        _headerView.editButton.hidden = YES;
        
    }
    return _headerView;
}

@end

@implementation ShowHeaderView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setUpUI];
        [self setUpEvents];
    }
    return self;
}

- (void)setUpEvents {
    [self.returnButton addTarget:self action:@selector(returnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteButton addTarget:self action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.editButton addTarget:self action:@selector(editClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)returnClicked:(UIButton *)sender {
    [sender showClickedAnimationWithLevel:2];
    [[self currentViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)deleteClicked:(UIButton *)sender {
    [sender showClickedAnimationWithLevel:2];
    [[self currentViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)editClicked:(UIButton *)sender {
    [sender showClickedAnimationWithLevel:2];
}

- (UIViewController *)currentViewController {
    UIResponder *responder = self;
    while ((responder = responder.nextResponder)) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
    }
    return nil;
}

- (void)showAppearAnimation {
    [self.titleLabel showClickedAnimationWithLevel:20];
    [UIView animateWithDuration:0.4 animations:^{
        self.titleLabel.alpha = 1.0;
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            self.returnButton.alpha = 1.0;
            self.deleteButton.alpha = 1.0;
            self.editButton.alpha = 1.0;
        }];
    });
}

- (void)setUpUI {
    self.backgroundColor = CLEAR_COLOR;
    [self addSubview:self.returnButton];
    [self addSubview:self.deleteButton];
    [self addSubview:self.titleLabel];
    [self addSubview:self.editButton];

    [self.returnButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(ZOOM(-10));
        make.left.equalTo(self).offset(ZOOM(20));
    }];

    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(ZOOM(-10));
        make.right.equalTo(self.editButton.mas_left).offset(ZOOM(-16));
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.returnButton);
        make.centerX.equalTo(self);
    }];

    [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(ZOOM(-10));
        make.right.equalTo(self).offset(ZOOM(-20));
    }];

    self.titleLabel.alpha = 0;
    self.returnButton.alpha = 0;
    self.deleteButton.alpha = 0;
    self.editButton.alpha = 0;
}

- (UIButton *)returnButton {
    if (_returnButton == nil) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"A_return"] forState:UIControlStateNormal];
        button.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
        _returnButton = button;
    }
    return _returnButton;
}

- (UIButton *)deleteButton {
    if (_deleteButton == nil) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
        button.hidden = YES;
        _deleteButton = button;
    }
    return _deleteButton;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [UILabel labelWithText:@"" fontSize:20 bold:YES textColor:RGB(51, 51, 51)];
    }
    return _titleLabel;
}

- (UIButton *)editButton {
    if (_editButton == nil) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
        _editButton = button;
    }
    return _editButton;
}

@end
