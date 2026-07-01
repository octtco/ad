//
//  FeedbackTableViewCell.m
//  Chord
//
//  Created by 蒙俊竹 on 2026/3/16.
//

#import "FeedbackTableViewCell.h"

@interface FeedbackTableViewCell ()

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIView *bubbleView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIImageView *messageImageView;
@property (nonatomic, strong) UIButton *retryButton;
@property (nonatomic, strong) NSURLSessionDataTask *imageTask;
@property (nonatomic, copy) NSString *currentImageURL;
@property (nonatomic, assign) BOOL isSenderFlag;
@property (nonatomic, assign) FeedbackSendStatus sendStatus;

@end

@implementation FeedbackTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.messageLabel.text = @"";
    self.bubbleView.layer.mask = nil;
    self.avatarImageView.image = nil;
    [self.imageTask cancel];
    self.imageTask = nil;
    self.currentImageURL = nil;
    self.messageImageView.image = nil;
    self.messageImageView.hidden = YES;
    self.messageLabel.hidden = NO;
    self.retryButton.hidden = YES;
    self.sendStatus = FeedbackSendStatusSent;
}


#pragma mark - setupUI

- (void)setupUI {
    self.backgroundColor = CLEAR_COLOR;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.separatorInset = UIEdgeInsetsMake(0, CGRectGetMaxX(self.contentView.frame) + 1000, 0, 0);
    [self addAllSubviews];
    [self addAllConstraints];
}

- (void)addAllSubviews {
    [self.contentView addSubview:self.avatarImageView];
    [self.contentView addSubview:self.bubbleView];
    [self.bubbleView addSubview:self.messageLabel];
    [self.bubbleView addSubview:self.messageImageView];
    [self.bubbleView addSubview:self.retryButton];
}

- (void)addAllConstraints {
    [_bubbleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(ZOOM(8));
        make.left.equalTo(self.contentView).offset(ZOOM(16));
        make.right.lessThanOrEqualTo(self.contentView).offset(ZOOM(-16));
        make.bottom.equalTo(self.contentView).offset(ZOOM(-8));
        make.width.lessThanOrEqualTo(self.contentView.mas_width).multipliedBy(0.72);
    }];
    
    [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bubbleView).offset(ZOOM(10));
        make.left.equalTo(self.bubbleView).offset(ZOOM(12));
        make.right.equalTo(self.bubbleView).offset(ZOOM(-12));
        make.bottom.equalTo(self.bubbleView).offset(ZOOM(-10));
    }];
}


#pragma mark - events

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self setSelected:NO animated:NO];
        // 获取长按的位置
        CGPoint location = [gestureRecognizer locationInView:self.messageLabel];
        [self.messageLabel becomeFirstResponder];
        [self showMenuAtLocation:location];
    }
}

- (void)showMenuAtLocation:(CGPoint)location{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyText:)];
    menuController.menuItems = @[copyItem];
    // 获取相对于 messageLabel 的目标矩形
    CGRect targetRect = CGRectMake(location.x, location.y, 1, 1);
    // 显示菜单
    [menuController showMenuFromView:self.messageLabel rect:targetRect];
}

- (void)copyText:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.messageLabel.text;
    // 显示成功的弹窗
    [SVProgressHUD showSuccessWithStatus:@"复制成功"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    // 不调用父类方法，避免选中状态
}

- (UIColor *)outgoingBubbleColor {
    return RGBA(239, 122, 69, 1);
}

- (UIColor *)incomingBubbleColor {
    return WHITE_COLOR;
}

- (void)applyBubbleAppearanceForSender:(BOOL)isSender {
    self.avatarImageView.image = isSender ? [self senderAvatarImage] : [self serviceAvatarImage];
    self.bubbleView.backgroundColor = isSender ? [self outgoingBubbleColor] : [self incomingBubbleColor];
}

- (void)handleRetryButtonTapped {

}


#pragma mark - Configure Send and Receive Cell

// 注意：由于出现单元格复用的情况，所以约束使用mas_remakeConstraints而非mas_makeConstraints和mas_updateConstraints
- (void)configureWithMessage:(FeedbackModel *)message iconSendImage:(UIImage*)sicon iconReceiveImage:(UIImage*)ricon{
    if (message.isSend) {
        self.isSenderFlag = YES;
        [self applyBubbleAppearanceForSender:YES];
        self.messageLabel.textColor = WHITE_COLOR;
        // 设置头像和气泡的约束
        [_avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(ZOOM(10));
            make.width.height.mas_equalTo(ZOOM(44));
            make.right.equalTo(self.contentView).offset(ZOOMW(-16));
        }];
        [_bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(ZOOM(10));
            make.bottom.equalTo(self.contentView).offset(ZOOM(-10));
            make.width.lessThanOrEqualTo(@(ZOOMW(280)));
            make.right.equalTo(self.avatarImageView.mas_left).offset(ZOOMW(-10));

        }];
    } else {
        self.isSenderFlag = NO;
        [self applyBubbleAppearanceForSender:NO];
        self.messageLabel.textColor = BLACK_COLOR;
        // 设置头像和气泡的约束
        [self.avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(ZOOM(10));
            make.width.height.mas_equalTo(ZOOM(44));
            make.left.equalTo(self.contentView).offset(ZOOMW(16));
        }];
        [self.bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(ZOOM(10));
            make.bottom.equalTo(self.contentView).offset(ZOOM(-10));
            make.width.lessThanOrEqualTo(@(ZOOMW(280)));
            make.left.equalTo(self.avatarImageView.mas_right).offset(ZOOMW(10));

        }];
    }
    self.messageLabel.text = message.content;
}

- (void)configureWithImageURL:(NSString *)imageURL isSender:(BOOL)isSender {
    self.isSenderFlag = isSender;
    self.messageLabel.hidden = YES;
    self.messageImageView.hidden = NO;
    [self applyBubbleAppearanceForSender:isSender];
    
    // 头像约束
    [self.avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(ZOOM(10));
        make.width.height.mas_equalTo(ZOOM(44));
        if (isSender) {
            make.right.equalTo(self.contentView).offset(ZOOMW(-16));
        } else {
            make.left.equalTo(self.contentView).offset(ZOOMW(16));
        }
    }];
    
    // 气泡约束
    [self.bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(ZOOM(10));
        make.bottom.equalTo(self.contentView).offset(ZOOM(-10));
        make.width.lessThanOrEqualTo(@(ZOOMW(280)));
        if (isSender) {
            make.right.equalTo(self.avatarImageView.mas_left).offset(ZOOMW(-10));
        } else {
            make.left.equalTo(self.avatarImageView.mas_right).offset(ZOOMW(10));
        }
    }];
    
    // 预设尺寸（根据屏幕宽度限制）
    CGFloat sw = [UIScreen mainScreen].bounds.size.width;
    CGFloat maxW = sw * 0.7f;
    
    // 设置图片视图约束
    [self.messageImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bubbleView).offset(ZOOM(6));
        if (isSender) {
            make.right.equalTo(self.bubbleView).offset(ZOOM(-6));
        } else {
            make.left.equalTo(self.bubbleView).offset(ZOOM(6));
        }
        make.width.mas_equalTo(ZOOMW(160));
        make.height.mas_equalTo(ZOOM(180));
        make.bottom.equalTo(self.bubbleView).offset(ZOOM(-6));
    }];
    
    self.messageImageView.image = nil;
    if (![imageURL isKindOfClass:NSString.class] || imageURL.length == 0) {
        return;
    }
    
    // data:image 或 base64
    if ([imageURL hasPrefix:@"data:image"]) {
        NSRange commaRange = [imageURL rangeOfString:@","];
        NSString *base64Part = (commaRange.location != NSNotFound && commaRange.location + 1 < imageURL.length) ? [imageURL substringFromIndex:commaRange.location + 1] : @"";
        NSData *rawData = [[NSData alloc] initWithBase64EncodedString:base64Part options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *img = rawData ? [UIImage imageWithData:rawData] : nil;
        if (img) {
            CGFloat iw = img.size.width;
            CGFloat ih = img.size.height;
            CGFloat ratio = (ih > 0.0f) ? (iw / ih) : 1.0f;
            BOOL isLandscape = ratio > 1.0f;
            CGFloat fixedW = isLandscape ? ZOOMW(220) : ZOOMW(160);
            CGFloat W = MIN(fixedW, maxW);
            CGFloat H = (ratio > 0.0f) ? (W / ratio) : ZOOM(180);
            self.messageImageView.image = img;
            [self.messageImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.bubbleView).offset(ZOOM(6));
                if (isSender) {
                    make.right.equalTo(self.bubbleView).offset(ZOOM(-6));
                } else {
                    make.left.equalTo(self.bubbleView).offset(ZOOM(6));
                }
                make.width.mas_equalTo(W);
                make.height.mas_equalTo(H);
                make.bottom.equalTo(self.bubbleView).offset(ZOOM(-6));
            }];
            [self.bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView).offset(ZOOM(10));
                make.bottom.equalTo(self.contentView).offset(ZOOM(-10));
                make.width.lessThanOrEqualTo(self.contentView.mas_width).multipliedBy(0.72f);
                if (isSender) {
                    make.right.equalTo(self.avatarImageView.mas_left).offset(ZOOMW(-10));
                    make.left.equalTo(self.messageImageView.mas_left).offset(ZOOM(-6));
                } else {
                    make.left.equalTo(self.avatarImageView.mas_right).offset(ZOOMW(10));
                    make.right.equalTo(self.messageImageView.mas_right).offset(ZOOM(6));
                }
            }];
            [self setNeedsLayout];
            return;
        }
    }
    
    NSURL *url = [NSURL URLWithString:imageURL];
    if (!url) {
        // 尝试直接以 base64 解析
        NSData *rawData = [[NSData alloc] initWithBase64EncodedString:imageURL options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *img = rawData ? [UIImage imageWithData:rawData] : nil;
        if (!img) { return; }
        CGFloat iw = img.size.width;
        CGFloat ih = img.size.height;
        CGFloat ratio = (ih > 0.0f) ? (iw / ih) : 1.0f;
        BOOL isLandscape = ratio > 1.0f;
        CGFloat fixedW = isLandscape ? ZOOMW(220) : ZOOMW(160);
        CGFloat W = MIN(fixedW, maxW);
        CGFloat H = (ratio > 0.0f) ? (W / ratio) : ZOOM(180);
        self.messageImageView.image = img;
        [self.messageImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bubbleView).offset(ZOOM(6));
            if (isSender) {
                make.right.equalTo(self.bubbleView).offset(ZOOM(-6));
            } else {
                make.left.equalTo(self.bubbleView).offset(ZOOM(6));
            }
            make.width.mas_equalTo(W);
            make.height.mas_equalTo(H);
            make.bottom.equalTo(self.bubbleView).offset(ZOOM(-6));
        }];
        [self.bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(ZOOM(10));
            make.bottom.equalTo(self.contentView).offset(ZOOM(-10));
            make.width.lessThanOrEqualTo(self.contentView.mas_width).multipliedBy(0.72f);
            if (isSender) {
                make.right.equalTo(self.avatarImageView.mas_left).offset(ZOOMW(-10));
                make.left.equalTo(self.messageImageView.mas_left).offset(ZOOM(-6));
            } else {
                make.left.equalTo(self.avatarImageView.mas_right).offset(ZOOMW(10));
                make.right.equalTo(self.messageImageView.mas_right).offset(ZOOM(6));
            }
        }];
        [self setNeedsLayout];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error || !data) { return; }
        UIImage *img = [UIImage imageWithData:data];
        if (!img) { return; }
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat iw = img.size.width;
            CGFloat ih = img.size.height;
            CGFloat ratio = (ih > 0.0f) ? (iw / ih) : 1.0f;
            BOOL isLandscape = ratio > 1.0f;
            CGFloat fixedW = isLandscape ? ZOOM(220) : ZOOM(160);
            CGFloat W = MIN(fixedW, maxW);
            CGFloat H = (ratio > 0.0f) ? (W / ratio) : ZOOM(180);
            weakSelf.messageImageView.image = img;
            [weakSelf.messageImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(weakSelf.bubbleView).offset(ZOOM(6));
                if (isSender) {
                    make.right.equalTo(weakSelf.bubbleView).offset(ZOOM(-6));
                } else {
                    make.left.equalTo(weakSelf.bubbleView).offset(ZOOM(6));
                }
                make.width.mas_equalTo(W);
                make.height.mas_equalTo(H);
                make.bottom.equalTo(weakSelf.bubbleView).offset(ZOOM(-6));
            }];
            [weakSelf setNeedsLayout];
        });
    }];
    [task resume];
}


#pragma mark - Avatar

- (UIImage *)senderAvatarImage {
    return [UIImage imageNamed:@"A_user"];
}

- (UIImage *)serviceAvatarImage {
    return [UIImage imageNamed:@"A_service"];
}


#pragma mark - lazy load

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.clipsToBounds = YES;
    }
    return _avatarImageView;
}

- (UIView *)bubbleView {
    if (!_bubbleView) {
        _bubbleView = [[UIView alloc] init];
        _bubbleView.layer.masksToBounds = YES;
        _bubbleView.layer.cornerRadius = ZOOM(12);
    }
    return _bubbleView;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.numberOfLines = 0;
        _messageLabel.font = [UIFont systemFontOfSize:ZOOM(16)];
        _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _messageLabel.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [_messageLabel addGestureRecognizer:longPressGesture];
    }
    return _messageLabel;
}

- (UIImageView *)messageImageView {
    if (!_messageImageView) {
        _messageImageView = [[UIImageView alloc] init];
        _messageImageView.contentMode = UIViewContentModeScaleAspectFit;
        _messageImageView.clipsToBounds = YES;
        _messageImageView.hidden = YES;
        _messageImageView.backgroundColor = RGB(235, 235, 235);
        _messageImageView.backgroundColor = [UIColor clearColor];
        _messageImageView.layer.cornerRadius = ZOOM(10);
        _messageImageView.layer.masksToBounds = YES;
    }
    return _messageImageView;
}

- (UIButton *)retryButton {
    if (!_retryButton) {
        _retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _retryButton.hidden = YES;
        _retryButton.titleLabel.font = [UIFont systemFontOfSize:ZOOM(12)];
        [_retryButton setTitle:@"点击重试/重新发送" forState:UIControlStateNormal];
        UIColor *red = [UIColor colorWithRed:1.0 green:0.23 blue:0.19 alpha:1.0];
        [_retryButton setTitleColor:red forState:UIControlStateNormal];
        _retryButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.86];
        _retryButton.layer.cornerRadius = ZOOM(9);
        _retryButton.clipsToBounds = YES;
        if (@available(iOS 13.0, *)) {
            UIImage *img = [UIImage systemImageNamed:@"exclamationmark.circle.fill"];
            if (img) {
                [_retryButton setImage:[img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
                _retryButton.tintColor = red;
                _retryButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, ZOOM(4));
            }
        }
        [_retryButton addTarget:self action:@selector(handleRetryButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        _retryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _retryButton.contentEdgeInsets = UIEdgeInsetsMake(0, ZOOM(6), 0, ZOOM(6));
    }
    return _retryButton;
}


@end
