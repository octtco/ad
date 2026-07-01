//
//  ResourceImagePickerController.h
//  CountDown
//
//  Created by 刘一夫 on 2025/7/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^ImageNameSelectionBlock)(NSString *selectedImageName);

@interface ResourceImagePickerController : UIViewController
@property (nonatomic, copy) ImageNameSelectionBlock selectionBlock; // 选择完成回调
@end
