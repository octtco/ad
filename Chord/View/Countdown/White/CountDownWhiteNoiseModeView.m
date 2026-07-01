//
//  CountDownWhiteNoiseModeView.m
//  WePage
//
//  Created by 蒙俊竹 on 2025/2/8.
//

#import "CountDownWhiteNoiseModeView.h"
#import "PrefixHeader.h"

@interface CountDownWhiteNoiseModeView ()

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIButton *whitebotton;
@property (nonatomic, strong) UIButton *brownbotton;
@property (nonatomic, strong) UIButton *pickbotton;

@end

@implementation CountDownWhiteNoiseModeView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setUpUI];
        [self setUpEvents];
        
        //_whitebotton.selected = YES;
        [self modeShouldUpdate:self.whitebotton];
    }
    return self;
}

#pragma mark - ui事件
- (void)modeShouldUpdate:(UIButton *)button {
    // 确保所有按钮都处于未选中状态，并且设置它们的背景色为clearColor
    _whitebotton.selected = NO;
    _whitebotton.backgroundColor = SHALLOW_COLOR;
    _whitebotton.titleLabel.textColor = BLACK_COLOR; // 设置默认的未选中字体颜色
    _whitebotton.layer.borderWidth = ZOOM(0);

    _brownbotton.selected = NO;
    _brownbotton.backgroundColor = SHALLOW_COLOR;
    _brownbotton.titleLabel.textColor = BLACK_COLOR;
    _brownbotton.layer.borderWidth = ZOOM(0);

    _pickbotton.selected = NO;
    _pickbotton.backgroundColor = SHALLOW_COLOR;
    _pickbotton.titleLabel.textColor = BLACK_COLOR;
    _pickbotton.layer.borderWidth = ZOOM(0);

    // 设置当前点击的按钮为选中状态
    button.selected = YES;
    button.backgroundColor = DEEP_COLOR_1;
    button.layer.borderColor = BUTTON_COLOR.CGColor;
    button.layer.borderWidth = ZOOM(0);
    [button setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateSelected];
    // 更改字体为 PingFang SC-Medium
    UIFont *pingFangFont = [UIFont fontWithName:@"PingFangSC-Medium" size:button.titleLabel.font.pointSize];
    [button.titleLabel setFont:pingFangFont];
    
 
    // 根据哪个按钮被选中来设置模式
    if (_whitebotton.isSelected == YES) {
        _mode = @"A_white.mp3";
    } else if (_brownbotton.isSelected == YES) {
        _mode = @"A_brown.mp3";
    } else if (_pickbotton.isSelected == YES) {
        _mode = @"A_pink.mp3";
    }
}

#pragma mark - setUpUI
- (void)setUpUI {
    self.backgroundColor = CLEAR_COLOR;
    
    [self addAllSubviews];
    [self addAllConstraints];
    
}

- (void)addAllSubviews {
    [self addSubview:self.backView];
    [self addSubview:self.whitebotton];
    [self addSubview:self.brownbotton];
    [self addSubview:self.pickbotton];
}

- (void)addAllConstraints {
    [_whitebotton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(ZOOM(10));
            make.left.equalTo(self);
            make.width.mas_equalTo(ZOOMW(105));
            make.bottom.equalTo(self).offset(ZOOM(-10));
    }];
    [_brownbotton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.whitebotton.mas_right).offset(ZOOM(14));
        make.width.mas_equalTo(ZOOMW(105));
        make.top.equalTo(self).offset(ZOOM(10));
        make.bottom.equalTo(self).offset(ZOOM(-10));
        
    }];
    [_pickbotton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.brownbotton.mas_right).offset(ZOOM(14));
            make.width.mas_equalTo(ZOOMW(105));
        make.top.equalTo(self).offset(ZOOM(10));
        make.bottom.equalTo(self).offset(ZOOM(-10));
    }];
}

#pragma mark - set up events
- (void)setUpEvents {
    
}

- (UIView *)backView{
    if(_backView == nil){
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = CLEAR_COLOR;
        _backView.layer.cornerRadius = ZOOM(12);
    }
    return _backView;
}

- (UIButton *)whitebotton {
    if (_whitebotton == nil) {
        _whitebotton = [self createBottomButtonWithTitle:NSLocalizedString(@"白噪音",nil)];
        _whitebotton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _whitebotton.layer.cornerRadius = ZOOM(20);
        _whitebotton.layer.borderColor = BUTTON_COLOR.CGColor;
    }
    return _whitebotton;
}

- (UIButton *)brownbotton {
    if (_brownbotton == nil) {
        _brownbotton = [self createBottomButtonWithTitle:NSLocalizedString(@"棕噪音",nil)];
        _brownbotton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _brownbotton.layer.cornerRadius = ZOOM(20);
        _brownbotton.layer.borderColor = BUTTON_COLOR.CGColor;
    }
    return _brownbotton;;
}
- (UIButton *)pickbotton {
    if (_pickbotton == nil) {
        _pickbotton = [self createBottomButtonWithTitle:NSLocalizedString(@"粉噪音",nil)];
        _pickbotton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _pickbotton.layer.cornerRadius = ZOOM(20);
        _pickbotton.layer.borderColor = BUTTON_COLOR.CGColor;
    }
    return _pickbotton;
}

#pragma mark -定义4个按钮的封装函数
// 这个方法只为快捷创建四个密码参数按钮
- (UIButton *)createBottomButtonWithTitle:(NSString *)title {
    
    //创建，背景颜色清除一下
    UIButton *button = [UIButton buttonWithTitle:title fontSize:16 bold:YES height:48 titleColor:BLACK_COLOR backGroundColor:SHALLOW_COLOR];
    /*
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];//因为圆形只是图片，底下是透明的按钮
    [button setTitle:title forState:UIControlStateNormal ];
    [button setFont:[UIFont fontWithName:@"PingFang SC" size: 16]];
    [button setTitleColor:RGB(51, 51, 51) forState:UIControlStateNormal];
    [button setTitleColor:RGB(119, 119, 119) forState:UIControlStateSelected];
    button.Selected = YES;
     */
    // 直接在这里添加ui事件避免后续要写多次
    [button addTarget:self action:@selector(modeShouldUpdate:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}
@end
