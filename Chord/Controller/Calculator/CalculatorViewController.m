//
//  CalculatorViewController.m
//  Calculator
//
//

#import "CalculatorViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Masonry/Masonry.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface CalculatorViewController () <AVAudioPlayerDelegate>

@property (nonatomic, strong) UILabel *processLabel;
@property (nonatomic, strong) UILabel *displayLabel;
@property (nonatomic, strong) UIView *buttonContainer;
@property (nonatomic, strong) NSMutableArray<UIButton *> *buttons;  // 存储所有按钮对象的数组
@property (nonatomic, strong) NSString *currentInput;
@property (nonatomic, assign) double currentValue;
@property (nonatomic, assign) double storedValue;
@property (nonatomic, copy) NSString *currentOperator;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation CalculatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"计算器";
    [self setUpHUD];
    [self setupUI];
    self.currentInput = @"0";
    [self setupAudioPlayer];
}

- (void)setUpHUD {
    [SVProgressHUD setBackgroundColor:RGBA(51, 51, 51, 0.5)];
    [SVProgressHUD setFont:[UIFont fontWithName:@"PingFang SC" size:16]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setMinimumSize:CGSizeMake(200, 120)];
    [SVProgressHUD setCornerRadius:15];
    [SVProgressHUD setMaximumDismissTimeInterval:0.8];
}

- (void)setupAudioPlayer {
    // 配置音频会话（允许后台播放/忽略静音模式）
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"rezero" ofType:@"mp3"];
    if (path.length == 0) {
        return;
    }
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if (error) {
        NSLog(@"音频播放器初始化失败: %@", error.localizedDescription);
    } else {
        [self.audioPlayer prepareToPlay];
        self.audioPlayer.delegate = self;
    }
}


#pragma mark - UI Setup

- (void)setupUI {
    self.view.backgroundColor = RGBA(229, 235, 233, 1);
    [self addAllSubviews];
    [self addAllConstraints];
}

- (void)addAllSubviews {
    [self.view addSubview:self.processLabel];
    [self.view addSubview:self.displayLabel];
    [self.view addSubview:self.buttonContainer];
    
    // 按钮标题数组
    NSArray *buttonTitles = @[
        @"AC", @"+ -", @"%", @"÷",
        @"7", @"8", @"9", @"×",
        @"4", @"5", @"6", @"−",
        @"1", @"2", @"3", @"+",
        @"00", @"0", @".", @"="
    ];

    self.buttons = [NSMutableArray array];
    
    for (NSString *title in buttonTitles) {
        if (title.length > 0) {
            UIButton *button = [self createButtonWithTitle:title];
            [self.buttonContainer addSubview:button];
            [self.buttons addObject:button];
        }
    }
}

- (void)addAllConstraints {
    NSInteger rows = 5;
    NSInteger cols = 4;
    CGFloat horizontalInset = ZOOMH(2);
    CGFloat buttonSpacing = ZOOMH(8);
    CGFloat buttonWidth = floor((kScreenWidth - horizontalInset * 2 - buttonSpacing * (cols - 1)) / cols);
    CGFloat containerHeight = buttonWidth * rows + buttonSpacing * (rows - 1);

    [self.buttonContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(horizontalInset);
        make.right.equalTo(self.view).offset(-horizontalInset);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(ZOOMH(-48));
        make.height.mas_equalTo(containerHeight);
    }];
    
    [self.displayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.buttonContainer.mas_top).offset(ZOOMH(-26));
        make.left.equalTo(self.view).offset(ZOOMH(20));
        make.right.equalTo(self.view).offset(ZOOMH(-16));
        make.height.mas_equalTo(ZOOMH(92));
    }];
    
    [self.processLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.displayLabel);
        make.bottom.equalTo(self.displayLabel.mas_top);
        make.height.mas_equalTo(0);
    }];
    
    for (NSInteger i = 0; i < rows; i++) {
        for (NSInteger j = 0; j < cols; j++) {
            NSInteger index = i * cols + j;
            UIButton *button = self.buttons[index];
            
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.height.mas_equalTo(buttonWidth);
                if (j == 0) {
                    make.left.equalTo(self.buttonContainer);
                } else {
                    UIButton *prevButton = self.buttons[index - 1];
                    make.left.equalTo(prevButton.mas_right).offset(buttonSpacing);
                }
                if (i == 0) {
                    make.top.equalTo(self.buttonContainer);
                } else {
                    UIButton *topButton = self.buttons[index - cols];
                    make.top.equalTo(topButton.mas_bottom).offset(buttonSpacing);
                }
            }];
        }
    }
}


#pragma mark - Button Creation

- (UIButton *)createButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [self buttonColorForTitle:title];
    button.layer.cornerRadius = ZOOMW(14);
    button.layer.masksToBounds = YES;
    CGFloat fontSize = [title isEqualToString:@"+ -"] ? 20 : 24;
    button.titleLabel.font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightMedium];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[self titleColorForTitle:title] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIColor *)buttonColorForTitle:(NSString *)title {
    if ([@[@"÷", @"×", @"−", @"+", @"="] containsObject:title]) {
        return RGBA(37, 175, 86, 1);
    } else if ([@[@"AC", @"+ -", @"%"] containsObject:title]) {
        return WHITE_COLOR;
    }
    return RGBA(114, 162, 131, 1);
}

- (UIColor *)titleColorForTitle:(NSString *)title {
    if ([@[@"AC", @"+ -", @"%"] containsObject:title]) {
        return RGBA(51, 51, 51, 1);
    }
    return WHITE_COLOR;
}


#pragma mark - Button Action

- (void)buttonTapped:(UIButton *)sender {
    NSString *buttonTitle = [self normalizedButtonTitle:sender.currentTitle];
    
    if ([buttonTitle isEqualToString:@"AC"]) {  // 清除所有状态
        if (self.audioPlayer) {
            [self.audioPlayer play];
        }
        
        self.processLabel.text = @"";
        self.currentInput = @"0";
        self.currentValue = 0;
        self.storedValue = 0;
        self.currentOperator = nil;
    }
    else if ([buttonTitle isEqualToString:@"±"]) {  // 正负号切换
        if (![self.currentInput isEqualToString:@"0"]) {
            if ([self.currentInput hasPrefix:@"-"]) {
                self.currentInput = [self.currentInput substringFromIndex:1];
            } else {
                self.currentInput = [@"-" stringByAppendingString:self.currentInput];
            }
        }
    }
    else if ([buttonTitle isEqualToString:@"%"]) {
        double value = [self.currentInput doubleValue] / 100.0;
        self.currentInput = [NSString stringWithFormat:@"%g", value];
    }
    else if ([@[@"÷", @"×", @"-", @"+"] containsObject:buttonTitle]) {
        // 更新过程显示
        self.processLabel.text = [NSString stringWithFormat:@"%@%@",
            self.currentInput,
            [self operatorSymbolForTitle:buttonTitle]];
        
        if (self.currentOperator) {
            [self performCalculation];
        }
        
        // 存储当前值并重置输入状态
        self.currentOperator = buttonTitle;
        self.storedValue = [self.currentInput doubleValue];
        self.currentInput = @"";
    }
    else if ([buttonTitle isEqualToString:@"="]) {
        if (self.currentOperator) {
            // 暂存操作数用于构建完整表达式
            NSString *firstOperand = [NSString stringWithFormat:@"%g", self.storedValue];
            NSString *secondOperand = [self.currentInput isEqualToString:@""] ? @"0" : self.currentInput;
            
            [self performCalculation];  // 计算结果会更新 currentInput
            
            // 正确构建完整表达式
            self.processLabel.text = [NSString stringWithFormat:@"%@%@%@ = %@",
                                     firstOperand,
                                     [self operatorSymbolForTitle:self.currentOperator],
                                     secondOperand,
                                     self.currentInput];
            self.currentOperator = nil;
        }
    }
    else if ([buttonTitle isEqualToString:@"."]) {
        if ([self.currentInput isEqualToString:@""]) {
            self.currentInput = @"0.";  // 兼容空字符状态
        } else if (![self.currentInput containsString:@"."]) {
            self.currentInput = [self.currentInput stringByAppendingString:@"."];
        }
    }
    else {  // 数字输入
        if ([self.currentInput isEqualToString:@"0"] || [self.currentInput isEqualToString:@""]) {
            self.currentInput = buttonTitle;  // 初始状态覆盖
        } else {
            self.currentInput = [self.currentInput stringByAppendingString:buttonTitle];
        }
    }
    
    self.displayLabel.text = self.currentInput; // 更新显示
}

- (void)performCalculation {
    double current = [self.currentInput doubleValue];
    double result = 0;
    
    if ([self.currentOperator isEqualToString:@"+"]) {
        result = self.storedValue + current;
    } else if ([self.currentOperator isEqualToString:@"-"]) {
        result = self.storedValue - current;
    } else if ([self.currentOperator isEqualToString:@"×"]) {
        result = self.storedValue * current;
    } else if ([self.currentOperator isEqualToString:@"÷"]) {
        result = current != 0 ? self.storedValue / current : 0;
    }
    
    self.currentInput = [NSString stringWithFormat:@"%g", result];
    self.storedValue = result;
}

// 转换运算符符号
- (NSString *)operatorSymbolForTitle:(NSString *)title {
    NSDictionary *symbolMap = @{
        @"÷": @"÷",
        @"×": @"×",
        @"-": @"−",
        @"+": @"+"
    };
    return symbolMap[title] ?: title;
}

- (NSString *)normalizedButtonTitle:(NSString *)title {
    if ([title isEqualToString:@"+ -"]) {
        return @"±";
    }
    if ([title isEqualToString:@"−"]) {
        return @"-";
    }
    return title;
}



#pragma mark - AVAudioPlayerDelegate

// 音频播放完成后的回调
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
//    NSLog(@"归零音频播放完成");
}


#pragma mark - Lazy Load

- (UILabel *)processLabel {
    if (!_processLabel) {
        _processLabel = [[UILabel alloc] init];
        _processLabel.text = @"";
        _processLabel.textColor = [UIColor clearColor];
        _processLabel.font = [UIFont systemFontOfSize:16];
        _processLabel.textAlignment = NSTextAlignmentRight;
        _processLabel.adjustsFontSizeToFitWidth = YES;
        _processLabel.minimumScaleFactor = 0.7;
    }
    return _processLabel;
}

- (UILabel *)displayLabel {
    if (!_displayLabel) {
        _displayLabel = [[UILabel alloc] init];
        _displayLabel.text = @"0";
        _displayLabel.textColor = RGBA(40, 40, 40, 1);
        _displayLabel.font = [UIFont monospacedDigitSystemFontOfSize:66 weight:UIFontWeightUltraLight];
        _displayLabel.textAlignment = NSTextAlignmentRight;
        _displayLabel.adjustsFontSizeToFitWidth = YES;
        _displayLabel.minimumScaleFactor = 0.5;
    }
    return _displayLabel;
}

- (UIView *)buttonContainer {
    if (!_buttonContainer) {
        _buttonContainer = [[UIView alloc] init];
        _buttonContainer.backgroundColor = [UIColor clearColor];
    }
    return _buttonContainer;
}

- (NSMutableArray<UIButton *> *)buttons {
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}


@end
