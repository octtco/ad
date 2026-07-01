//
//  CountDownWhiteNoisePlayView.m
//  WePage
//
//  Created by 蒙俊竹 on 2025/2/8.
//

#import "CountDownWhiteNoisePlayView.h"
#import "CountDownWhiteNoiseModeView.h"
#import "CountDownWhiteNoisePlayTimeView.h"
#import "PrefixHeader.h"

@interface CountDownWhiteNoisePlayView ()

@property(strong, nonatomic) UILabel *time;
@property(strong, nonatomic) UILabel *type;
@property(strong, nonatomic) CountDownWhiteNoiseModeView *modeview;
@property(strong, nonatomic) CountDownWhiteNoisePlayTimeView *timeview;
@property(strong, nonatomic) UILabel *custom;
@property(strong, nonatomic) UIView *customBack;
@property(strong, nonatomic) UILabel *customTime;

//创建一个AVPlayer播放类
@property (nonatomic, strong) AVPlayer *player;
//AVPlayerItem(多媒体资源)
@property (nonatomic, strong) AVPlayerItem *playerItem;

//播放暂停按钮
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UIButton *stopButton;

//定时
@property (nonatomic,assign) NSInteger targetSeconds;

@end

@implementation CountDownWhiteNoisePlayView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setUpUI];
        [self setUpEvents];
        
        // 创建手势识别器
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                              initWithTarget:self
                                              action:@selector(customTimeTapped:)
        ];
        [_customTime addGestureRecognizer:tapGesture];
    }
    return self;
}

#pragma mark - ui事件
- (void)play:(UIButton *)button {
    // copyButton显示点击效果
    [button showClickedAnimationWithLevel:2];
    [self endEditing:YES];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:_modeview.mode withExtension:nil];
    self.player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithURL:url]];
    
    // 请求权限以在后台播放音频，并允许与其它应用音频混合
    static dispatch_once_t onceToken;
     dispatch_once(&onceToken, ^{   // 只在app启动时设置（执行）一次
       AVAudioSession *audioSession = [AVAudioSession sharedInstance];  // 获取音频会话单例对象
       [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];   // 设置音频会话类别
             /*
                AVAudioSessionCategoryPlayback ：表示 app 将播放音频
                AVAudioSessionCategoryOptionMixWithOthers ：这个选项表示允许与其他音频应用混合播放
                error:nil ：表示忽略任何可能出现的错误（通常应该是捕获并处理可能出现的错误，这里我们选择忽略）
              */
       [audioSession setActive:YES error:nil];  // 激活音频会话（这里同样忽略错误）
     });
    
    _doneButton.hidden = YES;
    _stopButton.hidden = NO;
    
    [self.player play];
    //开始计时
    CMTime targetTime = CMTimeMake(_targetSeconds*3, 1); // 分钟
    __weak typeof(self) weakSelf = self;
    [self.player addBoundaryTimeObserverForTimes:@[[NSValue valueWithCMTime:targetTime]]
                                           queue:dispatch_get_main_queue()
                                      usingBlock:^{
//        [weakSelf stop:nil]; // 触发暂停
//        _doneButton.layer.hidden = NO;
//        _stopButton.layer.hidden = YES;
        [weakSelf stop:_stopButton];
    }];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(runLoopTheMovie:) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
}

- (void)stop:(UIButton *)button {
    // copyButton显示点击效果
    [button showClickedAnimationWithLevel:2];
    [self endEditing:YES];
    
    _doneButton.layer.hidden = NO;
    _stopButton.layer.hidden = YES;
    [self.player pause];
    //暂停定时器
    
}

//接收播放完成的通知
- (void)runLoopTheMovie:(NSNotification *)notification {
    NSURL *url = [[NSBundle mainBundle] URLForResource:_modeview.mode withExtension:nil];
    self.player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithURL:url]];
    [_player play];
}

- (void)customTimeTapped:(UITapGestureRecognizer *)sender {
    NSLog(@"tap");
    UIViewController *currentVC = [self findCurrentViewController];
    // 创建 UIAlertController
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"输入时间",nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"输入",nil);
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消",nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) { }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确认",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = alertController.textFields.firstObject;
        if (textField.text.length > 0) {
            // 保存用户输入的字符串
            NSString *newTime = textField.text;
            //NSLog(@"用户输入的新对话名称：%@", newTitle);
            // 更新自定义时间
            self.targetSeconds = [newTime intValue];
            self.customTime.text = [NSString stringWithFormat:@"%@",newTime];
        } else {
            // 如果用户没有输入任何内容，可以显示一个提示
            UIAlertController *warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"提示",nil) message:NSLocalizedString(@"没有输入",nil) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确认",nil) style:UIAlertActionStyleDefault handler:nil];
            [warningAlert addAction:okAction];
            [currentVC presentViewController:warningAlert animated:YES completion:nil];
        }
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    [currentVC presentViewController:alertController animated:YES completion:nil];
    
}

- (UIViewController *)findCurrentViewController {
    UIResponder *responder = self;
    while ((responder = [responder nextResponder])) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
    }
    return nil;
}

#pragma mark - setUpUI
- (void)setUpUI {
    self.backgroundColor = RGB(255, 255, 255);
    
    [self addAllSubviews];
    [self addAllConstraints];
    
    self.doneButton.hidden = NO;
    self.stopButton.hidden = YES;
}

- (void)addAllSubviews {
    [self addSubview:self.time];
    [self addSubview:self.type];
    [self addSubview:self.doneButton];
    [self addSubview:self.stopButton];
    [self addSubview:self.modeview];
    [self addSubview:self.custom];
    [self addSubview:self.customBack];
    [self addSubview:self.customTime];
    [self addSubview:self.timeview];
    
}

- (void)addAllConstraints {
    
    [_type mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(ZOOM(20));
        make.left.equalTo(self).offset(ZOOM(16));
    }];
    [_modeview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.type.mas_bottom).offset(ZOOM(10));
        make.height.mas_equalTo(ZOOM(74));
        make.left.equalTo(self).offset(ZOOM(16));
        make.right.equalTo(self).offset(ZOOM(-16));
    }];
    [_time mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.modeview.mas_bottom).offset(ZOOM(20));
        make.left.equalTo(self).offset(ZOOM(16));
    }];
    [_timeview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.time.mas_bottom).offset(ZOOM(10));
        make.height.mas_equalTo(ZOOM(150));
        make.left.equalTo(self).offset(ZOOM(16));
        make.right.equalTo(self).offset(ZOOM(-16));
    }];
    [_custom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timeview.mas_bottom).offset(ZOOM(20));
        make.left.equalTo(self).offset(ZOOM(16));
    }];
    [_customBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.custom.mas_bottom).offset(ZOOM(10));
        make.centerX.equalTo(self);
        make.height.mas_equalTo(ZOOM(84));
        make.width.mas_equalTo(ZOOM(343));
    }];
    [_customTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.customBack);
        make.centerX.equalTo(self.customBack);
//        make.height.mas_equalTo(ZOOM(84));
        make.width.mas_equalTo(ZOOM(343));
    }];
    [_stopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.customBack.mas_bottom).offset(ZOOM(120));
        make.width.mas_equalTo(_doneButton.width);
        make.height.mas_equalTo(ZOOM(54));
    }];
    [_doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.customBack.mas_bottom).offset(ZOOM(103));
        make.width.mas_equalTo(_doneButton.width);
        make.height.mas_equalTo(ZOOM(54));
    }];
}

#pragma mark - set up events
- (void)setUpEvents {
    [_doneButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    [_stopButton addTarget:self action:@selector(stop:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 初始化私有成员
- (UILabel *)time {
    if (_time == nil) {
        _time = [UILabel labelWithText:NSLocalizedString(@"定时",nil) fontSize:16 bold:YES textColor:RGB(51, 51, 51)];
    }
    return _time;
}

- (CountDownWhiteNoiseModeView *)modeview {
    if (_modeview == nil) {
        _modeview = [[CountDownWhiteNoiseModeView alloc] init];
        _modeview.layer.cornerRadius = ZOOM(12);
    }
    return _modeview;
}

- (CountDownWhiteNoisePlayTimeView *)timeview {
    if (_timeview == nil) {
        _timeview = [[CountDownWhiteNoisePlayTimeView alloc] init];
        _timeview.layer.cornerRadius = ZOOM(12);
    }
    return _timeview;
}

- (UILabel *)type {
    if (_type == nil) {
        _type = [UILabel labelWithText:NSLocalizedString(@"模式", nil) fontSize:16 bold:YES textColor:RGB(51, 51, 51)];
    }
    return _type;
}

- (UIButton *)doneButton {
    if (_doneButton == nil) {
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_doneButton setTitle:NSLocalizedString(@"开始",nil) forState:UIControlStateNormal];
        [_doneButton setBackgroundColor:DEEP_COLOR_1];
        _doneButton.layer.cornerRadius = ZOOM(12);
        
        [_doneButton setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
        [_doneButton setFont:[UIFont fontWithName:@"PingFang SC" size: 16]];
        UIFont *pingFangFont = [UIFont fontWithName:@"PingFangSC-Medium" size:_doneButton.titleLabel.font.pointSize];
        [_doneButton.titleLabel setFont:pingFangFont];
        
//        [_doneButton setImage:[UIImage imageNamed:@"done_start"] forState:UIControlStateNormal];
        
        _doneButton.width = ZOOMW(343);
        // 增大按钮触摸面积
        _doneButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, 0, -10, 0);
    }
    return _doneButton;
}
- (UIButton *)stopButton {
    if (_stopButton == nil) {
        _stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
        [_stopButton setTitle:NSLocalizedString(@"暂停",nil) forState:UIControlStateNormal];
        [_stopButton setTitleColor:BLACK_COLOR forState:UIControlStateNormal];
        [_stopButton setBackgroundColor:WHITE_COLOR];
        [_stopButton setFont:[UIFont fontWithName:@"PingFang SC" size: 16]];
        UIFont *pingFangFont = [UIFont fontWithName:@"PingFangSC-Medium" size:_stopButton.titleLabel.font.pointSize];
        [_stopButton.titleLabel setFont:pingFangFont];
//        _stopButton.layer.borderColor = DEEP_COLOR.CGColor;
//        _stopButton.layer.borderWidth = ZOOM(1);
        
        _stopButton.layer.cornerRadius = ZOOM(12);
        
        _stopButton.width = ZOOMW(343);
        // 增大按钮触摸面积
        _stopButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, 0, -10, 0);
    }
    return _stopButton;
}
- (UILabel *)custom {
    if (_custom == nil) {
        _custom = [UILabel labelWithText:NSLocalizedString(@"自定义时间（分钟）",nil) fontSize:16 bold:YES textColor:RGB(51, 51, 51)];
    }
    return _custom;
}
-(UIView *)customBack{
    if(_customBack == nil){
        _customBack = [[UIView alloc] init];
        _customBack.backgroundColor = SHALLOW_COLOR;
        _customBack.layer.cornerRadius = ZOOM(12);
    }
    return _customBack;
}

-(UILabel *)customTime{
    if(_customTime == nil){
        _customTime = [[UILabel alloc] init];
        _customTime.text = NSLocalizedString(@"请输入",nil);
        _customTime.textAlignment = NSTextAlignmentCenter;
        _customTime.userInteractionEnabled = YES;
    }
    return _customTime;
}
@end
