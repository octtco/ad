//
//  FeedbackViewController.m
//  Chord
//
//  Created by 蒙俊竹 on 2026/3/16.
//

#import "FeedbackViewController.h"
#import "SendView.h"
#import "FeedbackModel.h"
#import "FeedbackTableViewCell.h"

@interface FeedbackViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UITableView *chatTableView;
@property (nonatomic, strong) NSMutableArray<FeedbackModel *> *messages;
@property (nonatomic, strong) SendView *sendView;
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) UIViewController *imagePreviewController;
@property (nonatomic, assign) BOOL isLoadingOlder;
@property (nonatomic, assign) BOOL hasMoreHistory;
@property (nonatomic, assign) BOOL didInitialBottomScroll;

@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGBA(246, 246, 246, 1);
    [self setupNavigationBar];
    UIImage *backImg = [UIImage imageNamed:@"A_back"];
    if (backImg) {
        UIImage *returnImage = [backImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:returnImage style:UIBarButtonItemStylePlain target:self action:@selector(returnButtonClicked)];
    }
    
    // 点击空白收起键盘
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    tapGesture.cancelsTouchesInView = NO; // 不取消其他触摸事件
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    
    // 键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.messages = [FeedbackModel allMsgs];
    if ([FeedbackModel allMsgs].count == 0) {
        NSString *welcome = @"Salve, sono il vostro referente dedicato al servizio clienti. Non esitate a farmi qualsiasi domanda in qualsiasi momento, sarò lieto di rispondervi.";
        FeedbackModel *welcomeMsg = [[FeedbackModel alloc] initWithContent:welcome isSend:NO];
        [FeedbackModel addMsg:welcomeMsg];
    }

    [self setupUI];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!self.didInitialBottomScroll && self.messages.count > 0) {
        self.didInitialBottomScroll = YES;
        [self ensureBottomVisibleWithRetries:4 animated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.messages.count > 0) {
        [self ensureBottomVisibleWithRetries:4 animated:NO];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - setupUI

- (void)setupNavigationBar {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Feedback";
    titleLabel.textColor = RGB(51, 51, 51);
    titleLabel.font = KEEPASS_FONT_Medium(18);
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
}

- (void)setupUI {
    [self addAllSubviews];
    [self addAllConstraints];
}

- (void)addAllSubviews {
    [self.view addSubview:self.chatTableView];
    [self.view addSubview:self.sendView];
}

- (void)addAllConstraints {
    [_chatTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.sendView.mas_top);
    }];
    [_sendView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(ZOOMW(88));
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}


#pragma mark - events

- (void)returnButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleTap {
    [self.view endEditing:YES];
}

- (void)textfieldEditingChanged:(UITextField *)textField {
    NSString *trimmed = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL hasText = trimmed.length > 0;
    self.sendView.sendButton.enabled = hasText;
    self.sendView.sendButton.alpha = hasText ? 1.0 : 0.6;
}

- (void)send:(UIButton *)sender {
    NSString *userText = self.sendView.sendTextField.text;
    if (userText.length == 0) return;
    
    FeedbackModel *userMsg = [[FeedbackModel alloc] initWithContent:userText isSend:YES];
    [self.messages addObject:userMsg];
    [FeedbackModel saveMsgs];
    self.sendView.sendTextField.text = @"";
    [self.chatTableView reloadData];
    [self scrollToBottom];

    // 延迟 0.5 秒执行自动回复
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        NSString *answer = @"Ok, abbiamo ricevuto il tuo feedback e lo stiamo elaborando. Ti comunicheremo l'esito il prima possibile. Ti preghiamo di attendere con pazienza.";
        FeedbackModel *serviceMsg = [[FeedbackModel alloc] initWithContent:answer isSend:NO];
        [self.messages addObject:serviceMsg];
        [FeedbackModel saveMsgs];
        [self.chatTableView reloadData];
        [self scrollToBottom];
    });
}

- (void)openPhotoLibrary {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [SVProgressHUD showErrorWithStatus:@"Unable to access photo library"];
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    NSURL *pickedImageURL = info[UIImagePickerControllerImageURL];
    if (!pickedImageURL && image) {
        pickedImageURL = [self saveImageToTempFile:image];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (!image) {
        [SVProgressHUD showErrorWithStatus:@"Image selection failed"];
        return;
    }
    if (!pickedImageURL) {
        [SVProgressHUD showErrorWithStatus:@"Image read failed"];
        return;
    }
    NSData *previewData = UIImageJPEGRepresentation(image, 0.6);
    NSString *previewBase64 = previewData.length > 0 ? [previewData base64EncodedStringWithOptions:0] : @"";
    NSString *dataURI = previewBase64.length > 0 ? [NSString stringWithFormat:@"data:image/jpeg;base64,%@", previewBase64] : pickedImageURL.absoluteString;
    NSInteger localIndex = self.messages.count;
    FeedbackModel *localModel = [FeedbackModel new];
    localModel.localUUID = NSUUID.UUID.UUIDString;
    localModel.isSend = YES;
    localModel.type = FeedbackTypeImage;
    localModel.content = @"";
    localModel.imageURL = dataURI;
    localModel.localImageFileURL = pickedImageURL.absoluteString ?: @"";
    localModel.imageWidth = image.size.width;
    localModel.imageHeight = image.size.height;
    localModel.sendStatus = FeedbackSendStatusSending;
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    NSTimeZone *tz = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    fmt.timeZone = tz ?: [NSTimeZone timeZoneForSecondsFromGMT:8*3600];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    localModel.time = [fmt stringFromDate:[NSDate date]];
    localModel.msgId = (self.messages.count > 0 ? self.messages.lastObject.msgId : 0) + 1;
    [self.messages addObject:localModel];
    NSIndexPath *localPath = [NSIndexPath indexPathForRow:localIndex inSection:0];
    [self.chatTableView performBatchUpdates:^{
        [self.chatTableView insertRowsAtIndexPaths:@[localPath] withRowAnimation:UITableViewRowAnimationNone];
    } completion:^(BOOL finished) {
        [self scrollToBottom];
    }];
    
    [FeedbackModel saveMsgs];
}

- (NSURL *)saveImageToTempFile:(UIImage *)image {
    if (!image) { return nil; }
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    if (!imageData || imageData.length == 0) { return nil; }
    NSString *fileName = [NSString stringWithFormat:@"feedback_%@.jpg", NSUUID.UUID.UUIDString];
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    NSURL *tempURL = [NSURL fileURLWithPath:tempPath];
    NSError *error = nil;
    BOOL ok = [imageData writeToURL:tempURL options:NSDataWritingAtomic error:&error];
    if (!ok || error) { return nil; }
    return tempURL;
}


#pragma mark - table view

- (void)scrollToBottom {
    [self ensureBottomVisibleWithRetries:3 animated:YES];
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    if (self.messages.count > 0) {
        [self.view layoutIfNeeded];
        [self.chatTableView layoutIfNeeded];
        CGFloat contentHeight = self.chatTableView.contentSize.height;
        CGFloat tableHeight = CGRectGetHeight(self.chatTableView.bounds);
        UIEdgeInsets adjustedInsets = self.chatTableView.adjustedContentInset;
        CGFloat targetY = MAX(-adjustedInsets.top, contentHeight - tableHeight + adjustedInsets.bottom);
        CGPoint target = CGPointMake(0, targetY);
        [self.chatTableView setContentOffset:target animated:animated];
    }
}

- (BOOL)isNearBottom {
    CGFloat visibleBottom = self.chatTableView.contentOffset.y + CGRectGetHeight(self.chatTableView.bounds);
    CGFloat contentBottom = self.chatTableView.contentSize.height + self.chatTableView.adjustedContentInset.bottom;
    return (contentBottom - visibleBottom) <= ZOOM(120);
}

- (void)ensureBottomVisibleWithRetries:(NSInteger)retries animated:(BOOL)animated {
    [self scrollToBottomAnimated:animated];
    if (retries <= 0) { return; }
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.06 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        [strongSelf ensureBottomVisibleWithRetries:retries - 1 animated:NO];
    });
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.chatTableView) {
 
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedbackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedbackMessageCell" forIndexPath:indexPath];
    FeedbackModel *item = self.messages[indexPath.row];
    
    if (item.type == FeedbackTypeImage) {
        [cell configureWithImageURL:item.imageURL isSender:item.isSend];
    } else {
        UIImage *userImage = [UIImage imageNamed:@"A_user"];
        UIImage *serviceImage = [UIImage imageNamed:@"A_service"];
        [cell configureWithMessage:item iconSendImage:userImage iconReceiveImage:serviceImage];
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedbackModel *item = self.messages[indexPath.row];
    if (item.type == FeedbackTypeImage) {
        CGFloat contentWidth = CGRectGetWidth(tableView.bounds);
        CGFloat maxW = contentWidth * 0.7f;
        CGFloat ratio = (item.imageHeight > 0.0f) ? (item.imageWidth / item.imageHeight) : 0.0f;
        CGFloat fixedW = (ratio > 1.0f) ? ZOOMW(220) : ZOOMW(160);
        CGFloat W = MIN(fixedW, maxW);
        CGFloat imageHeight = (ratio > 0.0f) ? (W / ratio) : ZOOM(180);
        CGFloat bubblePadding = ZOOM(6) + ZOOM(6);
        CGFloat cellMargins = ZOOM(8) + ZOOM(8);
        return imageHeight + bubblePadding + cellMargins;
    } else {
        NSString *text = item.content ?: @"";
        if (text.length == 0) {
            return ZOOM(8 + 8 + 10 + 10) + ZOOM(18);
        }
        CGFloat contentWidth = CGRectGetWidth(tableView.bounds);
        CGFloat maxBubbleWidth = contentWidth * 0.72f;
        CGFloat labelHorizontalPadding = ZOOM(12) + ZOOM(12);
        CGFloat labelVerticalPadding = ZOOM(10) + ZOOM(10);
        CGFloat cellVerticalMargins = ZOOM(8) + ZOOM(8);
        CGFloat labelWidth = MAX(0.0, maxBubbleWidth - labelHorizontalPadding);
        CGRect bounding = [text boundingRectWithSize:CGSizeMake(labelWidth, CGFLOAT_MAX)
                                             options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                          attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:ZOOM(16)] }
                                             context:nil];
        CGFloat labelHeight = ceil(bounding.size.height);
        CGFloat cellHeight = labelHeight + labelVerticalPadding + cellVerticalMargins;
        CGFloat minHeight = ZOOM(44);
        return MAX(cellHeight, minHeight);
    }
}


#pragma mark - Keyboard Handling

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.sendView.sendTextField) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.sendView.sendTextField) {
        NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSString *trimmed = [newText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        BOOL hasText = trimmed.length > 0;
        self.sendView.sendButton.enabled = hasText;
        self.sendView.sendButton.alpha = hasText ? 1.0 : 0.6;
    }
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo ?: @{};
    CGRect keyboardEndFrameInWindow = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardEndFrame = [self.view convertRect:keyboardEndFrameInWindow fromView:nil];
    CGFloat overlap = MAX(0.0, CGRectGetMaxY(self.view.bounds) - CGRectGetMinY(keyboardEndFrame));
    if (@available(iOS 11.0, *)) {
        overlap = MAX(0.0, overlap - self.view.safeAreaInsets.bottom);
    }
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = ((UIViewAnimationOptions)[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16);
    [_sendView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-overlap - 20);
    }];
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        [self.view layoutIfNeeded];
        [self scrollToBottomAnimated:NO];
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo ?: @{};
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = ((UIViewAnimationOptions)[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16);
    [_sendView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
    }];
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIControl class]]) {
        return NO;
    }
    UIView *current = touch.view;
    while (current) {
        if (current == self.sendView) {
            return NO;
        }
        current = current.superview;
    }
    return YES;
}


#pragma mark - Image Preview

- (void)presentImagePreview:(UIImage *)image {
    self.previewImage = image;
    UIViewController *vc = [[UIViewController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.view.backgroundColor = [UIColor blackColor];

    UIImageView *previewImageView = [[UIImageView alloc] initWithImage:image];
    previewImageView.contentMode = UIViewContentModeScaleAspectFit;
    [vc.view addSubview:previewImageView];
    [previewImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(vc.view).offset(ZOOM(60));
        make.left.equalTo(vc.view).offset(ZOOM(16));
        make.right.equalTo(vc.view).offset(ZOOM(-16));
        make.bottom.equalTo(vc.view).offset(ZOOM(-120));
    }];

    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [saveButton setTitle:@"Save Image" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveButton.backgroundColor = RGB(45, 145, 255);
    saveButton.layer.cornerRadius = ZOOM(22);
    saveButton.layer.masksToBounds = YES;
    [saveButton addTarget:self action:@selector(savePreviewImage) forControlEvents:UIControlEventTouchUpInside];
    [vc.view addSubview:saveButton];
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(vc.view).offset(ZOOM(24));
        make.right.equalTo(vc.view).offset(ZOOM(-24));
        make.bottom.equalTo(vc.view).offset(ZOOM(-44));
        make.height.mas_equalTo(ZOOM(44));
    }];

    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    closeButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [closeButton addTarget:self action:@selector(dismissImagePreview) forControlEvents:UIControlEventTouchUpInside];
    [vc.view addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(vc.view.mas_safeAreaLayoutGuideTop).offset(ZOOM(12));
        } else {
            make.top.equalTo(vc.view).offset(ZOOM(28));
        }
        make.right.equalTo(vc.view).offset(ZOOM(-16));
        make.width.mas_equalTo(ZOOM(56));
        make.height.mas_equalTo(ZOOM(36));
    }];

    self.imagePreviewController = vc;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)dismissImagePreview {
    if (self.imagePreviewController) {
        [self.imagePreviewController dismissViewControllerAnimated:YES completion:nil];
    }
    self.imagePreviewController = nil;
}

- (void)savePreviewImage {
    if (!self.previewImage) {
        [SVProgressHUD showErrorWithStatus:@"Image save failed"];
        return;
    }
    UIImageWriteToSavedPhotosAlbum(self.previewImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        [SVProgressHUD showErrorWithStatus:@"Image save failed"];
    } else {
        [SVProgressHUD showSuccessWithStatus:@"Saved successfully"];
    }
}


#pragma mark - lazy

- (UITableView *)chatTableView {
    if (_chatTableView == nil) {
        _chatTableView = [[UITableView alloc] init];
        _chatTableView.backgroundColor = RGB(243, 243, 243);
        _chatTableView.showsVerticalScrollIndicator = NO;
        [_chatTableView registerClass:[FeedbackTableViewCell class] forCellReuseIdentifier:@"FeedbackMessageCell"]; // 注册消息单元格类
        _chatTableView.delegate = self;
        _chatTableView.dataSource = self;
    }
    return _chatTableView;
}

- (SendView *)sendView {
    if (_sendView == nil) {
        _sendView = [[SendView alloc] init];
        [_sendView.sendButton addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
        [_sendView.albumButton addTarget:self action:@selector(openPhotoLibrary) forControlEvents:UIControlEventTouchUpInside];
        _sendView.sendTextField.delegate = self;
        [_sendView.sendTextField addTarget:self action:@selector(textfieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        [self textfieldEditingChanged:_sendView.sendTextField];
    }
    return _sendView;
}


@end
