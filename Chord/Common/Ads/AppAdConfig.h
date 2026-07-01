//
//  AppAdConfig.h
//  Chord
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppAdConfig : NSObject

@property (nonatomic, assign, getter=isEnabled) BOOL enabled;
@property (nonatomic, copy) NSString *strategy;
@property (nonatomic, copy) NSString *primaryProvider;
@property (nonatomic, copy) NSDictionary<NSString *, NSDictionary *> *providers;

+ (instancetype)configWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)activeProviderConfig;
- (NSDictionary *)providerConfigForName:(NSString *)providerName;
- (NSArray<NSString *> *)enabledProviderNames;

@end

NS_ASSUME_NONNULL_END
