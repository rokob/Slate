//  Copyright (c) 2014 rokob. All rights reserved.

#import "SLDockView.h"
#import "SLDockViewInternal.h"

#import "SLDockItem.h"

static const CGFloat kViewSize = 50.0f;
static const CGFloat kExtraOffsetY = 10.0f;
static const CGFloat kSpacingY = 5.0f;
static const CGFloat kItemSpacingY = (kViewSize + kSpacingY) / 2.0f;
static const CGFloat kMaxOffsetX = kViewSize / 2.0f;
static const CGFloat kRecognitionWidth = 75.0f;
static const CGFloat kRecognitionHeight = 120.0f;

static struct DockAnimation DockAnimation = {
  .showing = {
    .duration = 1.2f,
    .damping = 0.8f,
    .velocity = 8.0f
  },
  .hiding = {
    .duration = 0.9f,
    .damping = 0.8f,
    .velocity = 5.0f
  },
  .selected = {
    .duration = 1.4f,
    .scaleUp = 1.2f,
    .scaleUpDuration = 0.3f,
    .scaleDown = 0.9f,
    .scaleDownDuration = 0.3f
  }
};

@interface SLDockView () <UIGestureRecognizerDelegate>
{
  UIWindow *_window;
  NSArray *_navigationItems;

  NSArray *_navigationViews;
  UILongPressGestureRecognizer *_revealGestureRecognizer;

  SLDockState _state;
  NSUInteger _selectedIndex;

  UIColor *_defaultBackgroundColor;
  UIColor *_selectedColor;

  id<SLDockDelegate> __weak _delegate;
  BOOL _delegateRespondsToWillShow;
  BOOL _delegateRespondsToDidShow;
  BOOL _delegateRespondsToWillHide;
  BOOL _delegateRespondsToDidHide;
}
@end

@implementation SLDockView

#pragma mark -
#pragma mark NSObject

- (id)initWithWindow:(UIWindow *)window navigationItems:(NSArray *)items
{
  if ((self = [super init])) {
    _navigationItems = [items copy];
    _window = window;
    _selectedIndex = NSNotFound;
    _defaultBackgroundColor = [UIColor blackColor];
    _selectedColor = [UIColor greenColor];
  }
  return self;
}

- (void)dealloc
{
  if (SLDockStateDisabled != _state) {
    [_window removeGestureRecognizer:_revealGestureRecognizer];
  }
}

#pragma mark -
#pragma mark Public API

- (id<SLDockDelegate>)delegate
{
  return _delegate;
}

- (void)setDelegate:(id<SLDockDelegate>)delegate
{
  if (_delegate != delegate) {
    _delegate = delegate;
    _delegateRespondsToWillShow = [_delegate respondsToSelector:@selector(willShowDockView:)];
    _delegateRespondsToDidShow = [_delegate respondsToSelector:@selector(didShowDockView:)];
    _delegateRespondsToWillHide = [_delegate respondsToSelector:@selector(willHideDockView:)];
    _delegateRespondsToDidHide = [_delegate respondsToSelector:@selector(didHideDockView:)];
  }
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

#pragma mark -
#pragma mark State Machine

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
      } else {
        if (_delegateRespondsToDidHide) {
          [_delegate didHideDockView:self];
        }
      }
      break;
    case SLDockStateShowing:
    {
      if (_delegateRespondsToWillShow) {
        [_delegate willShowDockView:self];
      }
      [UIView animateWithDuration:DockAnimation.showing.duration
                            delay:0
           usingSpringWithDamping:DockAnimation.showing.damping
            initialSpringVelocity:DockAnimation.showing.velocity
                          options:UIViewAnimationOptionCurveEaseInOut
                       animations:^{
                         [self->_navigationViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
                           BOOL even = idx%2==0;
                           CGFloat offset = idx==0 ? kMaxOffsetX : kMaxOffsetX - (kMaxOffsetX/2.0f)*(idx - (even ? 1 : 0));
                           view.center = CGPointMake(kViewSize+offset, view.center.y);
                         }];
                       }
                       completion:^(BOOL finished){
                         [self transitionToState:SLDockStateVisible];
                       }];
    }
      break;
    case SLDockStateVisible:
    {
      if (_delegateRespondsToDidShow) {
        [_delegate didShowDockView:self];
      }
    }
      break;
    case SLDockStateHiding:
    {
      if (_delegateRespondsToWillHide) {
        [_delegate willHideDockView:self];
      }
      [UIView animateWithDuration:DockAnimation.hiding.duration
                            delay:0
           usingSpringWithDamping:DockAnimation.hiding.damping
            initialSpringVelocity:DockAnimation.hiding.velocity
                          options:UIViewAnimationOptionCurveEaseInOut
                       animations:^{
                         [self->_navigationViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
                           view.center = CGPointMake(-kViewSize, view.center.y);
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
      id<SLDockItem> selectedItem = (id<SLDockItem>)[_navigationItems objectAtIndex:_selectedIndex];
      [self->_delegate dockView:self didSelectItem:selectedItem];
      if (_delegateRespondsToWillHide) {
        [_delegate willHideDockView:self];
      }

      UIView *selectedView = (UIView *)[_navigationViews objectAtIndex:_selectedIndex];
      UIColor *colorToRestore = selectedView.backgroundColor;
      [UIView animateKeyframesWithDuration:DockAnimation.selected.duration
                                     delay:0.0
                                   options:UIViewKeyframeAnimationOptionCalculationModeCubic
                                animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:DockAnimation.selected.scaleUpDuration animations:^{
                                    selectedView.transform = CGAffineTransformScale(CGAffineTransformIdentity, DockAnimation.selected.scaleUp, DockAnimation.selected.scaleUp);
                                    [selectedView setBackgroundColor:self->_selectedColor];
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:DockAnimation.selected.scaleUpDuration relativeDuration:DockAnimation.selected.scaleDownDuration animations:^{
                                    selectedView.transform = CGAffineTransformScale(CGAffineTransformIdentity, DockAnimation.selected.scaleDown, DockAnimation.selected.scaleDown);
                                  }];
                                  CGFloat hideStart = DockAnimation.selected.scaleUpDuration + DockAnimation.selected.scaleDownDuration;
                                  CGFloat hideDuration = 1.0f - hideStart;
                                  [UIView addKeyframeWithRelativeStartTime:hideStart relativeDuration:hideDuration animations:^{
                                    selectedView.transform = CGAffineTransformIdentity;
                                    [self->_navigationViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
                                      view.center = CGPointMake(-kViewSize, view.center.y);
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

#pragma mark -
#pragma mark Lazy Construction

- (NSArray *)constructNavigationViewsWithItems:(NSArray *)items
{
  CGRect navFrame = CGRectZero;
  NSMutableArray *navViews = [NSMutableArray array];
  for (NSInteger i=0; i < (NSInteger)[items count]; i++) {
    navFrame.size = CGSizeMake(kViewSize, kViewSize);
    UIView *navView = [[UIView alloc] initWithFrame:navFrame];
    BOOL even = i%2==0;
    CGFloat offset = i==0 ? 0 : kItemSpacingY * ( (i+1)*(even?-1:1) + (even?1:0) );
    navView.center = CGPointMake(-kViewSize, _window.center.y+kExtraOffsetY+offset);
    [navView setBackgroundColor:_defaultBackgroundColor];
    navView.layer.cornerRadius = kViewSize/2.0f;
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

#pragma mark -
#pragma mark Handle Gesture

- (void)didLongPress
{
  if (_revealGestureRecognizer.state == UIGestureRecognizerStateBegan) {
    [self transitionToState:SLDockStateShowing];
  } else if (_revealGestureRecognizer.state == UIGestureRecognizerStateEnded) {
    CGPoint location = [_revealGestureRecognizer locationInView:_window];
    NSUInteger selectedIndex = [_navigationViews indexOfObjectPassingTest:^BOOL(UIView *view, NSUInteger idx, BOOL *stop) {
      return CGRectContainsPoint(view.frame, location) ? YES : NO; // CGRectContainsPoint -> bool (not BOOL)
    }];
    if (selectedIndex != NSNotFound) {
      _selectedIndex = selectedIndex;
      [self transitionToState:SLDockStateSelected];
    } else {
      [self transitionToState:SLDockStateHiding];
    }
  }
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
  if (self.revealGestureRecognizer != gestureRecognizer) { return NO; }
  CGPoint location = [gestureRecognizer locationInView:_window];
  return location.x < kRecognitionWidth && fabsf(location.y - _window.frame.size.height/2) < kRecognitionHeight;
}

@end
