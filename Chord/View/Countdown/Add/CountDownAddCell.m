//
//  CountDownAdd.m
//  CountDown
//
//  Created by 刘一夫 on 2025/7/21.
//

#import "CountDownAddCell.h"
#import "PrefixHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface CountDownAddCell ()

@end

@implementation CountDownAddCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
        self.backgroundColor = WHITE_COLOR;
        self.layer.cornerRadius = ZOOMW(24);
        self.layer.masksToBounds = YES;
    }
    return self;
}

#pragma mark - setupui

- (void)setUpUI {
    
    [self addAllSubviews];
    [self addAllConstraints];
    
}

- (void)addAllSubviews {
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.accessary];
    [self.contentView addSubview:self.Switch];
    [self.contentView addSubview:self.contentImage];
    [self.contentView addSubview:self.Separator];
}

- (void)addAllConstraints {
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(ZOOMW(16));
        make.centerY.equalTo(self.contentView);
    }];
    [self.accessary mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-ZOOMW(20));
        make.centerY.equalTo(self.contentView);
        make.width.height.mas_equalTo(ZOOMW(16));
    }];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.accessary.mas_left).offset(-ZOOMW(12));
        make.centerY.equalTo(self.contentView);
        make.left.greaterThanOrEqualTo(self.nameLabel.mas_right).offset(ZOOMW(12));
    }];
    [self.Switch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-ZOOMW(16));
        make.centerY.equalTo(self.contentView);
    }];
    [self.contentImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.accessary.mas_left).offset(-ZOOMW(16));
        make.centerY.equalTo(self.contentView);
        make.width.height.mas_equalTo(ZOOMW(22));
    }];
    [self.Separator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.mas_equalTo(ZOOM(1));
    }];
    
}

#pragma mark - lazy

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = RGB(51, 51, 51);
        _nameLabel.font = KEEPASS_FONT_Regular(16);
    }
    return _nameLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.textColor = RGB(51, 51, 51);
        _contentLabel.font = KEEPASS_FONT_Regular(16);
        _contentLabel.textAlignment = NSTextAlignmentRight;
    }
    return _contentLabel;
}

- (UIButton *)accessary {
    if (!_accessary) {
        _accessary = [[UIButton alloc] init];
        _accessary.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
        [_accessary setBackgroundImage:[UIImage imageNamed:@"A_go"] forState:UIControlStateNormal];
    }
    return _accessary;
}

- (UIImageView *)contentImage {
    if (!_contentImage) {
        _contentImage = [[UIImageView alloc] init];
        _contentImage.hidden = YES;
        _contentImage.image = [UIImage imageNamed:@"A_B1"];
    }
    return _contentImage;
}

- (UISwitch *)Switch {
    if (!_Switch) {
        _Switch = [[UISwitch alloc] init];
        _Switch.hidden = YES;
        _Switch.onTintColor = RGBA(255, 91, 25, 1);
        _Switch.tintColor = RGBA(197, 197, 197, 1);
        _Switch.backgroundColor = RGBA(197, 197, 197, 1);
        _Switch.thumbTintColor = WHITE_COLOR;
        _Switch.layer.cornerRadius = ZOOMW(15.5);
    }
    return _Switch;
}

- (UIView *)Separator {
    if (!_Separator) {
        _Separator = [[UIView alloc] init];
        _Separator.backgroundColor = RGBA(230, 230, 230, 1);
        _Separator.hidden = YES;
    }
    return _Separator;
}

@end

NS_ASSUME_NONNULL_END
