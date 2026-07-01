//
//  FeedbackModel.h
//  Chord
//
//  Created by 蒙俊竹 on 2026/3/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    FeedbackTypeNone,
    FeedbackTypeText,
    FeedbackTypeImage
} FeedbackType;

typedef NS_ENUM(NSInteger, FeedbackSendStatus) {
    FeedbackSendStatusSent = 0,
    FeedbackSendStatusSending = 1,
    FeedbackSendStatusFailed = 2
};

@interface FeedbackModel : NSObject

@property (nonatomic, assign) BOOL isSend;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, assign) NSInteger msgId;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, assign) FeedbackType type;
@property (nonatomic, assign) CGFloat imageWidth;
@property (nonatomic, assign) CGFloat imageHeight;
@property (nonatomic, assign) FeedbackSendStatus sendStatus;
@property (nonatomic, copy) NSString *localUUID;
@property (nonatomic, copy) NSString *localImageFileURL;

- (instancetype)initWithContent:(NSString *)content isSend:(BOOL)isSend;
+ (NSMutableArray<FeedbackModel *> *)allMsgs;
+ (void)saveMsgs;
+ (void)addMsg:(FeedbackModel *)Msg;
+ (void)clearMsgs;

@end

NS_ASSUME_NONNULL_END
