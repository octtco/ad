//
//  AppMockAdProvider.m
//  Chord
//

#import "AppMockAdProvider.h"
#import "AppAdConfig.h"

@interface AppMockAdProvider ()

@property (nonatomic, assign, readwrite, getter=isReady) BOOL ready;
@property (nonatomic, strong) AppAdConfig *config;

@end

@implementation AppMockAdProvider

- (void)setupWithConfig:(AppAdConfig *)config {
    self.config = config;
    NSDictionary *providerConfig = [config activeProviderConfig];
    id enabled = providerConfig[@"enabled"];
    self.ready = config.isEnabled && [enabled respondsToSelector:@selector(boolValue)] && [enabled boolValue];
#if DEBUG
    NSLog(@"[Ads] Mock provider initialized, enabled: %@", self.ready ? @"YES" : @"NO");
#endif
}

@end
