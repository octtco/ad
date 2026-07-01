//
//  CountDownWhiteNoisePlayTimeView.m
//  WePage
//
//  Created by 蒙俊竹 on 2025/2/8.
//

#import "CountDownWhiteNoisePlayTimeView.h"
#import "PrefixHeader.h"

@interface CountDownWhiteNoisePlayTimeView ()

@property (nonatomic, strong) UIButton *botton5;
@property (nonatomic, strong) UIButton *botton15;
@property (nonatomic, strong) UIButton *botton30;
@property (nonatomic, strong) UIButton *botton60;

@end

@implementation CountDownWhiteNoisePlayTimeView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setUpUI];
        [self setUpEvents];
        
        //_botton5.selected = YES;
        [self buttomclick:self.botton5];
        
        self.backgroundColor = CLEAR_COLOR;
    }
    return self;
}

#pragma mark - ui事件
- (void)buttomclick:(UIButton *)button {
    
    UIFont *pingFangFontUnselected = [UIFont fontWithName:@"PingFangSC" size:button.titleLabel.font.pointSize];
    
    // 先确保所有按钮都处于未选中的状态
    _botton5.selected = NO;
    _botton5.backgroundColor = SHALLOW_COLOR;
    [_botton5.titleLabel setFont:pingFangFontUnselected];
    _botton5.layer.borderWidth = ZOOM(0);
    
    _botton15.selected = NO;
    _botton15.backgroundColor = SHALLOW_COLOR;
    [_botton15.titleLabel setFont:pingFangFontUnselected];
    _botton15.layer.borderWidth = ZOOM(0);
    
    _botton30.selected = NO;
    _botton30.backgroundColor = SHALLOW_COLOR;
    [_botton30.titleLabel setFont:pingFangFontUnselected];
    _botton30.layer.borderWidth = ZOOM(0);
    
    _botton60.selected = NO;
    _botton60.backgroundColor = SHALLOW_COLOR;
    [_botton60.titleLabel setFont:pingFangFontUnselected];
    _botton60.layer.borderWidth = ZOOM(0);
    
    
    // 设置当前点击的按钮为选中状态
    button.selected = YES;
    button.backgroundColor = DEEP_COLOR_1;
    button.layer.borderColor = BUTTON_COLOR.CGColor;
    button.layer.borderWidth = ZOOM(0);
    [button setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateSelected];
    // 更改字体为 PingFang SC-Medium
    UIFont *pingFangFont = [UIFont fontWithName:@"PingFangSC-Medium" size:button.titleLabel.font.pointSize];
    [button.titleLabel setFont:pingFangFont];
}

#pragma mark - setUpUI
- (void)setUpUI {
    self.backgroundColor = [UIColor clearColor];
    
    [self addAllSubviews];
    [self addAllConstraints];
    
}

- (void)addAllSubviews {
    [self addSubview:self.botton5];
    [self addSubview:self.botton15];
    [self addSubview:self.botton30];
    [self addSubview:self.botton60];
}

- (void)addAllConstraints {
    
    [_botton5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(ZOOM(10));
        make.left.equalTo(self);
        make.width.mas_equalTo(ZOOMW(166));
        make.height.mas_offset(ZOOM(62));
    }];
    [_botton15 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.botton5.mas_right).offset(ZOOM(11));
        make.top.equalTo(self.botton5);
        make.width.mas_equalTo(ZOOMW(166));
        make.height.mas_offset(ZOOM(62));
    }];
    [_botton30 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.width.mas_equalTo(ZOOMW(166));
        make.height.mas_offset(ZOOM(62));
        make.top.equalTo(self.botton15.mas_bottom).offset(ZOOM(11));
    }];
    [_botton60 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.botton30.mas_right).offset(ZOOMW(11));
        make.width.mas_equalTo(ZOOMW(166));
        make.height.mas_offset(ZOOM(62));
        make.top.equalTo(self.botton30);
    }];
}

#pragma mark - set up events
- (void)setUpEvents {
    
}

#pragma mark - 懒加载
- (UIButton *)botton5 {
    if (_botton5 == nil) {
        _botton5 = [self createBottomButtonWithTitle:@"5"];
        _botton5.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _botton5.layer.cornerRadius = ZOOM(20);
        _botton5.layer.borderColor = BUTTON_COLOR.CGColor;
        _botton5.layer.borderWidth = ZOOM(1);
        [_botton5 setTitleColor:BLACK_COLOR forState:UIControlStateNormal];
    }
    return _botton5;
}

- (UIButton *)botton15 {
    if (_botton15 == nil) {
        _botton15 = [self createBottomButtonWithTitle:@"15"];
        _botton15.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _botton15.layer.cornerRadius = ZOOM(20);
        _botton15.layer.borderColor = BUTTON_COLOR.CGColor;
        _botton15.layer.borderWidth = ZOOM(1);
        [_botton15 setTitleColor:BLACK_COLOR forState:UIControlStateNormal];
    }
    return _botton15;;
}
- (UIButton *)botton30 {
    if (_botton30 == nil) {
        _botton30 = [self createBottomButtonWithTitle:@"30"];
        _botton30.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _botton30.layer.cornerRadius = ZOOM(20);
        _botton30.layer.borderColor = BUTTON_COLOR.CGColor;
        _botton30.layer.borderWidth = ZOOM(1);
        [_botton30 setTitleColor:BLACK_COLOR forState:UIControlStateNormal];
    }
    return _botton30;
}
- (UIButton *)botton60 {
    if (_botton60 == nil) {
        _botton60 = [self createBottomButtonWithTitle:@"60"];
        _botton60.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _botton60.layer.cornerRadius = ZOOM(20);
        _botton60.layer.borderColor = BUTTON_COLOR.CGColor;
        _botton60.layer.borderWidth = ZOOM(1);
        [_botton60 setTitleColor:BLACK_COLOR forState:UIControlStateNormal];
//        _botton60.hidden = YES;
    }
    return _botton60;
}

#pragma mark -定义4个按钮的封装函数
// 这个方法只为快捷创建四个密码参数按钮
- (UIButton *)createBottomButtonWithTitle:(NSString *)title {
    
    //创建，背景颜色清除一下
    UIButton *button = [UIButton buttonWithTitle:title fontSize:16 bold:YES height:84 titleColor:BLACK_COLOR backGroundColor:SHALLOW_COLOR];
    //button.backgroundColor = [UIColor clearColor];//因为圆形只是图片，底下是透明的按钮
    
    
    
    // 直接在这里添加ui事件避免后续要写多次
    [button addTarget:self action:@selector(buttomclick:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

@end
