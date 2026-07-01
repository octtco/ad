//
//  CountDownMusicModePickerViewController.m
//  WeStream
//
//  Created by 刘一夫 on 2025/6/24.
//

#import "CountDownMusicModePickerViewController.h"
#import "CountDownMusicModeView.h"

@interface CountDownMusicModePickerViewController ()

@property (nonatomic, strong) CountDownMusicModeView *modeView;

@end

@implementation CountDownMusicModePickerViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        // 设置modal出来的模式是占满全屏幕
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.view.backgroundColor = RGBA(51, 51, 51, 0.5);
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setUpUI];
    [self setUpEvents];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
//            initWithTarget:self action:@selector(dismiss)];
//        [self.view addGestureRecognizer:tap];
    
    [self.modeView.violinButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.modeView.pianoButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.modeView.guitarButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)dismiss {
    
    if (self.returnBlock) {
           self.returnBlock(_modeView.mode);
       }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ui

- (void)setUpUI {
    [self.view addSubview:self.modeView];
}

- (void)setUpEvents {
    [_modeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.view);
        make.width.mas_equalTo(ZOOM(320));
        make.height.mas_equalTo(ZOOM(262));
    }];
}

#pragma mark - 懒加载

- (CountDownMusicModeView *)modeView {
    if(_modeView == nil) {
        _modeView = [[CountDownMusicModeView alloc]init];
        _modeView.layer.cornerRadius = ZOOM(16);
    }
    return _modeView;
}

@end
