//
//  CountDownAdd.h
//  CountDown
//
//  Created by 刘一夫 on 2025/7/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CountDownModel : NSObject

@property(class, nonatomic, readonly) NSMutableArray<CountDownModel *> *CountDowns;
// 倒计时标题
@property(copy, nonatomic) NSString *Title;
// 目标日期
@property (nonatomic, strong) NSDate *TargetDate;

@property (nonatomic, strong) NSDate *EndDate;
// 类型
@property (nonatomic, strong) NSString *Classify;
// 是否显示时分秒
@property (nonatomic, assign) BOOL isTimeDetail;
// 背景
@property (nonatomic, strong) NSString *BackGroundName;
// 剩余时间
@property (nonatomic, assign) NSInteger RemainingDays;


+ (void)save;
+ (void)deleteAllCountDowns;
+ (NSMutableArray<CountDownModel *> *)filterCountDownsWithPredicate:(NSPredicate *)predicate;

- (void)updateRemainingDays;
- (NSComparisonResult )CompareDaysResult;


@end

NS_ASSUME_NONNULL_END
