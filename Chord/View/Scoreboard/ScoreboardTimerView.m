//
//  ScoreboardTimerView.m
//  JiFen
//
//  Created by 蒙俊竹 on 2024/10/10.
//

#import "ScoreboardTimerView.h"
#import "PrefixHeader.h"

@interface ScoreboardTimerView ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *mmTimeLabel;

@property (nonatomic, strong) NSTimer *timer;   // 记时器
@property (nonatomic, assign) int seconds;
@property (nonatomic, assign) int minutes;
@property (nonatomic, assign) int milliseconds;

@end


@implementation ScoreboardTimerView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.seconds = 0;
        self.minutes = 0;
        self.milliseconds = 0;
        [self setUpUI];
    }
    return self;
}


#pragma mark - setUpUI

- (void)setUpUI {
    self.backgroundColor = [UIColor clearColor];
    
    [self addAllSubviews];
    [self addAllConstraints];
    
}

- (void)addAllSubviews {
    [self addSubview:self.imageView];
    [self addSubview:self.timeLabel];
    [self addSubview:self.mmTimeLabel];
}

- (void)addAllConstraints {
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.timeLabel.mas_left).offset(ZOOM(-12));
        make.centerY.equalTo(self.timeLabel);
        make.width.mas_equalTo(ZOOM(30));
        make.height.mas_equalTo(ZOOM(30));
    }];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.centerX.equalTo(self).offset(-ZOOM(18));
    }];
    
    [_mmTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.timeLabel.mas_right).offset(ZOOM(6));
        make.bottom.equalTo(self.timeLabel).offset(ZOOM(-8));
        make.right.lessThanOrEqualTo(self);
    }];
}

#pragma mark - 计时相关的方法

- (void)startTiming {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    }
}

- (void)pauseTiming {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)resetTiming {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    self.seconds = 0;
    self.minutes = 0;
    self.milliseconds = 0;
    self.timeLabel.text = @"00:00";
    self.mmTimeLabel.text = @"000";
}

- (void)updateTime {
    
    self.milliseconds += 10;
    if (self.milliseconds >= 1000) {
        self.seconds++;
        self.milliseconds = 0;
    }
    if (self.seconds >= 60) {
        self.minutes++;
        self.seconds = 0;
    }
    
    NSString *secondString = [NSString stringWithFormat:@"%02d", self.seconds];
    NSString *minuteString = [NSString stringWithFormat:@"%02d", self.minutes];
    NSString *millisecondString = [NSString stringWithFormat:@"%03d", self.milliseconds];
    
    self.timeLabel.text = [minuteString stringByAppendingString:[@":" stringByAppendingString:secondString]];
    self.mmTimeLabel.text = millisecondString;
}



#pragma mark - 懒加载

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"A_Score_time_icon"]];
        _imageView.backgroundColor = [UIColor clearColor];
    }
    return _imageView;
}

- (UILabel *)timeLabel {
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.text = @"00:00";
        _timeLabel.font = [UIFont systemFontOfSize:44 weight:UIFontWeightMedium];
        _timeLabel.textColor = RGB(102, 102, 102);
        _timeLabel.lineBreakMode = NSLineBreakByClipping;
        _timeLabel.adjustsFontSizeToFitWidth = YES;
        _timeLabel.minimumScaleFactor = 0.88;
        [_timeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_timeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _timeLabel;
}

- (UILabel *)mmTimeLabel {
    if (_mmTimeLabel == nil) {
        _mmTimeLabel = [[UILabel alloc] init];
        _mmTimeLabel.text = @"000";
        _mmTimeLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
        _mmTimeLabel.textColor = RGB(153, 153, 153);
        _mmTimeLabel.lineBreakMode = NSLineBreakByClipping;
        [_mmTimeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_mmTimeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _mmTimeLabel;
}


@end
