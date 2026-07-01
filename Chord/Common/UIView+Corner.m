//
//  UIView+Corner.m
//  Chord
//

#import "UIView+Corner.h"

@implementation UIView (Corner)

- (void)setCornerRadius:(CGFloat)radius {
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}

@end
