//  Copyright (c) 2014 rokob. All rights reserved.

#import "SLFontManager.h"

@implementation SLFontManager

+ (UIFont *)fontForText
{
  return [UIFont systemFontOfSize:[UIFont systemFontSize]];
}

+ (UIFont *)fontForTitleText
{
  return [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
}

@end
