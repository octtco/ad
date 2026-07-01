//
//  CountDownPicker.h
//  CountDown
//
//  Created by 刘一夫 on 2025/7/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^CountDownSelectionBlock)(NSString *selectedCountDown);

@interface CountDownPickerView : UIView

@property (nonatomic, copy) CountDownSelectionBlock selectionBlock;
@property (nonatomic, strong) NSString *currentSelected;

- (instancetype)initWithOptions:(NSArray<NSString *> *)options;


@end

NS_ASSUME_NONNULL_END
