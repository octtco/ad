//
//  timeView.h
//  CountDown
//
//  Created by 刘一夫 on 2025/5/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CountDownTimeView : UIView

@property (strong, nonatomic) UILabel *arrival;
@property (strong, nonatomic) UIView *dayBackView;
@property (strong, nonatomic) UILabel *days;

@property (assign, nonatomic) NSInteger daysCount;
@property (assign, nonatomic) BOOL isarrival;

- (instancetype)initWithIsarrival:(BOOL)isarrival;

@end

NS_ASSUME_NONNULL_END
