//  Copyright (c) 2014 rokob. All rights reserved.

#import "SLColorPalette.h"

@implementation SLColorPalette

+ (instancetype)sharedPalette
{
  static SLColorPalette *palette = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    palette = [[self alloc] init];
  });
  return palette;
}

- (UIColor *)primary
{
  return [self primaryWithAlpha:1.0f];
}

- (UIColor *)primaryWithAlpha:(CGFloat)alpha
{
  return [self colorFromHex:0x197886 withAlpha:alpha];
}

- (UIColor *)lightText
{
  return [UIColor whiteColor];
}

- (UIColor *)bodyText
{
  return [UIColor colorWithWhite:0.01f alpha:1.0f];
}

#pragma mark -
#pragma mark Helpers

- (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
  return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1.0];
}

- (UIColor *)colorFromHex:(NSUInteger)hex
{
  return [self colorFromHex:hex withAlpha:1.0];
}

- (UIColor *)colorFromHex:(NSUInteger)hex withAlpha:(CGFloat)alpha
{
  return [UIColor colorWithRed:((CGFloat) ((hex & 0xFF0000) >> 16))/255
                         green:((CGFloat) ((hex & 0xFF00) >> 8))/255
                          blue:((CGFloat) (hex & 0xFF))/255
                         alpha:alpha];
}

@end
