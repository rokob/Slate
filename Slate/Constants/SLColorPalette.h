//  Copyright (c) 2014 rokob. All rights reserved.

@import UIKit;

@interface SLColorPalette : NSObject

+ (instancetype)sharedPalette;

- (UIColor *)primary;
- (UIColor *)bodyText;
- (UIColor *)lightText;

- (UIColor *)primaryWithAlpha:(CGFloat)alpha;

@end
