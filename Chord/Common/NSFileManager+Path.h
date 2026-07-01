//
//  NSFileManager+Path.h
//  Chord
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (Path)

+ (NSString *)documentFilePathWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
