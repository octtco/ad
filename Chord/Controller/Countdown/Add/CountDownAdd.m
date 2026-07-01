//
//  CountDownAdd.m
//  CountDown
//
//  Created by 刘一夫 on 2025/7/21.
//

#import "CountDownAdd.h"
#import "CountDownPickerView.h"

static UIFont *CountDownAddSafeRegularFont(CGFloat size) {
    UIFont *font = KEEPASS_FONT_Regular(size);
    return font ?: [UIFont systemFontOfSize:size];
}

@interface CountDownEditDeleteAlertView : UIControl

@property(nonatomic, copy) dispatch_block_t confirmBlock;

- (void)showInView:(UIView *)view;

@end

@implementation CountDownEditDeleteAlertView {
    UIView *_contentView;
}

- (instancetype)init {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.48];
        [self addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = WHITE_COLOR;
    _contentView.layer.cornerRadius = ZOOMW(20);
    _contentView.clipsToBounds = YES;
    [self addSubview:_contentView];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Eliminare";
    titleLabel.textColor = RGB(51, 51, 51);
    titleLabel.font = KEEPASS_FONT_Medium(22);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [_contentView addSubview:titleLabel];

    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.text = @"Confermare la cancellazione?";
    messageLabel.textColor = RGB(51, 51, 51);
    messageLabel.font = KEEPASS_FONT_Regular(18);
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.numberOfLines = 2;
    [_contentView addSubview:messageLabel];

    UIView *horizontalLine = [[UIView alloc] init];
    horizontalLine.backgroundColor = RGBA(230, 230, 230, 1);
    [_contentView addSubview:horizontalLine];

    UIView *verticalLine = [[UIView alloc] init];
    verticalLine.backgroundColor = RGBA(230, 230, 230, 1);
    [_contentView addSubview:verticalLine];

    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"Cancellare" forState:UIControlStateNormal];
    [cancelButton setTitleColor:RGB(102, 102, 102) forState:UIControlStateNormal];
    cancelButton.titleLabel.font = KEEPASS_FONT_Regular(18);
    [cancelButton addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:cancelButton];

    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmButton setTitle:@"Confermare" forState:UIControlStateNormal];
    [confirmButton setTitleColor:RGBA(255, 91, 25, 1) forState:UIControlStateNormal];
    confirmButton.titleLabel.font = KEEPASS_FONT_Medium(18);
    [confirmButton addTarget:self action:@selector(confirmTapped) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:confirmButton];

    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.left.right.equalTo(self).inset(ZOOMW(53));
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_contentView).offset(ZOOMW(28));
        make.left.right.equalTo(_contentView).inset(ZOOMW(20));
    }];
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(ZOOMW(24));
        make.left.right.equalTo(_contentView).inset(ZOOMW(20));
    }];
    [horizontalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_contentView);
        make.top.equalTo(messageLabel.mas_bottom).offset(ZOOMW(28));
        make.height.mas_equalTo(ZOOMW(0.5));
    }];
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(_contentView);
        make.top.equalTo(horizontalLine.mas_bottom);
        make.height.mas_equalTo(ZOOMW(52));
    }];
    [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(_contentView);
        make.top.equalTo(horizontalLine.mas_bottom);
        make.left.equalTo(cancelButton.mas_right);
        make.width.equalTo(cancelButton);
        make.height.equalTo(cancelButton);
    }];
    [verticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(horizontalLine.mas_bottom);
        make.bottom.equalTo(_contentView);
        make.centerX.equalTo(_contentView);
        make.width.mas_equalTo(ZOOMW(0.5));
    }];
}

- (void)showInView:(UIView *)view {
    self.alpha = 0;
    _contentView.transform = CGAffineTransformMakeScale(1.04, 1.04);
    [view addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
        self->_contentView.transform = CGAffineTransformIdentity;
    }];
}

- (void)confirmTapped {
    if (self.confirmBlock) {
        self.confirmBlock();
    }
    [self dismissSelf];
}

- (void)dismissSelf {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end

@interface CountDownAdd ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property(nonatomic, strong) UIView *headerBar;
@property(nonatomic, strong) UIButton *backButton;
@property(nonatomic, strong) UILabel *pageTitleLabel;
@property(nonatomic, strong) UIButton *deleteButton;
@property(nonatomic, strong) UIButton *saveButton;
@property(nonatomic, strong) UIButton *footerButton;

@property(nonatomic, strong) UIControl *pickerMaskView;
@property(nonatomic, strong) UIView *datePickerPanel;
@property(nonatomic, strong) UILabel *datePickerTitleLabel;
@property(nonatomic, strong) UIPickerView *datePickerView;
@property(nonatomic, strong) UIButton *cancelDateButton;
@property(nonatomic, strong) UIButton *confirmDateButton;

@property(nonatomic, strong) NSArray<NSNumber *> *yearOptions;
@property(nonatomic, strong) NSArray<NSNumber *> *dayOptions;

@property(nonatomic, assign) NSInteger pickerYear;
@property(nonatomic, assign) NSInteger pickerMonth;
@property(nonatomic, assign) NSInteger pickerDay;
@property(nonatomic, assign) BOOL pickingEndDate;

@end

@implementation CountDownAdd {
    BOOL _isEditingMode;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = RGBA(246, 246, 246, 1);
    self.selectedDate = [NSDate date];
    self.selectedClassify = @"Life";
    self.showDetails = NO;
    [self SetUpUI];

    [self.backButton addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteButton addTarget:self action:@selector(showDeleteAlert) forControlEvents:UIControlEventTouchUpInside];
    [self.saveButton addTarget:self action:@selector(Save:) forControlEvents:UIControlEventTouchUpInside];
    [self.footerButton addTarget:self action:@selector(footerButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.TitleField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupInitialData];
}

- (void)closeKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - 初始化数据

- (void)setupInitialData {
    if (self.editingModel) {
        _isEditingMode = YES;
        self.TitleField.text = self.editingModel.Title;
        self.selectedDate = self.editingModel.TargetDate ?: [NSDate date];
        self.selectedEndDate = self.editingModel.EndDate;
        self.selectedClassify = self.editingModel.Classify.length > 0 ? self.editingModel.Classify : @"Life";
        self.showDetails = self.editingModel.isTimeDetail;
        self.imageName = self.editingModel.BackGroundName;
    } else {
        _isEditingMode = NO;
        if (!self.TitleField.text.length) {
            self.TitleField.text = @"";
        }
        self.selectedDate = self.selectedDate ?: [NSDate date];
        self.selectedClassify = self.selectedClassify.length > 0 ? self.selectedClassify : @"Life";
        self.showDetails = NO;
    }
    self.typeLabel.text = [self displayNameForClassify:self.selectedClassify];
    self.pageTitleLabel.text = _isEditingMode ? @"Modificare" : @"Aggiungere a";
    self.deleteButton.hidden = !_isEditingMode;
    self.footerButton.hidden = _isEditingMode;
    self.footerButton.userInteractionEnabled = !_isEditingMode;
    [self.footerButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).inset(ZOOMW(16));
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(_isEditingMode ? 0 : -ZOOMW(20));
        make.height.mas_equalTo(_isEditingMode ? 0 : ZOOMW(56));
    }];
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.TitleField.mas_bottom).offset(ZOOMW(24));
        make.left.right.equalTo(self.view);
        if (self->_isEditingMode) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.footerButton.mas_top).offset(-ZOOMW(24));
        }
    }];
    [self updateFooterState];
    [self.collectionView reloadData];
}

#pragma mark - setupui

- (void)SetUpUI{
    [self addAllSubviews];
    [self addAllConstraints];
}

- (void)addAllSubviews {
    [self.view addSubview:self.headerBar];
    [self.headerBar addSubview:self.backButton];
    [self.headerBar addSubview:self.pageTitleLabel];
    [self.headerBar addSubview:self.deleteButton];
    [self.headerBar addSubview:self.saveButton];

    [self.view addSubview:self.typeBackView];
    [self.typeBackView addSubview:self.typeLabel];
    [self.typeBackView addSubview:self.switchImageView];

    [self.view addSubview:self.TitleField];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.footerButton];
    [self.view addSubview:self.pickerMaskView];
    [self.pickerMaskView addSubview:self.datePickerPanel];
    [self.datePickerPanel addSubview:self.datePickerTitleLabel];
    [self.datePickerPanel addSubview:self.datePickerView];
    [self.datePickerPanel addSubview:self.cancelDateButton];
    [self.datePickerPanel addSubview:self.confirmDateButton];
}

- (void)addAllConstraints {
    [self.headerBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(ZOOMW(42));
    }];

    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerBar).offset(ZOOMW(16));
        make.centerY.equalTo(self.headerBar);
        make.width.height.mas_equalTo(ZOOMW(24));
    }];

    [self.pageTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backButton.mas_right).offset(ZOOMW(16));
        make.centerY.equalTo(self.backButton);
    }];

    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.saveButton);
        make.right.equalTo(self.saveButton.mas_left).offset(-ZOOMW(24));
        make.width.height.mas_equalTo(ZOOMW(24));
    }];

    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.headerBar).offset(-ZOOMW(16));
        make.centerY.equalTo(self.backButton);
        make.width.height.mas_equalTo(ZOOMW(24));
    }];

    [self.typeBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerBar.mas_bottom).offset(ZOOMW(22));
        make.left.right.equalTo(self.view).inset(ZOOMW(16));
        make.height.mas_equalTo(ZOOMW(48));
    }];

    [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.typeBackView);
        make.centerX.equalTo(self.typeBackView).offset(-ZOOMW(10));
    }];

    [self.switchImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.typeBackView);
        make.left.equalTo(self.typeLabel.mas_right).offset(ZOOMW(12));
        make.width.mas_equalTo(ZOOMW(24));
        make.height.mas_equalTo(ZOOMW(14));
    }];

    [self.TitleField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.typeBackView.mas_bottom).offset(ZOOMW(32));
        make.left.right.equalTo(self.view).inset(ZOOMW(16));
        make.height.mas_equalTo(ZOOMW(48));
    }];

    [self.footerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).inset(ZOOMW(16));
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-ZOOMW(20));
        make.height.mas_equalTo(ZOOMW(56));
    }];

    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.TitleField.mas_bottom).offset(ZOOMW(24));
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.footerButton.mas_top).offset(-ZOOMW(24));
    }];

    [self.pickerMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self.datePickerPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).inset(ZOOMW(16));
        make.centerY.equalTo(self.view).offset(ZOOMW(60));
        make.height.mas_equalTo(ZOOMW(312));
    }];

    [self.datePickerTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.datePickerPanel);
        make.height.mas_equalTo(ZOOMW(84));
    }];

    [self.datePickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.datePickerTitleLabel.mas_bottom);
        make.left.right.equalTo(self.datePickerPanel);
        make.height.mas_equalTo(ZOOMW(170));
    }];

    [self.cancelDateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(self.datePickerPanel);
        make.height.mas_equalTo(ZOOMW(58));
        make.width.equalTo(self.datePickerPanel.mas_width).multipliedBy(0.5);
    }];

    [self.confirmDateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(self.datePickerPanel);
        make.height.width.equalTo(self.cancelDateButton);
    }];
}

#pragma mark - CollectionView Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cellTitles.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CountDownAddCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [cell.accessary removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    [cell.Switch removeTarget:nil action:NULL forControlEvents:UIControlEventValueChanged];

    cell.nameLabel.text = self.cellTitles[indexPath.item];
    cell.contentImage.hidden = YES;

    if (indexPath.item == 0 || indexPath.item == 1) {
        cell.contentLabel.hidden = NO;
        cell.accessary.hidden = NO;
        cell.Switch.hidden = YES;
        cell.contentLabel.text = indexPath.item == 0 ? [self formattedDateString:self.selectedDate] : [self formattedDateString:self.selectedEndDate];
        [cell.accessary addTarget:self action:indexPath.item == 0 ? @selector(showDatePicker:) : @selector(showendDatePicker:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        cell.contentLabel.hidden = YES;
        cell.accessary.hidden = YES;
        cell.Switch.hidden = NO;
        cell.Switch.on = self.showDetails;
        [cell.Switch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    }

    return cell;
}

#pragma mark - 分类选择

- (void)showClassifyPicker {
    [self closeKeyboard];
    CountDownPickerView *picker = [[CountDownPickerView alloc] initWithOptions:@[@"Life", @"Work", @"Learn"]];
    picker.currentSelected = self.selectedClassify;
    __weak typeof(self) weakSelf = self;
    picker.selectionBlock = ^(NSString *selectedCountDown) {
        weakSelf.selectedClassify = selectedCountDown;
        weakSelf.typeLabel.text = [weakSelf displayNameForClassify:selectedCountDown];
    };
    [self.view addSubview:picker];
}

#pragma mark - 日期选择

- (void)showDatePicker:(id)sender {
    [self presentDatePickerForEndDate:NO];
}

- (void)showendDatePicker:(id)sender {
    [self presentDatePickerForEndDate:YES];
}

- (void)presentDatePickerForEndDate:(BOOL)isEndDate {
    [self closeKeyboard];
    self.pickingEndDate = isEndDate;
    NSDate *baseDate = isEndDate ? (self.selectedEndDate ?: self.selectedDate ?: [NSDate date]) : (self.selectedDate ?: [NSDate date]);
    [self updateDatePickerWithDate:baseDate];
    [self.datePickerView reloadAllComponents];
    [self.datePickerView selectRow:self.pickerYear - self.yearOptions.firstObject.integerValue inComponent:0 animated:NO];
    [self.datePickerView selectRow:self.pickerMonth - 1 inComponent:1 animated:NO];
    [self.datePickerView selectRow:self.pickerDay - 1 inComponent:2 animated:NO];
    self.pickerMaskView.hidden = NO;
    self.pickerMaskView.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{
        self.pickerMaskView.alpha = 1;
    }];
}

- (void)hideDatePicker {
    [UIView animateWithDuration:0.25 animations:^{
        self.pickerMaskView.alpha = 0;
    } completion:^(BOOL finished) {
        self.pickerMaskView.hidden = YES;
    }];
}

- (void)pickerMaskTapped {
    [self hideDatePicker];
}

- (void)confirmDateSelection {
    NSDate *pickedDate = [self selectedDateFromPicker];
    if (self.pickingEndDate) {
        self.selectedEndDate = pickedDate;
    } else {
        self.selectedDate = pickedDate;
    }
    [self.collectionView reloadData];
    [self hideDatePicker];
}

- (void)updateDatePickerWithDate:(NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    NSInteger currentYear = components.year;
    NSMutableArray<NSNumber *> *years = [NSMutableArray array];
    for (NSInteger year = currentYear - 1; year <= currentYear + 20; year++) {
        [years addObject:@(year)];
    }
    self.yearOptions = years;
    self.pickerYear = components.year;
    self.pickerMonth = components.month;
    self.pickerDay = components.day;
    [self reloadDayOptionsPreservingSelection];
}

- (void)reloadDayOptionsPreservingSelection {
    NSInteger maxDays = [self daysInMonth:self.pickerMonth year:self.pickerYear];
    NSMutableArray<NSNumber *> *days = [NSMutableArray array];
    for (NSInteger day = 1; day <= maxDays; day++) {
        [days addObject:@(day)];
    }
    self.dayOptions = days;
    self.pickerDay = MIN(MAX(self.pickerDay, 1), maxDays);
}

- (NSInteger)daysInMonth:(NSInteger)month year:(NSInteger)year {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = year;
    components.month = month;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date = [calendar dateFromComponents:components];
    return [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;
}

- (NSDate *)selectedDateFromPicker {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = self.pickerYear;
    components.month = self.pickerMonth;
    components.day = self.pickerDay;
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.yearOptions.count;
    }
    if (component == 1) {
        return 12;
    }
    return self.dayOptions.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return ZOOMW(56);
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (component == 1) {
        return ZOOMW(92);
    }
    return ZOOMW(110);
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = (UILabel *)view;
    if (![label isKindOfClass:[UILabel class]]) {
        label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
    }

    NSInteger selectedRow = [pickerView selectedRowInComponent:component];
    BOOL isSelected = row == selectedRow;
    NSInteger value = component == 0 ? self.yearOptions[row].integerValue : (component == 1 ? row + 1 : self.dayOptions[row].integerValue);
    NSString *unit = component == 0 ? @"Anno" : (component == 1 ? @"Luna" : @"Giorno");
    label.text = isSelected ? [NSString stringWithFormat:@"%ld  %@", (long)value, unit] : [NSString stringWithFormat:@"%ld", (long)value];
    label.font = isSelected ? KEEPASS_FONT_Medium(16) : KEEPASS_FONT_Regular(16);
    label.textColor = isSelected ? RGBA(255, 91, 25, 1) : RGB(102, 102, 102);
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        self.pickerYear = self.yearOptions[row].integerValue;
        [self reloadDayOptionsPreservingSelection];
        [pickerView reloadComponent:2];
    } else if (component == 1) {
        self.pickerMonth = row + 1;
        [self reloadDayOptionsPreservingSelection];
        [pickerView reloadComponent:2];
    } else {
        self.pickerDay = self.dayOptions[row].integerValue;
    }

    NSInteger validDayIndex = MAX(self.pickerDay - 1, 0);
    if (validDayIndex < self.dayOptions.count) {
        [pickerView selectRow:validDayIndex inComponent:2 animated:YES];
    }
    [pickerView reloadAllComponents];
}

#pragma mark - 输入事件

- (void)textFieldDidChange:(UITextField *)textField {
    [self updateFooterState];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)footerButtonTapped {
    if (self.TitleField.text.length == 0) {
        [self.TitleField becomeFirstResponder];
        return;
    }
    [self Save:self.footerButton];
}

- (void)updateFooterState {
    NSString *buttonTitle = self.TitleField.text.length > 0 ? self.TitleField.text : @"Inserisci un titolo";
    [self.footerButton setTitle:buttonTitle forState:UIControlStateNormal];
    if (self.TitleField.text.length > 0) {
        self.footerButton.backgroundColor = RGBA(255, 91, 25, 1);
        [self.footerButton setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
    } else {
        self.footerButton.backgroundColor = WHITE_COLOR;
        [self.footerButton setTitleColor:RGB(51, 51, 51) forState:UIControlStateNormal];
    }
}

#pragma mark - switch开关

- (void)switchValueChanged:(UISwitch *)sender {
    self.showDetails = sender.isOn;
}

#pragma mark - 保存

- (void)Save:(UIButton *)sender {
    [self.view endEditing:YES];

    if (self.TitleField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"Inserisci un titolo"];
        return;
    }

    CountDownModel *model = _isEditingMode ? self.editingModel : [[CountDownModel alloc] init];
    model.Title = self.TitleField.text;
    model.TargetDate = self.selectedDate;
    model.EndDate = self.selectedEndDate;
    model.Classify = self.selectedClassify;
    model.isTimeDetail = self.showDetails;
    model.BackGroundName = self.imageName.length > 0 ? self.imageName : @"A_B1";
    [model updateRemainingDays];

    if (!_isEditingMode) {
        [CountDownModel.CountDowns addObject:model];
    }
    [CountDownModel save];
    [SVProgressHUD showSuccessWithStatus:@"Salvato"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DataUpdatedNotification" object:nil];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)dismissSelf {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showDeleteAlert {
    if (!_isEditingMode || !self.editingModel) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    CountDownEditDeleteAlertView *alertView = [[CountDownEditDeleteAlertView alloc] init];
    alertView.confirmBlock = ^{
        [weakSelf deleteCurrentCountDown];
    };
    [alertView showInView:self.view];
}

- (void)deleteCurrentCountDown {
    if (!self.editingModel) {
        return;
    }
    [CountDownModel.CountDowns removeObject:self.editingModel];
    [CountDownModel save];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DataUpdatedNotification" object:nil];
    UIViewController *dismissTarget = self.presentingViewController.presentingViewController ?: self.presentingViewController ?: self;
    [dismissTarget dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 辅助

- (NSString *)formattedDateString:(NSDate *)date {
    if (!date) {
        return @"--";
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    return [formatter stringFromDate:date];
}

- (NSString *)displayNameForClassify:(NSString *)classify {
    if ([classify isEqualToString:@"Life"] || [classify isEqualToString:@"Vita"]) {
        return @"Vita";
    }
    if ([classify isEqualToString:@"Work"] || [classify isEqualToString:@"Lavoro"]) {
        return @"Lavoro";
    }
    if ([classify isEqualToString:@"Learn"] || [classify isEqualToString:@"Studio"]) {
        return @"Studio";
    }
    return classify.length > 0 ? classify : @"Vita";
}

- (NSString *)internalClassifyForSelectedText:(NSString *)selectedText {
    if ([selectedText isEqualToString:@"生活"] || [selectedText isEqualToString:@"Vita"]) {
        return @"Life";
    }
    if ([selectedText isEqualToString:@"工作"] || [selectedText isEqualToString:@"Lavoro"]) {
        return @"Work";
    }
    if ([selectedText isEqualToString:@"学习"] || [selectedText isEqualToString:@"Studio"]) {
        return @"Learn";
    }
    return selectedText;
}

#pragma mark - 懒加载

- (UIView *)headerBar {
    if (!_headerBar) {
        _headerBar = [[UIView alloc] init];
        _headerBar.backgroundColor = CLEAR_COLOR;
    }
    return _headerBar;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"A_return"] forState:UIControlStateNormal];
        _backButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
    }
    return _backButton;
}

- (UILabel *)pageTitleLabel {
    if (!_pageTitleLabel) {
        _pageTitleLabel = [[UILabel alloc] init];
        _pageTitleLabel.text = @"Aggiungere a";
        _pageTitleLabel.font = KEEPASS_FONT_Medium(18);
        _pageTitleLabel.textColor = RGB(51, 51, 51);
    }
    return _pageTitleLabel;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveButton setImage:[UIImage imageNamed:@"A_save"] forState:UIControlStateNormal];
        _saveButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
    }
    return _saveButton;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setImage:[UIImage imageNamed:@"A_cellDelete"] forState:UIControlStateNormal];
        _deleteButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
        _deleteButton.hidden = YES;
    }
    return _deleteButton;
}

- (UIView *)typeBackView {
    if (!_typeBackView) {
        _typeBackView = [[UIView alloc] init];
        _typeBackView.backgroundColor = WHITE_COLOR;
        _typeBackView.layer.cornerRadius = ZOOMW(24);
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showClassifyPicker)];
        tapGesture.cancelsTouchesInView = NO;
        [_typeBackView addGestureRecognizer:tapGesture];
    }
    return _typeBackView;
}

- (UILabel *)typeLabel {
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc] init];
        _typeLabel.textColor = RGB(51, 51, 51);
        _typeLabel.font = KEEPASS_FONT_Medium(18);
        _typeLabel.text = @"Vita";
    }
    return _typeLabel;
}

- (UIImageView *)switchImageView {
    if (!_switchImageView) {
        _switchImageView = [[UIImageView alloc] init];
        _switchImageView.contentMode = UIViewContentModeScaleAspectFit;
        _switchImageView.image = [UIImage imageNamed:@"A_CountDown_edit"];
    }
    return _switchImageView;
}

-(UITextField *)TitleField {
    if (!_TitleField) {
        _TitleField = [[UITextField alloc] init];
        UIFont *placeholderFont = CountDownAddSafeRegularFont(16);
        _TitleField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Inserisci un titolo." attributes:@{
            NSForegroundColorAttributeName: RGB(153, 153, 153),
            NSFontAttributeName: placeholderFont
        }];
        _TitleField.backgroundColor = WHITE_COLOR;
        _TitleField.layer.cornerRadius = ZOOMW(24);
        _TitleField.keyboardType = UIKeyboardTypeDefault;
        _TitleField.textAlignment = NSTextAlignmentLeft;
        _TitleField.textColor = RGB(51, 51, 51);
        _TitleField.font = placeholderFont;
        _TitleField.delegate = self;
        UIView *leftPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ZOOMW(32), ZOOMW(48))];
        _TitleField.leftView = leftPadding;
        _TitleField.leftViewMode = UITextFieldViewModeAlways;
        _TitleField.returnKeyType = UIReturnKeyDone;
    }
    return _TitleField;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.minimumLineSpacing = ZOOMW(16);
        _flowLayout.itemSize = CGSizeMake(ZOOMW(343), ZOOMW(56));
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, ZOOMW(16), ZOOMW(16), ZOOMW(16));
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[CountDownAddCell class] forCellWithReuseIdentifier:@"cell"];
        _collectionView.backgroundColor = CLEAR_COLOR;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.clipsToBounds = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.allowsSelection = NO;
    }
    return _collectionView;
}

- (UIButton *)footerButton {
    if (!_footerButton) {
        _footerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _footerButton.layer.cornerRadius = ZOOMW(28);
        _footerButton.titleLabel.font = KEEPASS_FONT_Medium(16);
        [_footerButton setTitle:@"Inserisci un titolo" forState:UIControlStateNormal];
        [_footerButton setTitleColor:RGB(51, 51, 51) forState:UIControlStateNormal];
        _footerButton.backgroundColor = WHITE_COLOR;
    }
    return _footerButton;
}

- (UIControl *)pickerMaskView {
    if (!_pickerMaskView) {
        _pickerMaskView = [[UIControl alloc] init];
        _pickerMaskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.55];
        _pickerMaskView.hidden = YES;
        [_pickerMaskView addTarget:self action:@selector(pickerMaskTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pickerMaskView;
}

- (UIView *)datePickerPanel {
    if (!_datePickerPanel) {
        _datePickerPanel = [[UIView alloc] init];
        _datePickerPanel.backgroundColor = WHITE_COLOR;
        _datePickerPanel.layer.cornerRadius = ZOOMW(24);
        _datePickerPanel.clipsToBounds = YES;
    }
    return _datePickerPanel;
}

- (UILabel *)datePickerTitleLabel {
    if (!_datePickerTitleLabel) {
        _datePickerTitleLabel = [[UILabel alloc] init];
        _datePickerTitleLabel.text = @"Dati";
        _datePickerTitleLabel.textColor = WHITE_COLOR;
        _datePickerTitleLabel.font = KEEPASS_FONT_Medium(18);
        _datePickerTitleLabel.textAlignment = NSTextAlignmentCenter;
        _datePickerTitleLabel.backgroundColor = RGBA(255, 91, 25, 1);
    }
    return _datePickerTitleLabel;
}

- (UIPickerView *)datePickerView {
    if (!_datePickerView) {
        _datePickerView = [[UIPickerView alloc] init];
        _datePickerView.dataSource = self;
        _datePickerView.delegate = self;
        _datePickerView.backgroundColor = WHITE_COLOR;
    }
    return _datePickerView;
}

- (UIButton *)cancelDateButton {
    if (!_cancelDateButton) {
        _cancelDateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelDateButton setTitle:@"Cancellare" forState:UIControlStateNormal];
        [_cancelDateButton setTitleColor:RGB(102, 102, 102) forState:UIControlStateNormal];
        _cancelDateButton.titleLabel.font = KEEPASS_FONT_Regular(16);
        [_cancelDateButton addTarget:self action:@selector(hideDatePicker) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelDateButton;
}

- (UIButton *)confirmDateButton {
    if (!_confirmDateButton) {
        _confirmDateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmDateButton setTitle:@"Confermare" forState:UIControlStateNormal];
        [_confirmDateButton setTitleColor:RGB(51, 51, 51) forState:UIControlStateNormal];
        _confirmDateButton.titleLabel.font = KEEPASS_FONT_Medium(16);
        [_confirmDateButton addTarget:self action:@selector(confirmDateSelection) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmDateButton;
}

- (NSArray<NSString *> *)cellTitles {
    if (_cellTitles == nil) {
        _cellTitles = @[@"Data prevista",
                        @"Data di fine",
                        @"Tempo di visualizzazione"];
    }
    return _cellTitles;
}

@end
