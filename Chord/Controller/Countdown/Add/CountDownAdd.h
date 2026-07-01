//
//  CountDownAdd.h
//  CountDown
//
//  Created by 刘一夫 on 2025/7/21.
//

#import <Foundation/Foundation.h>
#import "CountDownAddCell.h"
#import "ActionSheetDatePicker.h"
#import "ResourceImagePickerController.h"
#import "CountDownModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CountDownAdd : UIViewController
 
@property(nonatomic, strong) UIView *typeBackView;
@property(nonatomic, strong) UILabel *typeLabel;
@property(nonatomic, strong) UIImageView *switchImageView;
@property(nonatomic, strong) UITextField *TitleField;
@property(strong, nonatomic) NSArray<NSString *> *cellTitles;
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property(nonatomic, strong) UILabel *TitleLabel;
@property(nonatomic, strong) NSDate *selectedDate;
@property(nonatomic, strong) NSDate *selectedEndDate;
@property(nonatomic, strong) NSString *selectedClassify;
@property(nonatomic, strong) NSString *imageName;

@property(strong, nonatomic) CountDownModel *CountDown;
@property (nonatomic, strong, nullable) CountDownModel *editingModel;

@property (nonatomic, assign) BOOL showDetails;


@end

NS_ASSUME_NONNULL_END
