//
//  CountDownViewController.m
//  CountDown
//
//  Created by 刘一夫 on 2025/5/13.
//

#import "CountDownViewController.h"
#import "CountDownCollectionCell.h"
#import "CountDownPickerView.h"
#import "CountDownWhiteNoiseViewController.h"
#import "CountDownAdd.h"
#import "CountDownDetailViewController.h"
#import "FeedbackViewController.h"

@interface CountDownHomeDeleteAlertView : UIControl

@property(nonatomic, copy) dispatch_block_t confirmBlock;

- (void)showInView:(UIView *)view;

@end

@implementation CountDownHomeDeleteAlertView {
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

@interface CountDownViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) UIButton *addButton;
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property(nonatomic, strong) UIButton *classifyButton;
@property(nonatomic, assign) BOOL isDelete;

@property(nonatomic, strong) NSString *selectedClassify;

@end

@implementation CountDownViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.CountDowns = CountDownModel.CountDowns;
        self.isDelete = NO;
        self.selectedClassify = @"Default";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SetUpUI];
    UIColor *pageColor = RGBA(246, 246, 246, 1);
    self.view.backgroundColor = pageColor;
    self.collectionView.backgroundColor = pageColor;
    [self setupNavigationBar];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataUpdate:) name:@"DataUpdatedNotification" object:nil];
    
    [self UpdateUI];
    
}

- (void)handleDataUpdate:(NSNotification *)notification {
    [self UpdateUI];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - SetUpUI

- (void)SetUpUI {
    [self addAllSubviews];
    [self addAllConstraints];
}

- (void)UpdateUI {
    NSMutableArray<CountDownModel *> *filtered = nil;
    if ([self.selectedClassify isEqualToString:NSLocalizedString(@"Default", nil)] || [self.selectedClassify isEqualToString:@"Default"]) {
        filtered = [CountDownModel.CountDowns mutableCopy];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Classify == %@", self.selectedClassify];
        filtered = [CountDownModel filterCountDownsWithPredicate:predicate];
    }
    self.CountDowns = filtered ?: [NSMutableArray array];
    if (self.CountDowns.count == 0) {
        self.isDelete = NO;
        self.collectionView.allowsSelection = YES;
    }
    self.addButton.hidden = self.CountDowns.count > 0;
    [self.collectionView reloadData];
}

- (void)addAllSubviews {

    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.addButton];
}
    
- (void)addAllConstraints {
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-ZOOMW(18));
        make.height.mas_equalTo(ZOOMW(52));
        make.left.right.equalTo(self.view).inset(ZOOMW(16));
    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.bottom.equalTo(self.view);
    }];
}


#pragma mark - 按钮事件

- (void)classifyButtonDidTap:(UIButton *)button {
    NSArray *options = @[@"生活", @"工作", @"学习"];
    CountDownPickerView *picker = [[CountDownPickerView alloc] initWithOptions:options];
    
    
    // 处理选中结果
    picker.selectionBlock = ^(NSString *selectedClassify) {
        NSLog(@"用户选择了: %@", selectedClassify);
        self.selectedClassify = [self internalClassifyForSelectedText:selectedClassify];
        [self UpdateUI];
        
    };
    
    // 显示弹窗
    [self.view addSubview:picker];
}

- (void)gotoWhiteNoise:(UIButton *)sender {
    CountDownWhiteNoiseViewController *white = [[CountDownWhiteNoiseViewController alloc] init];
    [self presentViewController:white animated:YES completion:nil];
}

- (void)gotoFeedback:(UIButton *)sender {
    FeedbackViewController *feedbackVC = [[FeedbackViewController alloc] init];
    feedbackVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:feedbackVC animated:YES];
}

- (void)gotoAdd:(UIButton *)sender {
    CountDownAdd *add = [[CountDownAdd alloc] init];
    [self presentViewController:add animated:YES completion:nil];
}

- (void)showDelete:(UIButton *)sender {
    self.isDelete = !self.isDelete;
    self.collectionView.allowsSelection = !self.isDelete;
    [self.collectionView reloadData];
}

- (void)deleteCountDown:(UIButton *)sender {
    if (sender.tag >= self.CountDowns.count) {
        return;
    }
    CountDownModel *model = self.CountDowns[sender.tag];
    __weak typeof(self) weakSelf = self;
    CountDownHomeDeleteAlertView *alertView = [[CountDownHomeDeleteAlertView alloc] init];
    alertView.confirmBlock = ^{
        [weakSelf removeCountDownModel:model];
    };
    [alertView showInView:self.view];
}


#pragma mark - CollectionView Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.CountDowns.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CountDownCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    [_CountDowns[indexPath.item] updateRemainingDays];
    CountDownModel *model = _CountDowns[indexPath.item];
    cell.nameLabel.text = model.Title.length > 0 ? model.Title : @"--";
    cell.dateLabel.text = [self dateTextForCountDown:model];
    NSComparisonResult result = [model CompareDaysResult];
    cell.dayCount = model.RemainingDays;
    cell.timeView.days.text = [self remainingTextForCountDown:model compareResult:result];
    cell.deleteButton.hidden = !self.isDelete;
    cell.deleteButton.userInteractionEnabled = self.isDelete;
    cell.deleteButton.tag = indexPath.item;
    [cell.deleteButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    [cell.deleteButton addTarget:self action:@selector(deleteCountDown:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isDelete) {
        return;
    }
    CountDownDetailViewController *CountDownVC = [[CountDownDetailViewController alloc] init];
    CountDownVC.CountDown = _CountDowns[indexPath.item];
    [self presentViewController:CountDownVC animated:YES completion:nil];
}


#pragma mark - 懒加载

- (UIButton *)addButton {
    if (!_addButton) {
        _addButton = [[UIButton alloc] init];
        [_addButton setTitle:@"Aggiungere a" forState:UIControlStateNormal];
        [_addButton setTitleColor:RGBA(255, 91, 25, 1) forState:UIControlStateNormal];
        _addButton.backgroundColor = WHITE_COLOR;
        _addButton.titleLabel.font = KEEPASS_FONT_Medium(16);
        _addButton.layer.cornerRadius = ZOOMW(26);
        _addButton.layer.borderWidth = ZOOMW(1.5);
        _addButton.layer.borderColor = RGBA(255, 91, 25, 1).CGColor;
        _addButton.layer.masksToBounds = YES;
        [_addButton addTarget:self action:@selector(gotoAdd:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addButton;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.minimumLineSpacing = ZOOMW(14);
        _flowLayout.itemSize = CGSizeMake(ZOOMW(343), ZOOMW(126));
        _flowLayout.sectionInset = UIEdgeInsetsMake(ZOOMW(16), ZOOMW(16), ZOOMW(24), ZOOMW(16));
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[CountDownCollectionCell class] forCellWithReuseIdentifier:@"cell"];
        self.collectionView.backgroundColor = RGBA(246, 246, 246, 1);
        self.collectionView.alwaysBounceVertical = YES;
        self.collectionView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
        self.collectionView.clipsToBounds = YES;
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.allowsSelection = YES;
        self.collectionView.userInteractionEnabled = YES;
    }
    return _collectionView;
}

- (void)setupNavigationBar {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Conto alla rovescia";
    titleLabel.textColor = RGB(51, 51, 51);
    titleLabel.font = KEEPASS_FONT_Medium(18);
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    UIButton *addNavButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [addNavButton setImage:[UIImage imageNamed:@"A_CountDown_add"] forState:UIControlStateNormal];
    addNavButton.frame = CGRectMake(0, 0, ZOOMW(24), ZOOMW(24));
    [addNavButton addTarget:self action:@selector(gotoAdd:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:addNavButton];
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spacer.width = ZOOMW(12);
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setImage:[UIImage imageNamed:@"A_cellDelete"] forState:UIControlStateNormal];
    deleteButton.frame = CGRectMake(0, 0, ZOOMW(24), ZOOMW(24));
    [deleteButton addTarget:self action:@selector(showDelete:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithCustomView:deleteButton];
    
    self.navigationItem.rightBarButtonItems = @[addItem, spacer, deleteItem];
}

- (NSString *)dateTextForCountDown:(CountDownModel *)model {
    if (!model.TargetDate) {
        return @"Data prevista: --";
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"it_IT"];
    formatter.dateFormat = @"d MMMM yyyy";
    return [NSString stringWithFormat:@"Data prevista: %@", [formatter stringFromDate:model.TargetDate]];
}

- (NSString *)remainingTextForCountDown:(CountDownModel *)model compareResult:(NSComparisonResult)result {
    NSInteger dayCount = MAX((NSInteger)model.RemainingDays, 0);
    if (result == NSOrderedAscending) {
        if (dayCount == 1) {
            return @"È trascorso un giorno";
        }
        NSString *dayText = [self italianWordForSmallNumber:dayCount];
        return [NSString stringWithFormat:@"Sono trascorsi %@ giorni", dayText];
    }
    if (dayCount == 1) {
        return @"1 giorno rimanente";
    }
    return [NSString stringWithFormat:@"%ld giorni rimanenti", (long)dayCount];
}

- (void)refreshClassifyButtonTitle {
    NSString *displayName = [self displayNameForClassify:self.selectedClassify];
    [self.classifyButton setTitle:displayName forState:UIControlStateNormal];
    [self.classifyButton sizeToFit];
}

- (NSString *)displayNameForClassify:(NSString *)classify {
    if ([classify isEqualToString:@"生活"] || [classify isEqualToString:@"工作"] || [classify isEqualToString:@"学习"] || [classify isEqualToString:@"默认"]) {
        return classify;
    }
    if ([classify isEqualToString:@"Life"]) {
        return @"生活";
    }
    if ([classify isEqualToString:@"Work"]) {
        return @"工作";
    }
    if ([classify isEqualToString:@"Learn"]) {
        return @"学习";
    }
    if ([classify isEqualToString:@"Default"] || [classify isEqualToString:NSLocalizedString(@"Default", nil)]) {
        return @"默认";
    }
    return classify.length > 0 ? classify : @"生活";
}

- (NSString *)internalClassifyForSelectedText:(NSString *)selectedText {
    if ([selectedText isEqualToString:@"生活"]) {
        return @"Life";
    }
    if ([selectedText isEqualToString:@"工作"]) {
        return @"Work";
    }
    if ([selectedText isEqualToString:@"学习"]) {
        return @"Learn";
    }
    if ([selectedText isEqualToString:@"默认"]) {
        return @"Default";
    }
    return selectedText;
}

- (void)removeCountDownModel:(CountDownModel *)model {
    if (!model) {
        return;
    }
    [self.CountDowns removeObject:model];
    [CountDownModel.CountDowns removeObject:model];
    [CountDownModel save];
    [self UpdateUI];
}

- (NSString *)italianWordForSmallNumber:(NSInteger)number {
    NSDictionary<NSNumber *, NSString *> *words = @{
        @0: @"zero",
        @1: @"uno",
        @2: @"due",
        @3: @"tre",
        @4: @"quattro",
        @5: @"cinque",
        @6: @"sei",
        @7: @"sette",
        @8: @"otto",
        @9: @"nove",
        @10: @"dieci"
    };
    return words[@(number)] ?: [NSString stringWithFormat:@"%ld", (long)number];
}


@end
