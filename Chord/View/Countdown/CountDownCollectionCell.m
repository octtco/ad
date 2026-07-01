//
//  CountDownCollectionCell.m
//  CountDown
//
//  Created by 刘一夫 on 2025/5/13.
//

#import "CountDownCollectionCell.h"


@interface CountDownCollectionCell()

@end

@implementation CountDownCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = CLEAR_COLOR;
        self.contentView.backgroundColor = CLEAR_COLOR;
        [self setUpUI];
    }
    return self;
}


#pragma mark - setUpUI
- (void) setUpUI{
    
    [self addAllSubviews];
    [self addAllConstraints];
    
}

- (void)addAllSubviews{
    [self.contentView addSubview:self.BackGround];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:self.timeView];
    [self.contentView addSubview:self.deleteButton];
}

- (void)addAllConstraints{
    [_BackGround mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(ZOOMW(24));
        make.top.equalTo(self.contentView).offset(ZOOMW(20));
        make.right.lessThanOrEqualTo(self.contentView).offset(-ZOOMW(56));
    }];
    [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(ZOOMW(8));
        make.right.equalTo(self.contentView).offset(-ZOOMW(24));
    }];
    [_timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.BackGround);
        make.height.mas_equalTo(ZOOMW(52));
    }];
    
    [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(ZOOMW(12));
        make.right.equalTo(self.contentView).offset(-ZOOMW(12));
        make.height.width.mas_equalTo(ZOOMW(24));
    }];
}

#pragma mark - 懒加载

- (UIView *)BackGround{
    if (_BackGround == nil) {
        _BackGround = [[UIView alloc]init];
        _BackGround.backgroundColor = WHITE_COLOR;
        _BackGround.layer.cornerRadius = ZOOMW(18);
        _BackGround.clipsToBounds = YES;
    }
    return _BackGround;
}

- (UIImageView *)icon{
    if(_icon == nil){
        _icon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"countimage"]];
        _icon.hidden = YES;
    }
    return _icon;
}

- (UILabel *)nameLabel{
    if(_nameLabel == nil){
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.text = @"";
        _nameLabel.textColor = RGB(51, 51, 51);
        _nameLabel.font = KEEPASS_FONT_Medium(16);
        _nameLabel.numberOfLines = 1;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _nameLabel;
}

- (UILabel *)dateLabel{
    if(_dateLabel == nil){
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.text = @"";
        _dateLabel.textColor = RGB(102, 102, 102);
        _dateLabel.font = KEEPASS_FONT_Regular(14);
    }
    return _dateLabel;
}

- (CountDownTimeView *)timeView{
    if(_timeView == nil){
        _timeView = [[CountDownTimeView alloc] initWithIsarrival:_isarrival];
        _timeView.layer.cornerRadius = ZOOMW(18);
        _timeView.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
        _timeView.clipsToBounds = YES;
    }
    return _timeView;
}

- (UIButton *)deleteButton {
    if (_deleteButton == nil) {
        _deleteButton = [[UIButton alloc] init];
        [_deleteButton setBackgroundImage:[UIImage imageNamed:@"A_cellDelete"] forState:UIControlStateNormal];
        _deleteButton.hidden = YES;
    }
    return _deleteButton;
}

@end
