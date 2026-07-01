//
//  CountDownPicker.m
//  CountDown
//
//  Created by 刘一夫 on 2025/7/15.
//

#import "CountDownPicker.h"
#import <Masonry/Masonry.h>


NSString * const CountDownPickerDidSelectNotification = @"CountDownPickerDidSelectNotification";

@interface CountDownPicker () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *confirmButton;

@end

@implementation CountDownPicker


- (instancetype)initWithOptions:(NSArray<NSString *> *)options {
    self = [super init];
    if (self) {
        _options = options;
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = [UIScreen mainScreen].bounds;
    [self setupBaseUI];
}

#pragma mark - 界面配置
- (void)setupBaseUI {
    // 背景色
    self.view.backgroundColor = RGBA(255, 255, 255, 0.5);
    
    [self addAllSubviews];
    [self addAllConstraints];
    [self configureAppearance];
}

#pragma mark - 视图添加
- (void)addAllSubviews {
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.titleLabel];
    [self.containerView addSubview:self.tableView];
}

#pragma mark - 约束设置
- (void)addAllConstraints {
    // 容器视图
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.mas_equalTo(320);
        make.height.mas_equalTo(340);
    }];
    
    // 标题
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView).offset(20);
        make.left.right.equalTo(self.containerView).inset(20);
        make.height.mas_equalTo(28);
    }];
    
    // 表格
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(15);
        make.left.right.equalTo(self.containerView);
    }];
}

#pragma mark - 样式配置
- (void)configureAppearance {
    // 容器样式
    self.containerView.layer.cornerRadius = 10;
    self.containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.containerView.layer.shadowOpacity = 0.1;
    self.containerView.layer.shadowOffset = CGSizeMake(0, 4);
    self.containerView.layer.shadowRadius = 12;
    
    // 表格样式
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20);
    self.tableView.separatorColor = [UIColor colorWithWhite:0.9 alpha:1.0];
}

#pragma mark - 懒加载
- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.backgroundColor = [UIColor whiteColor];
        _containerView.clipsToBounds = YES;
    }
    return _containerView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.text = @"分类";
        _titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightSemibold];
        _titleLabel.textColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.2 alpha:1.0];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.hidden = YES;
    }
    return _titleLabel;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = ZOOM(44);
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    }
    return _tableView;
}

#pragma mark - 表格数据源
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *option = self.options[indexPath.row];
    
    // 基础配置
    cell.textLabel.text = [self displayNameForOption:option];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = SHALLOW_COLOR;
    
    // 选中状态指示器
    UIView *indicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    indicator.layer.cornerRadius = ZOOM(22);
    indicator.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1.0].CGColor;
    
    if ([option isEqualToString:self.currentSelected]) {
        indicator.backgroundColor = [UIColor colorWithRed:0.3 green:0.7 blue:0.3 alpha:1.0];
        indicator.layer.borderColor = [UIColor clearColor].CGColor;
        cell.backgroundColor = DEEP_COLOR;
    }
    
    cell.accessoryView = indicator;
    return cell;
}

- (NSString *)displayNameForOption:(NSString *)option {
    if ([option isEqualToString:@"Life"]) {
        return @"生活";
    }
    if ([option isEqualToString:@"Work"]) {
        return @"工作";
    }
    if ([option isEqualToString:@"Learn"]) {
        return @"学习";
    }
    if ([option isEqualToString:@"Default"]) {
        return @"默认";
    }
    return option;
}

#pragma mark - 表格代理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.currentSelected = self.options[indexPath.row];
        
        // 立即发送通知并关闭
        [[NSNotificationCenter defaultCenter] postNotificationName:CountDownPickerDidSelectNotification
                                                            object:nil
                                                          userInfo:@{@"selectedCountDownClassify": self.currentSelected}];
        [self dismissViewControllerAnimated:NO completion:nil];
}



#pragma mark - 交互处理
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint location = [[touches anyObject] locationInView:self.view];
    if (!CGRectContainsPoint(self.containerView.frame, location)) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

@end
