//
//  MyCell.m
//  Chord
//
//  Created by 蒙俊竹 on 2026/3/16.
//

#import "MyCell.h"

@implementation MyCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // 卡片背景
    self.containerView = [[UIView alloc] init];
    self.containerView.backgroundColor = RGBA(245, 245, 245, 1);
    self.containerView.layer.cornerRadius = ZOOMW(16);
    [self addSubview:self.containerView];
    
    self.goView = [[UIImageView alloc] init];
    [self.goView setImage:[UIImage imageNamed:@"A_go"]];
    [self.containerView addSubview:self.goView];
    
    // 标题标签
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.titleLabel.textColor = [UIColor blackColor];
    [self.containerView addSubview:self.titleLabel];
    
    self.versionLabel = [[UILabel alloc] init];
    self.versionLabel.text = @"1.0";
    self.versionLabel.font = [UIFont boldSystemFontOfSize:16];
    self.versionLabel.textColor = RGBA(153, 153, 153, 1);
    [self.containerView addSubview:self.versionLabel];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.goView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.containerView);
        make.right.equalTo(self.containerView).offset(ZOOMW(-16));
        make.height.mas_equalTo(ZOOMW(16));
        make.width.mas_equalTo(ZOOMW(16));
    }];
    
    [self.versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.containerView);
        make.right.equalTo(self.containerView).offset(ZOOMW(-16));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.containerView);
        make.left.equalTo(self.containerView).offset(ZOOMW(16));
    }];
}


@end
