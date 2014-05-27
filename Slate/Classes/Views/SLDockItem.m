//  Copyright (c) 2014 rokob. All rights reserved.

#import "SLDockItem.h"

@interface SLDockItem ()
{
  NSString *_title;
}
@end

@implementation SLDockItem

+ (instancetype)newWithTitle:(NSString *)title
{
  return [[self alloc] initWithTitle:title];
}

- (instancetype)initWithTitle:(NSString *)title
{
  if ((self = [super init])) {
    _title = title;
  }
  return self;
}

- (NSString *)title
{
  return _title;
}

@end
