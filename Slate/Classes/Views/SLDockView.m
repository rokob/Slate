//  Copyright (c) 2014 rokob. All rights reserved.

#import "SLDockView.h"

typedef NS_ENUM(NSUInteger, SLDockState) {
  SLDockStateDisabled = 0,
  SLDockStateHidden,
  SLDockStateShowing,
  SLDockStateVisible,
  SLDockStateSelected,
  SLDockStateHiding
};

@interface SLDockView () <UIGestureRecognizerDelegate>
{
  NSArray *_navigationItems;
  NSArray *_navigationViews;
  UIWindow *_window;
  NSUInteger _selectedIndex;
  UILongPressGestureRecognizer *_revealGestureRecognizer;
  SLDockState _state;
  UIColor *_defaultBackgroundColor;
}
@end

@implementation SLDockView

- (id)initWithWindow:(UIWindow *)window navigationItems:(NSArray *)items
{
  if ((self = [super init])) {
    _navigationItems = [items copy];
    _window = window;
    _selectedIndex = NSNotFound;
    _defaultBackgroundColor = [UIColor blackColor];
  }
  return self;
}

- (void)setEnabled:(BOOL)enabled
{
  if (enabled ^ (SLDockStateDisabled == _state)) {
    return;
  }
  if (enabled) {
    [self transitionToState:SLDockStateHidden];
  } else {
    [self transitionToState:SLDockStateDisabled];
  }
}

- (void)transitionToState:(SLDockState)newState
{
  if (newState == _state) {
    return;
  }
  SLDockState oldState = _state;
  _state = newState;

  switch (newState) {
    case SLDockStateDisabled:
      _navigationViews = nil;
      [_window removeGestureRecognizer:self.revealGestureRecognizer];
      break;
    case SLDockStateHidden:
      if (oldState == SLDockStateDisabled) {
        _navigationViews = [self constructNavigationViewsWithItems:_navigationItems];
        [_window addGestureRecognizer:self.revealGestureRecognizer];
      }
      break;
    case SLDockStateShowing:
    {
      [UIView animateWithDuration:1.0f
                            delay:0.0
           usingSpringWithDamping:0.8f
            initialSpringVelocity:2.0f
                          options:UIViewAnimationOptionCurveEaseInOut
                       animations:^{
                         [self->_navigationViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
                           BOOL even = idx%2==0;
                           CGFloat offset = idx==0 ? 25.0f : 25.0f - 12.5f*(idx - (even ? 1 : 0));
                           view.center = CGPointMake(50.0f+offset, view.center.y);
                         }];
                       }
                       completion:^(BOOL finished){
                         [self transitionToState:SLDockStateVisible];
                       }];
    }
      break;
    case SLDockStateVisible:
    {

    }
      break;
    case SLDockStateHiding:
    {
      [UIView animateWithDuration:0.7f
                            delay:0.0
           usingSpringWithDamping:0.8f
            initialSpringVelocity:3.0f
                          options:UIViewAnimationOptionCurveEaseInOut
                       animations:^{
                         [self->_navigationViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
                           view.center = CGPointMake(-50.0f, view.center.y);
                         }];
                       }
                       completion:^(BOOL finished){
                         [self->_navigationViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
                           [view setBackgroundColor:self->_defaultBackgroundColor];
                         }];
                         [self transitionToState:SLDockStateHidden];
                       }];
    }
      break;
    case SLDockStateSelected:
    {
      UIView *selectedView = (UIView *)[_navigationViews objectAtIndex:_selectedIndex];
      UIColor *colorToRestore = selectedView.backgroundColor;
      [UIView animateKeyframesWithDuration:1.5f
                                     delay:0.0
                                   options:UIViewKeyframeAnimationOptionCalculationModeCubic
                                animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5f animations:^{
                                    selectedView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2f, 1.2f);
                                    [selectedView setBackgroundColor:[UIColor greenColor]];
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.5f relativeDuration:0.25f animations:^{
                                    selectedView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9f, 0.9f);
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.75f relativeDuration:0.25f animations:^{
                                    selectedView.transform = CGAffineTransformIdentity;
                                    [self->_navigationViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
                                      view.center = CGPointMake(-50.0f, view.center.y);
                                    }];
                                  }];
                                }
                                completion:^(BOOL finished) {
                                  [selectedView setBackgroundColor:colorToRestore];
                                  [self transitionToState:SLDockStateHidden];
                                }];
    }
      break;
  }
}

- (NSArray *)constructNavigationViewsWithItems:(NSArray *)items
{
  CGRect navFrame = CGRectZero;
  NSMutableArray *navViews = [NSMutableArray array];
  for (NSInteger i=0; i<5; i++) {
    navFrame.size = CGSizeMake(50.0f, 50.0f);
    UIView *navView = [[UIView alloc] initWithFrame:navFrame];
    BOOL even = i%2==0;
    CGFloat offset = i==0 ? 0 : 27.5f * ( (i+1)*(even?-1:1) + (even?1:0) );
    navView.center = CGPointMake(-50.0f, _window.center.y+offset);
    [navView setBackgroundColor:_defaultBackgroundColor];
    navView.layer.cornerRadius = 25.0f;
    [navViews addObject:navView];
    [_window addSubview:navView];
  }
  return [navViews copy];
}

- (UILongPressGestureRecognizer *)revealGestureRecognizer
{
  if (!_revealGestureRecognizer) {
    _revealGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(didLongPress)];
    _revealGestureRecognizer.delegate = self;
  }
  return _revealGestureRecognizer;
}

- (void)didLongPress
{
  if (_revealGestureRecognizer.state == UIGestureRecognizerStateBegan) {
    [self transitionToState:SLDockStateShowing];
  } else if (_revealGestureRecognizer.state == UIGestureRecognizerStateEnded) {
    CGPoint location = [_revealGestureRecognizer locationInView:_window];
    NSUInteger selectedIndex = [_navigationViews indexOfObjectPassingTest:^BOOL(UIView *view, NSUInteger idx, BOOL *stop) {
      return CGRectContainsPoint(view.frame, location) ? YES : NO;
    }];
    if (selectedIndex != NSNotFound) {
      _selectedIndex = selectedIndex;
      [self transitionToState:SLDockStateSelected];
    } else {
      [self transitionToState:SLDockStateHiding];
    }
  }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
  if (self.revealGestureRecognizer != gestureRecognizer) { return NO; }
  CGPoint location = [gestureRecognizer locationInView:_window];
  return location.x < 75.0f && fabsf(location.y - _window.frame.size.height/2) < 75.0f;
}

@end
