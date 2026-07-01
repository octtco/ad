//
//  NSFileManager+Path.m
//  Chord
//

#import "NSFileManager+Path.h"

@implementation NSFileManager (Path)

+ (NSString *)documentFilePathWithName:(NSString *)name {
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [docPath stringByAppendingPathComponent:name];
}

@end
