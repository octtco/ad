//
//  BaseViewController.m
//  Chord
//

#import "BaseViewController.h"
#import "AppThemeManager.h"

@interface BaseViewController ()

@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) UILabel *emptyLabel;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [AppThemeManager sharedManager].appBackgroundColor;
    [self configureNavigationBar];
}

- (void)configureNavigationBar {
    [[AppThemeManager sharedManager] applyThemeToNavigationController:self.navigationController];
}

- (void)showLoading {
    if (!self.loadingIndicator) {
        self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:self.loadingIndicator];
        [NSLayoutConstraint activateConstraints:@[
            [self.loadingIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [self.loadingIndicator.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        ]];
    }
    [self.loadingIndicator startAnimating];
}

- (void)hideLoading {
    [self.loadingIndicator stopAnimating];
}

- (void)showEmptyViewWithMessage:(NSString *)message {
    if (!self.emptyView) {
        self.emptyView = [[UIView alloc] init];
        self.emptyView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.emptyLabel = [[UILabel alloc] init];
        self.emptyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.emptyLabel.textAlignment = NSTextAlignmentCenter;
        self.emptyLabel.font = [UIFont systemFontOfSize:15];
        self.emptyLabel.textColor = [AppThemeManager sharedManager].textSecondaryColor;
        [self.emptyView addSubview:self.emptyLabel];
        
        [NSLayoutConstraint activateConstraints:@[
            [self.emptyLabel.centerXAnchor constraintEqualToAnchor:self.emptyView.centerXAnchor],
            [self.emptyLabel.centerYAnchor constraintEqualToAnchor:self.emptyView.centerYAnchor],
        ]];
        
        [self.view addSubview:self.emptyView];
        [NSLayoutConstraint activateConstraints:@[
            [self.emptyView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [self.emptyView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        ]];
    }
    self.emptyLabel.text = message;
    self.emptyView.hidden = NO;
}

- (void)hideEmptyView {
    self.emptyView.hidden = YES;
}

@end
