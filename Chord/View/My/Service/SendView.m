//
//  SendView.m
//  Chord
//
//  Created by 蒙俊竹 on 2026/3/16.
//

#import "SendView.h"

@implementation SendView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI {
    self.backgroundColor = WHITE_COLOR;
    [self addAllSubviews];
    [self addAllConstraints];
}

#pragma mark - Setup

- (void)addAllSubviews {
    [self addSubview:self.containerView];
    [self addSubview:self.sendBackView];
    [self addSubview:self.albumButton];
    [self addSubview:self.sendTextField];
    [self addSubview:self.sendButton];
}

- (void)addAllConstraints {
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    [self.albumButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView).offset(ZOOMW(16));
        make.centerY.equalTo(self.sendBackView);
        make.width.height.mas_equalTo(ZOOMW(28));
    }];

    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.containerView).offset(-ZOOMW(16));
        make.centerY.equalTo(self.sendBackView);
        make.width.height.mas_equalTo(ZOOMW(30));
    }];

    [self.sendBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView).offset(ZOOMW(10));
        make.left.equalTo(self.albumButton.mas_right).offset(ZOOMW(12));
        make.right.equalTo(self.sendButton.mas_left).offset(-ZOOMW(16));
        make.height.mas_equalTo(ZOOMW(54));
    }];

    [self.sendTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.sendBackView).offset(ZOOMW(18));
        make.right.equalTo(self.sendBackView).offset(-ZOOMW(18));
        make.centerY.equalTo(self.sendBackView);
    }];
}

#pragma mark - Helpers

- (UIImage *)photoOutlineImage {
    CGSize size = CGSizeMake(ZOOMW(28), ZOOMW(28));
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    UIColor *accent = RGBA(255, 91, 25, 1);
    CGRect frame = CGRectMake(1.5, 1.5, size.width - 3, size.height - 3);

    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:ZOOMW(3)];
    borderPath.lineWidth = ZOOMW(2);
    [accent setStroke];
    [borderPath stroke];

    UIBezierPath *sunPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(size.width * 0.64, size.height * 0.22, size.width * 0.12, size.width * 0.12)];
    [accent setFill];
    [sunPath fill];

    UIBezierPath *mountainPath = [UIBezierPath bezierPath];
    [mountainPath moveToPoint:CGPointMake(size.width * 0.18, size.height * 0.72)];
    [mountainPath addLineToPoint:CGPointMake(size.width * 0.42, size.height * 0.48)];
    [mountainPath addLineToPoint:CGPointMake(size.width * 0.56, size.height * 0.62)];
    [mountainPath addLineToPoint:CGPointMake(size.width * 0.72, size.height * 0.42)];
    [mountainPath addLineToPoint:CGPointMake(size.width * 0.82, size.height * 0.72)];
    mountainPath.lineWidth = ZOOMW(2);
    mountainPath.lineCapStyle = kCGLineCapRound;
    mountainPath.lineJoinStyle = kCGLineJoinRound;
    [accent setStroke];
    [mountainPath stroke];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)sendOutlineImage {
    CGSize size = CGSizeMake(ZOOMW(30), ZOOMW(30));
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    UIColor *accent = RGBA(255, 91, 25, 1);

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(size.width * 0.14, size.height * 0.53)];
    [path addLineToPoint:CGPointMake(size.width * 0.84, size.height * 0.18)];
    [path addLineToPoint:CGPointMake(size.width * 0.62, size.height * 0.82)];
    [path addLineToPoint:CGPointMake(size.width * 0.51, size.height * 0.58)];
    [path addLineToPoint:CGPointMake(size.width * 0.14, size.height * 0.53)];
    path.lineWidth = ZOOMW(2.4);
    path.lineJoinStyle = kCGLineJoinRound;
    path.lineCapStyle = kCGLineCapRound;
    [accent setStroke];
    [path stroke];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - Lazy

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = WHITE_COLOR;
    }
    return _containerView;
}

- (UIView *)sendBackView {
    if (!_sendBackView) {
        _sendBackView = [[UIView alloc] init];
        _sendBackView.backgroundColor = RGB(243, 243, 243);
        _sendBackView.layer.cornerRadius = ZOOMW(27);
    }
    return _sendBackView;
}

- (UIButton *)albumButton {
    if (!_albumButton) {
        _albumButton = [[UIButton alloc] init];
        [_albumButton setImage:[self photoOutlineImage] forState:UIControlStateNormal];
    }
    return _albumButton;
}

- (UITextField *)sendTextField {
    if (!_sendTextField) {
        _sendTextField = [[UITextField alloc] init];
        UIFont *font = KEEPASS_FONT_Regular(16);
        if (font == nil) {
            font = [UIFont systemFontOfSize:16];
        }
        _sendTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Inserisci"
                                                                               attributes:@{
            NSForegroundColorAttributeName: RGBA(182, 182, 182, 1),
            NSFontAttributeName: font
        }];
        _sendTextField.font = font;
        _sendTextField.textColor = RGB(51, 51, 51);
    }
    return _sendTextField;
}

- (UIButton *)sendButton {
    if (!_sendButton) {
        _sendButton = [[UIButton alloc] init];
        [_sendButton setImage:[self sendOutlineImage] forState:UIControlStateNormal];
    }
    return _sendButton;
}

@end
