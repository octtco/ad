//
//  SendView.h
//  Chord
//
//  Created by 蒙俊竹 on 2026/3/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SendView : UIView

@property(strong, nonatomic) UIView *containerView;
@property(strong, nonatomic) UIView *sendBackView;
@property(strong, nonatomic) UITextField *sendTextField;
@property(strong, nonatomic) UIButton *sendButton;
@property(strong, nonatomic) UIButton *albumButton;

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
