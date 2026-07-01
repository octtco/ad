//
//  MyCell.h
//  Chord
//
//  Created by 蒙俊竹 on 2026/3/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyCell : UICollectionViewCell

@property(strong, nonatomic) UIView *containerView;
@property(strong, nonatomic) UILabel *titleLabel;
@property(strong, nonatomic) UIImageView *goView;
@property(strong, nonatomic) UILabel *versionLabel;

@end

NS_ASSUME_NONNULL_END
