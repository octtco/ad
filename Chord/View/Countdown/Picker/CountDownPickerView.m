//
//  CountDownPicker.m
//  CountDown
//
//  Created by 刘一夫 on 2025/7/15.
//

#import "CountDownPickerView.h"


@interface CountDownPickerView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray<NSString *> *options;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation CountDownPickerView

- (instancetype)initWithOptions:(NSArray<NSString *> *)options {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        _options = options;
        [self setupUI];
    }
    return self;
}

#pragma mark - UI Setup
- (void)setupUI {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.16];

    CGFloat width = ZOOMW(182);
    CGFloat height = ZOOMW(172);
    _containerView = [[UIView alloc] initWithFrame:CGRectMake((UIScreen.mainScreen.bounds.size.width - width) * 0.5, UIScreen.mainScreen.bounds.size.height, width, height)];
    _containerView.backgroundColor = [UIColor whiteColor];
    _containerView.layer.cornerRadius = ZOOMW(18);
    _containerView.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.12].CGColor;
    _containerView.layer.shadowOpacity = 1;
    _containerView.layer.shadowOffset = CGSizeMake(0, ZOOMW(10));
    _containerView.layer.shadowRadius = ZOOMW(18);
    [self addSubview:_containerView];

    _tableView = [[UITableView alloc] initWithFrame:_containerView.bounds style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = CLEAR_COLOR;
    _tableView.scrollEnabled = NO;
    if (@available(iOS 15.0, *)) {
        _tableView.sectionHeaderTopPadding = 0;
    }
    [_containerView addSubview:_tableView];

    [UIView animateWithDuration:0.3 animations:^{
        self->_containerView.frame = CGRectMake((UIScreen.mainScreen.bounds.size.width - width) * 0.5, ZOOMW(200), width, height);
    }];
}

#pragma mark - UITableView 数据源
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _options.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ZOOMW(56);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = CLEAR_COLOR;
    NSString *option = _options[indexPath.row];
    cell.textLabel.text = [self displayNameForOption:option];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.font = KEEPASS_FONT_Regular(16);
    cell.textLabel.textColor = RGB(51, 51, 51);
    cell.textLabel.frame = CGRectMake(ZOOMW(20), 0, ZOOMW(110), ZOOMW(56));

    UIView *outerCircle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ZOOMW(18), ZOOMW(18))];
    outerCircle.layer.cornerRadius = ZOOMW(9);
    outerCircle.layer.borderWidth = ZOOMW(1.5);
    outerCircle.layer.borderColor = RGB(220, 220, 220).CGColor;

    if ([option isEqualToString:_currentSelected]) {
        cell.textLabel.textColor = RGBA(255, 91, 25, 1);
        cell.textLabel.font = KEEPASS_FONT_Medium(16);
        outerCircle.layer.borderColor = RGBA(255, 91, 25, 1).CGColor;
        UIView *innerCircle = [[UIView alloc] initWithFrame:CGRectMake(ZOOMW(4), ZOOMW(4), ZOOMW(8), ZOOMW(8))];
        innerCircle.backgroundColor = RGBA(255, 91, 25, 1);
        innerCircle.layer.cornerRadius = ZOOMW(4);
        [outerCircle addSubview:innerCircle];
    }
    cell.accessoryView = outerCircle;
    return cell;
}

#pragma mark - UITableView 代理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _currentSelected = _options[indexPath.row];
    [tableView reloadData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self->_selectionBlock) {
            self->_selectionBlock(self->_currentSelected);
        }
        [self dismiss];
    });
}

#pragma mark - 确认选择
- (void)confirmSelection {
    if (_selectionBlock) {
        _selectionBlock(_currentSelected);
    }
    [self dismiss];
}

- (NSString *)displayNameForOption:(NSString *)option {
    if ([option isEqualToString:@"Life"]) {
        return @"Vita";
    }
    if ([option isEqualToString:@"Work"]) {
        return @"Lavoro";
    }
    if ([option isEqualToString:@"Learn"]) {
        return @"Studio";
    }
    if ([option isEqualToString:@"Default"]) {
        return @"Default";
    }
    return option;
}

#pragma mark - 关闭弹窗
- (void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
        self->_containerView.transform = CGAffineTransformMakeScale(0.96, 0.96);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

// 点击遮罩关闭
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint location = [[touches anyObject] locationInView:self];
    if (!CGRectContainsPoint(_containerView.frame, location)) {
        [self dismiss];
    }
}


@end
