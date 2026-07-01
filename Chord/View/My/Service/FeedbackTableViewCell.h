//
//  FeedbackTableViewCell.h
//  Chord
//
//  Created by 蒙俊竹 on 2026/3/16.
//

#import <UIKit/UIKit.h>
#import "FeedbackModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FeedbackTableViewCell : UITableViewCell

// 初始化方法
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)identifier;
- (void)configureWithMessage:(FeedbackModel *)message iconSendImage:(UIImage*)sicon iconReceiveImage:(UIImage*)ricon;
- (void)configureWithImageURL:(NSString *)imageURL isSender:(BOOL)isSender;

@end

NS_ASSUME_NONNULL_END
