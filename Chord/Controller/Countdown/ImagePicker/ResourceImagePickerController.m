//
//  ResourceImagePickerController.m
//  CountDown
//
//  Created by 刘一夫 on 2025/7/22.
//


#import "ResourceImagePickerController.h"

#import <Masonry/Masonry.h>

// 自定义卡片视图 (替换原collection view cell)
@interface ResourceCardView : UIView
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *checkmarkView;
@property (nonatomic, assign) BOOL selected;

@end

@implementation ResourceCardView
- (instancetype)init {
    self = [super init];
    if (self) {
        // 卡片样式
        self.layer.cornerRadius = 12;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1.5;
        self.layer.borderColor = [UIColor clearColor].CGColor;
        
        // 图片视图
        _imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        
        // 选中标记 (采用系统样式的圆形选中标记)
        _checkmarkView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"checkmark.circle.fill"]];
        _checkmarkView.tintColor = [UIColor systemBlueColor];
        _checkmarkView.backgroundColor = [UIColor whiteColor];
        _checkmarkView.layer.cornerRadius = 12;
        _checkmarkView.alpha = 0;
        [self addSubview:_checkmarkView];
        
        // 布局
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [_checkmarkView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(10);
            make.right.equalTo(self).offset(-10);
            make.size.mas_equalTo(CGSizeMake(24, 24));
        }];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.layer.borderColor = selected ? [UIColor systemBlueColor].CGColor : [UIColor clearColor].CGColor;
        self.checkmarkView.alpha = selected ? 1.0 : 0;
        self.transform = selected ? CGAffineTransformMakeScale(0.95, 0.95) : CGAffineTransformIdentity;
    }];
}
@end

#pragma mark - 主控制器实现

@interface ResourceImagePickerController ()
// UI组件
@property (nonatomic, strong) UIView *backgroundOverlay; // 半透明黑色遮罩
@property (nonatomic, strong) UIView *cardContainer;     // 卡片容器
@property (nonatomic, strong) NSArray<ResourceCardView *> *cards;

// 数据
@property (nonatomic, strong) NSArray<UIImage *> *resourceImages;
@property (nonatomic, assign) NSInteger selectedIndex;   // 当前选中项
@property (nonatomic, strong) NSArray<NSString *> *resourceImageNames;
@end

@implementation ResourceImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    [self setupData];
    [self setupUI];
}

#pragma mark - 数据初始化
- (void)setupData {
    NSMutableArray *images = [NSMutableArray array];
    NSMutableArray *names = [NSMutableArray array];
    
    // 加载三张卡片资源图 (按实际图片名修改)
    NSArray *imageNames = @[@"A_B1", @"A_B2", @"A_B3"];
    for (NSString *name in imageNames) {
        UIImage *img = [UIImage imageNamed:name];
        if (img) {
            [images addObject:img];
            [names addObject:name];
        }
    }
    self.resourceImages = images.copy;
    self.resourceImageNames = names.copy;
}

#pragma mark - UI构建 (Masonry布局)
- (void)setupUI {
    // 半透明黑色遮罩
    self.backgroundOverlay = [UIView new];
    self.backgroundOverlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    self.backgroundOverlay.userInteractionEnabled = YES;
    [self.view addSubview:self.backgroundOverlay];
    
    // 添加点击关闭手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self
                                         action:@selector(didTapBackground)];
    [self.backgroundOverlay addGestureRecognizer:tapGesture];
    
    // 卡片容器
    self.cardContainer = [UIView new];
    self.cardContainer.backgroundColor = [UIColor whiteColor];
    self.cardContainer.layer.cornerRadius = 14;
    self.cardContainer.clipsToBounds = YES;
    [self.view addSubview:self.cardContainer];
    
    // 卡片视图
    NSMutableArray *cards = [NSMutableArray array];
    for (UIImage *image in self.resourceImages) {
        ResourceCardView *card = [ResourceCardView new];
        card.imageView.image = image;
        card.userInteractionEnabled = YES;
        
        // 添加卡片点击手势
        UITapGestureRecognizer *cardTap = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(didSelectCard:)];
        [card addGestureRecognizer:cardTap];
        
        [cards addObject:card];
        [self.cardContainer addSubview:card];
    }
    self.cards = cards.copy;

    
    [self setupConstraints];
}

- (void)setupConstraints {
    [self.backgroundOverlay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.cardContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-20); // 略微上移使视觉居中
        make.width.mas_equalTo(ZOOM(334));
        make.height.mas_equalTo(ZOOM(150));
    }];
    
    ResourceCardView *lastCard;
    for (ResourceCardView *card in self.cards) {
        [card mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.cardContainer);
            make.height.mas_equalTo(ZOOM(120));
            make.width.mas_equalTo(ZOOM(90));

            if (lastCard) {
                make.left.equalTo(lastCard.mas_right).offset(16);
            } else {
                make.left.equalTo(self.cardContainer).offset(16);
            }
        }];
        lastCard = card;
    }
    
    // 容器底部约束
    [lastCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.cardContainer).offset(-16);
    }];
    
}

#pragma mark - 手势处理
- (void)didTapBackground {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSelectCard:(UITapGestureRecognizer *)sender {
    // 获取选中的卡片索引
    NSInteger index = [self.cards indexOfObject:(ResourceCardView *)sender.view];
    if (index == NSNotFound) return;
    
    // 取消旧选中项
    if (self.selectedIndex != NSNotFound) {
        self.cards[self.selectedIndex].selected = NO;
    }
    
    // 设置新选中项
    self.selectedIndex = index;
    self.cards[index].selected = YES;
    
    // 这里选择后立即返回结果 (根据需求可调整为点完成按钮才返回)
    if (self.selectionBlock) {
        self.selectionBlock(self.resourceImageNames[index]);
    }
    
    // 延迟关闭
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

#pragma mark - 完成回调
- (void)didTapDone {
    if (self.selectionBlock && self.selectedIndex != NSNotFound) {
        self.selectionBlock(self.resourceImageNames[self.selectedIndex]);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 动画效果
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 入场动画
    self.backgroundOverlay.alpha = 0;
    self.cardContainer.transform = CGAffineTransformMakeScale(0.8, 0.8);
    
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        self.backgroundOverlay.alpha = 1;
        self.cardContainer.transform = CGAffineTransformIdentity;
    } completion:nil];
}
@end
