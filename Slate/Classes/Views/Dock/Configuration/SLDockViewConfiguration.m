//  Copyright (c) 2014 rokob. All rights reserved.

#import "SLDockViewConfiguration.h"

@implementation SLDockContext

- (instancetype)initWithBackgroundColor:(UIColor *)backgroundColor
                          selectedColor:(UIColor *)selectedColor
                        maxDisplayCount:(NSInteger)maxDisplayCount
                               location:(SLDockLocation)location
{
  if ((self = [super init])) {
    _backgroundColor = backgroundColor;
    _selectedColor = selectedColor;
    _maxDisplayCount = maxDisplayCount;
    _location = location;
  }
  return self;
}

+ (instancetype)defaultLeftContext
{
  SLDockContext *context = [self defaultContext];
  context->_location = SLDockLocationLeft;

  return context;
}

+ (instancetype)defaultLeftBottomContext
{
  SLDockContext *context = [self defaultContext];
  context->_location = SLDockLocationLeft | SLDockLocationBottom;

  return context;
}

+ (instancetype)defaultLeftTopContext
{
  SLDockContext *context = [self defaultContext];
  context->_location = SLDockLocationLeft | SLDockLocationTop;

  return context;
}

+ (instancetype)defaultRightContext
{
  SLDockContext *context = [self defaultContext];
  context->_location = SLDockLocationRight;

  return context;
}

+ (instancetype)defaultRightBottomContext
{
  SLDockContext *context = [self defaultContext];
  context->_location = SLDockLocationRight | SLDockLocationBottom;

  return context;
}

+ (instancetype)defaultRightTopContext
{
  SLDockContext *context = [self defaultContext];
  context->_location = SLDockLocationRight | SLDockLocationTop;

  return context;
}

+ (instancetype)defaultContext
{
  return [[self alloc] initWithBackgroundColor:[UIColor blackColor]
                                 selectedColor:[UIColor greenColor]
                               maxDisplayCount:5
                                      location:SLDockLocationLeft];
}

@end
