//
//  PrefixHeader.h
//  Chord
//

#ifndef PrefixHeader_h
#define PrefixHeader_h

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "AppStudioFeatureCompat.h"

#define kScreenWidth UIScreen.mainScreen.bounds.size.width
#define kScreenHeight UIScreen.mainScreen.bounds.size.height

#define RGB(r, g, b) [UIColor colorWithRed:(r) / 255.0 green:(g) / 255.0 blue:(b) / 255.0 alpha:1.0]
#define RGBA(r, g, b, a) [UIColor colorWithRed:(r) / 255.0 green:(g) / 255.0 blue:(b) / 255.0 alpha:(a)]
#define WHITE_COLOR UIColor.whiteColor
#define BLACK_COLOR UIColor.blackColor
#define CLEAR_COLOR UIColor.clearColor
#define APP_THEME APP_THEME_MANAGER
#define APP_THEME_FEATURE_COLOR(feature, key, fallback) [APP_THEME colorForFeature:(feature) key:(key) fallback:(fallback)]
#define APP_THEME_FEATURE_FLOAT(feature, key, fallback) [APP_THEME floatForFeature:(feature) key:(key) fallback:(fallback)]

#define ZOOMW(value) ((value) * kScreenWidth / 375.0)
#define ZOOMH(value) ((value) * kScreenHeight / 812.0)

#endif /* PrefixHeader_h */
