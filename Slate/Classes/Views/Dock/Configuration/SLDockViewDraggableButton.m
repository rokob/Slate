//  Copyright (c) 2014 rokob. All rights reserved.

#import "SLDockViewDraggableButton.h"

#define CLAMPED(x) MAX(1.0f, MIN(1000.0f, x))

@interface SLDockViewDraggableButton ()
{
  BOOL _dragging;
  CGPoint _lastPoint;
  CGPoint _llastPoint;
  NSTimeInterval _lastTime;
  NSTimeInterval _llastTime;
}
@end

@implementation SLDockViewDraggableButton

- (id)init
{
  if ((self = [super init])) {
    self.userInteractionEnabled = YES;
  }
  return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
  return [super pointInside:point withEvent:event];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  _lastPoint = [[touches anyObject] locationInView:self.superview];
  _lastTime = event.timestamp;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (!_dragging) {
    _dragging = YES;
    [_delegate draggableButtonDidBeginDragging:self];
  }
  CGPoint p = [[touches anyObject] locationInView:self.superview];
  self.center = p;

  _llastPoint = _lastPoint;
  _lastPoint = p;

  _llastTime = _lastTime;
  _lastTime = event.timestamp;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (!_dragging) {
    return;
  }
  _dragging = NO;
  [_delegate draggableButton:self didEndDraggingWithVelocity:[self velocityWithPoint:_lastPoint timestamp:_lastTime]];
}

- (CGPoint)velocityWithPoint:(CGPoint)point timestamp:(NSTimeInterval)timestamp
{
  CGFloat xVelocity = (point.x - _llastPoint.x) / (CGFloat)(timestamp - _llastTime);
  CGFloat yVelocity = (point.y - _llastPoint.y) / (CGFloat)(timestamp - _llastTime);

  CGFloat xFactor = xVelocity < 0 ? -1 : 1;
  xVelocity = fabsf(xVelocity);

  CGFloat yFactor = yVelocity < 0 ? -1 : 1;
  yVelocity = fabsf(yVelocity);

  return CGPointMake(xFactor*CLAMPED(xVelocity), yFactor*CLAMPED(yVelocity));
}

@end
