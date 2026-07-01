//
//  CountDownCollectionCell.h
//  CountDown
//
//  Created by 刘一夫 on 2025/5/13.
//

#import <UIKit/UIKit.h>
#import "CountDownTimeView.h"

@interface CountDownCollectionCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) CountDownTimeView *timeView;
@property (strong, nonatomic) UIView *BackGround;
@property (strong, nonatomic) UIButton *deleteButton;

@property (assign, nonatomic) BOOL isarrival;
@property (assign, nonatomic) NSInteger dayCount;

@end
