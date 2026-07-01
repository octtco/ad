//
//  CountDownAdd.m
//  CountDown
//
//  Created by 刘一夫 on 2025/7/21.
//

#import "CountDownModel.h"
#import "NSArray+JSON.h"
#import "NSFileManager+Path.h"


@implementation CountDownModel

+ (NSMutableArray<CountDownModel *> *)CountDowns {
    static id CountDowns = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *array = [NSArray arrayWithJsonFile:self.filePath elementClass:CountDownModel.class];
        CountDowns = array ? [array mutableCopy] : [NSMutableArray array];
    });
    return CountDowns;
}
- (void)setValue:(id)value forKey:(NSString *)key {
    if (([key isEqualToString:@"TargetDate"] && [value isKindOfClass:[NSString class]]) || ([key isEqualToString:@"EndDate"] && [value isKindOfClass:[NSString class]])) {
        // 创建日期格式化器（复用优化）
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
        [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        
        // 字符串转 NSDate
        NSDate *date = [formatter dateFromString:value];
        if (date) {
            [super setValue:date forKey:key]; // 成功转换后赋值
        } else {
            NSLog(@"⚠️ 日期转换失败：字符串格式错误 -> %@", value);
        }
    } else {
        [super setValue:value forKey:key]; // 其他字段正常处理
    }
}
- (NSDictionary *)dictionaryRepresentation {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"]; 
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    NSString *dateString = [formatter stringFromDate:self.TargetDate];
    NSString *enddateString = [formatter stringFromDate:self.EndDate];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"Title"] = self.Title;
    dict[@"TargetDate"] = dateString;
    dict[@"EndDate"] = enddateString;
    dict[@"Classify"] = self.Classify;
    dict[@"isTimeDetail"] = @(self.isTimeDetail);
    dict[@"BackGroundName"] = self.BackGroundName;
    
    return dict;
}

+ (void)save {
    [CountDownModel.CountDowns writeToJsonFile:self.filePath];
    
    // 将 accounts 转换为 JSON 格式的字符串并打印
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[CountDownModel.CountDowns valueForKey:@"dictionaryRepresentation"] options:NSJSONWritingPrettyPrinted error:&error];
    
    if (!error) {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"CountDowns.json 内容:\n%@", jsonString);
    } else {
        NSLog(@"转换 JSON 失败: %@", error.localizedDescription);
    }
}

+ (void)deleteAllCountDowns {
    NSLog(@"BeforedeleteAllCountDowns，count=%ld", [CountDownModel.CountDowns count]);
    NSMutableArray *CountDownsToDelete = [NSMutableArray array];
    
    for (CountDownModel *deleteCountDowns in CountDownModel.CountDowns) {
        NSString *Title = deleteCountDowns.Title;
        // 记录要删除的账号
        [CountDownsToDelete addObject:deleteCountDowns];
    }
    // 从 accounts 中删除记录的账号
    [CountDownModel.CountDowns removeObjectsInArray:CountDownsToDelete];
    // 保存新的账户数据
    [CountDownModel save];
    NSLog(@"AfterdeleteAllCountDowns，count=%ld", [CountDownModel.CountDowns count]);
}

+ (NSMutableArray<CountDownModel *> *)filterCountDownsWithPredicate:(NSPredicate *)predicate {
    NSMutableArray * array = self.CountDowns;
    NSArray *filteredArray = [self.CountDowns filteredArrayUsingPredicate:predicate];
    return [filteredArray mutableCopy];
}

- (void)updateRemainingDays {
    if (!_TargetDate) return;
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay
                                              fromDate:now
                                                toDate:_TargetDate
                                               options:0];
    NSLog(@"components.day的值为%ld", labs((long)components.day));
    _RemainingDays = labs(components.day); // 绝对值
}

- (NSComparisonResult )CompareDaysResult {
    NSDate *now = [NSDate date];
    
    NSComparisonResult result = [self.TargetDate compare:now];
    return result;
}


#pragma mark - private
+ (NSString *)filePath {
    return [NSFileManager documentFilePathWithName:@"CountDownModel.json"];
}

@end

