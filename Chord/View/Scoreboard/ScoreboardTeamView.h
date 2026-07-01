//
//  ScoreboardTeamView.h
//  JiFen
//
//  Created by 蒙俊竹 on 2024/10/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScoreboardTeamView : UIView

@property (nonatomic, assign) int score; // 分数值
@property (nonatomic, strong) UIColor *accentColor;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UIImageView *scoreBackView;
@property (nonatomic, strong) UILabel *scoreLabel;

@end

NS_ASSUME_NONNULL_END
