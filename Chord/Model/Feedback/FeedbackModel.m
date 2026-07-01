//
//  FeedbackModel.m
//  Chord
//
//  Created by 蒙俊竹 on 2026/3/16.
//

#import "FeedbackModel.h"
#import "NSArray+JSON.h"
#import "NSFileManager+Path.h"

@implementation FeedbackModel

+ (NSMutableArray<FeedbackModel *> *)allMsgs {
    static NSMutableArray *msgs = nil;
    
    if (msgs) {
        return msgs;
    }
    
    @synchronized (self) {
        if (!msgs) {
            msgs = [NSMutableArray array];
            
            // 尝试从文件加载
            NSArray *savedMsgs = [NSArray arrayWithJsonFile:[self filePath] elementClass:[FeedbackModel class]];
            if (savedMsgs) {
                [msgs addObjectsFromArray:savedMsgs];
            }
        }
    }
    
    return msgs;
}

- (instancetype)initWithContent:(NSString *)content isSend:(BOOL)isSend {
    self = [super init];
    if (self) {
        _content = content;
        _isSend = isSend;
    }
    return self;
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeBool:self.isSend forKey:@"isSend"];
    [coder encodeObject:self.time forKey:@"time"];
    [coder encodeInteger:self.msgId forKey:@"msgId"];
    [coder encodeObject:self.content forKey:@"content"];
    [coder encodeObject:self.imageURL forKey:@"imageURL"];
    [coder encodeInteger:self.type forKey:@"type"];
    [coder encodeFloat:self.imageWidth forKey:@"imageWidth"];
    [coder encodeFloat:self.imageHeight forKey:@"imageHeight"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        _isSend = [coder decodeBoolForKey:@"isSend"];
        _time = [coder decodeObjectForKey:@"time"];
        _msgId = [coder decodeIntegerForKey:@"msgId"];
        _content = [coder decodeObjectForKey:@"content"];
        _imageURL = [coder decodeObjectForKey:@"imageURL"];
        _type = (FeedbackType)[coder decodeIntegerForKey:@"type"];
        _imageWidth = [coder decodeFloatForKey:@"imageWidth"];
        _imageHeight = [coder decodeFloatForKey:@"imageHeight"];
    }
    return self;
}

+ (void)saveMsgs {
    [[FeedbackModel allMsgs] writeToJsonFile:[self filePath]];
}

+ (void)addMsg:(FeedbackModel *)Msg {
    [[FeedbackModel allMsgs] addObject:Msg];
    [self saveMsgs];
}

+ (void)clearMsgs {
    [[FeedbackModel allMsgs] removeAllObjects];
    [self saveMsgs];
}


#pragma mark - Private

+ (NSString *)filePath {
    return [NSFileManager documentFilePathWithName:@"Msgs.json"];
}


@end
