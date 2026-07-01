#import "AppStudioFeatureCompat.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

static const NSString *AppStudioHitTestEdgeInsetsKey = @"AppStudioHitTestEdgeInsets";

@implementation UIView (AppStudioFeatureCompat)

- (void)setX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x {
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)showClickedAnimation {
    [self showClickedAnimationWithLevel:5];
}

- (void)showClickedAnimationWithLevel:(NSUInteger)level {
    CAKeyframeAnimation *animation = [[CAKeyframeAnimation alloc] init];
    animation.keyPath = @"transform";
    animation.duration = 0.2;
    animation.removedOnCompletion = YES;

    CGFloat factor = 1.0 + level * 0.02;
    animation.values = @[
        [NSValue valueWithCATransform3D:CATransform3DIdentity],
        [NSValue valueWithCATransform3D:CATransform3DMakeScale(factor, factor, 1.0)],
        [NSValue valueWithCATransform3D:CATransform3DIdentity],
    ];
    [self.layer addAnimation:animation forKey:nil];
}

@end

@implementation UIButton (AppStudioFeatureCompat)

- (void)setHitTestEdgeInsets:(UIEdgeInsets)hitTestEdgeInsets {
    NSValue *value = [NSValue value:&hitTestEdgeInsets withObjCType:@encode(UIEdgeInsets)];
    objc_setAssociatedObject(self, &AppStudioHitTestEdgeInsetsKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)hitTestEdgeInsets {
    NSValue *value = objc_getAssociatedObject(self, &AppStudioHitTestEdgeInsetsKey);
    if (!value) {
        return UIEdgeInsetsZero;
    }
    UIEdgeInsets insets;
    [value getValue:&insets];
    return insets;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    UIEdgeInsets insets = self.hitTestEdgeInsets;
    if (UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsetsZero) || !self.enabled || self.hidden) {
        return [super pointInside:point withEvent:event];
    }
    return CGRectContainsPoint(UIEdgeInsetsInsetRect(self.bounds, insets), point);
}

+ (instancetype)buttonWithTitle:(NSString *)title fontSize:(CGFloat)fontSize bold:(BOOL)bold height:(CGFloat)height titleColor:(UIColor *)titleColor backGroundColor:(UIColor *)backgroundColor {
    UIButton *button = [self buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = bold ? [UIFont boldSystemFontOfSize:fontSize] : [UIFont systemFontOfSize:fontSize];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    button.backgroundColor = backgroundColor;
    button.layer.cornerRadius = height / 2.0;
    button.clipsToBounds = YES;
    return button;
}

@end

@implementation UILabel (AppStudioFeatureCompat)

+ (instancetype)labelWithText:(NSString *)text fontSize:(NSUInteger)size bold:(BOOL)isBold textColor:(UIColor *)textColor {
    UILabel *label = [[self alloc] init];
    label.text = text;
    label.font = isBold ? [UIFont systemFontOfSize:size weight:UIFontWeightSemibold] : [UIFont systemFontOfSize:size];
    label.textColor = textColor ?: UIColor.blackColor;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

@end

@implementation NSString (AppStudioFeatureCompat)

- (NSString *)randomElement {
    if (self.length == 0) {
        return @"";
    }
    NSUInteger index = arc4random_uniform((uint32_t)self.length);
    return [self substringWithRange:NSMakeRange(index, 1)];
}

- (instancetype)appendOrInsertToFront:(NSString *)string {
    NSMutableString *result = [self isKindOfClass:NSMutableString.class] ? (NSMutableString *)self : self.mutableCopy;
    if (arc4random_uniform(2)) {
        [result appendString:string];
    } else {
        [result insertString:string atIndex:0];
    }
    return result;
}

@end
