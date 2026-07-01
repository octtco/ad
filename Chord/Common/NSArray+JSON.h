//
//  NSArray+JSON.h
//  Chord
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (JSON)

+ (nullable NSArray *)arrayWithJsonFile:(NSString *)filePath elementClass:(Class)elementClass;
- (void)writeToJsonFile:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END
