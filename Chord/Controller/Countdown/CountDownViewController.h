//
//  CountDownViewController.h
//  CountDown
//
//  Created by 刘一夫 on 2025/5/13.
//

#import <UIKit/UIKit.h>
#import "CountDownModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CountDownViewController : UIViewController

@property(strong, nonatomic) NSMutableArray<CountDownModel *> *CountDowns;

@end

NS_ASSUME_NONNULL_END
