//
//  timeView.m
//  CountDown
//
//  Created by 刘一夫 on 2025/5/13.
//

#import "CountDownTimeView.h"

@interface CountDownTimeView()

@end

@implementation CountDownTimeView

- (instancetype)initWithIsarrival:(BOOL)isarrival{
    self = [super init];
    if (self) {
        self.isarrival = isarrival;
        [self setUpUI];
        self.backgroundColor = RGBA(255, 91, 25, 1);
        self.userInteractionEnabled = NO;
    }
    return self;
}

#pragma mark - setUpUI

- (void) setUpUI{
    
    [self addAllSubviews];
    [self addAllConstraints];
    
}

- (void)addAllSubviews{
    [self addSubview:self.days];
}

- (void)addAllConstraints{
    [_days mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self);
    }];
}

#pragma make - 懒加载

- (UILabel *)days{
    if(_days == nil){
        _days = [[UILabel alloc] init];
        if (_isarrival) {
            _days.text = [NSString stringWithFormat:@"已过去%ld天", self.daysCount];
        } else {
            _days.text = [NSString stringWithFormat:@"还有%ld天", self.daysCount];
        }
        _days.textColor = WHITE_COLOR;
        _days.font = KEEPASS_FONT_Medium(16);
    }
    return _days;
}

@end
