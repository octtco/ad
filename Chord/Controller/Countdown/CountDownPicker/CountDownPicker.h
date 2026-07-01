//
//  CountDownPicker.h
//  CountDown
//
//  Created by 刘一夫 on 2025/7/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const CountDownPickerDidSelectNotification; // 通知名称

@interface CountDownPicker : UIViewController

@property (nonatomic, strong) NSArray<NSString *> *options;
@property (nonatomic, strong) NSString *currentSelected;

- (instancetype)initWithOptions:(NSArray<NSString *> *)options;

@end

NS_ASSUME_NONNULL_END
