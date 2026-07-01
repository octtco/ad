//
//  AppAdConfig.m
//  Chord
//

#import "AppAdConfig.h"

@implementation AppAdConfig

+ (instancetype)configWithDictionary:(NSDictionary *)dictionary {
    AppAdConfig *config = [[AppAdConfig alloc] init];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        config.enabled = NO;
        config.strategy = @"primary";
        config.primaryProvider = @"none";
        config.providers = @{};
        return config;
    }

    id enabled = dictionary[@"enabled"];
    config.enabled = [enabled respondsToSelector:@selector(boolValue)] ? [enabled boolValue] : NO;
    config.strategy = [self stringValueFromDictionary:dictionary key:@"strategy" defaultValue:@"primary"];
    config.primaryProvider = [self stringValueFromDictionary:dictionary key:@"primary_provider" defaultValue:@"none"];

    id providers = dictionary[@"providers"];
    config.providers = [providers isKindOfClass:[NSDictionary class]] ? [providers copy] : @{};

    return config;
}

- (NSDictionary *)activeProviderConfig {
    return [self providerConfigForName:self.primaryProvider];
}

- (NSDictionary *)providerConfigForName:(NSString *)providerName {
    if (providerName.length == 0) {
        return @{};
    }

    NSDictionary *providerConfig = self.providers[providerName];
    return [providerConfig isKindOfClass:[NSDictionary class]] ? providerConfig : @{};
}

- (NSArray<NSString *> *)enabledProviderNames {
    NSMutableArray<NSString *> *providerNames = [NSMutableArray array];
    [self.providers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *obj, BOOL *stop) {
        if (![key isKindOfClass:[NSString class]] || ![obj isKindOfClass:[NSDictionary class]]) {
            return;
        }

        id enabled = obj[@"enabled"];
        if ([enabled respondsToSelector:@selector(boolValue)] && [enabled boolValue]) {
            [providerNames addObject:key];
        }
    }];
    return [providerNames copy];
}

+ (NSString *)stringValueFromDictionary:(NSDictionary *)dictionary key:(NSString *)key defaultValue:(NSString *)defaultValue {
    id value = dictionary[key];
    return [value isKindOfClass:[NSString class]] ? value : defaultValue;
}

@end
