//
//  NSArray+JSON.m
//  Chord
//

#import "NSArray+JSON.h"

@implementation NSArray (JSON)

+ (nullable NSArray *)arrayWithJsonFile:(NSString *)filePath elementClass:(Class)elementClass {
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (!data) return nil;

    NSError *error;
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&error];
    if (error) {
        NSLog(@"[NSArray+JSON] unarchive error: %@", error);
        return nil;
    }
    unarchiver.requiresSecureCoding = NO;
    NSSet *classes = [NSSet setWithObjects:[NSArray class], [NSMutableArray class], elementClass, nil];
    NSArray *array = [unarchiver decodeObjectOfClasses:classes forKey:NSKeyedArchiveRootObjectKey];
    [unarchiver finishDecoding];
    return array;
}

- (void)writeToJsonFile:(NSString *)filePath {
    NSError *error;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self requiringSecureCoding:NO error:&error];
    if (error) {
        NSLog(@"[NSArray+JSON] archive error: %@", error);
        return;
    }
    [data writeToFile:filePath atomically:YES];
}

@end
