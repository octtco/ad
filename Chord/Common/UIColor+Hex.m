//
//  UIColor+Hex.m
//  Chord
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (UIColor *)colorWithHex:(NSString *)hexString {
    NSString *str = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    if (str.length == 3) {
        NSString *r = [str substringWithRange:NSMakeRange(0, 1)];
        NSString *g = [str substringWithRange:NSMakeRange(1, 1)];
        NSString *b = [str substringWithRange:NSMakeRange(2, 1)];
        str = [NSString stringWithFormat:@"%@%@%@%@%@%@", r, r, g, g, b, b];
    } else if (str.length == 4) {
        NSString *r = [str substringWithRange:NSMakeRange(0, 1)];
        NSString *g = [str substringWithRange:NSMakeRange(1, 1)];
        NSString *b = [str substringWithRange:NSMakeRange(2, 1)];
        NSString *a = [str substringWithRange:NSMakeRange(3, 1)];
        str = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", r, r, g, g, b, b, a, a];
    }
    
    if (str.length == 6) {
        str = [str stringByAppendingString:@"FF"];
    }
    
    if (str.length != 8) {
        return [UIColor blackColor];
    }
    
    unsigned int hex = 0;
    [[NSScanner scannerWithString:str] scanHexInt:&hex];
    
    CGFloat r = ((hex & 0xFF000000) >> 24) / 255.0;
    CGFloat g = ((hex & 0x00FF0000) >> 16) / 255.0;
    CGFloat b = ((hex & 0x0000FF00) >> 8)  / 255.0;
    CGFloat a =  (hex & 0x000000FF)        / 255.0;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

@end
