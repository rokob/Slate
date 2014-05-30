//  Copyright (c) 2014 rokob. All rights reserved.

#import "SLDockWindow.h"

#import "SLDockViewDraggableButton.h"

@interface SLDockWindow ()
{
  SLDockViewDraggableButton *__weak _button;
}
@end

@implementation SLDockWindow

- (id)initWithFrame:(CGRect)frame
{
  if ((self = [super initWithFrame:frame])) {
    // Initialization code
  }
  return self;
}

- (void)configureWithButton:(SLDockViewDraggableButton *)button
{
  _button = button;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
  UIView *result = [super hitTest:point withEvent:event];
  CGPoint buttonPoint = [_button convertPoint:point fromView:self];
  if ([_button pointInside:buttonPoint withEvent:event]) {
    return _button;
  }
  return result;
}

@end
