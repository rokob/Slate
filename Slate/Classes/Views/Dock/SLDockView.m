//  Copyright (c) 2014 rokob. All rights reserved.

#import "SLDockView.h"

#import "SLDockViewConfiguration.h"
#import "SLDockViewLongPress.h"

@interface SLDockView () <SLDockViewConfigurationDelegate>
{
  id<SLDockDelegate> __weak _delegate;
  id<SLDockViewConfiguration> _configuration;

  BOOL _delegateRespondsToWillShow;
  BOOL _delegateRespondsToDidShow;
  BOOL _delegateRespondsToWillHide;
  BOOL _delegateRespondsToDidHide;

  SLDockState _state;
}
@end

@implementation SLDockView

#pragma mark -
#pragma mark NSObject

- (id)initWithWindow:(UIWindow *)window navigationItems:(NSArray *)items dockStyle:(SLDockStyle)dockStyle
{
  self = [super init];
  if (!self) {
    return nil;
  }

  switch (dockStyle) {
    case SLDockStyleLeftLongPress:
      _configuration = [[SLDockViewLongPress alloc] initWithWindow:window navigationItems:items context:[SLDockContext defaultLeftContext]];
      break;
    case SLDockStyleLowerLeftButton:
    case SLDockStyleLowerRightButton:
      break;
    case SLDockStyleRightLongPress:
      _configuration = [[SLDockViewLongPress alloc] initWithWindow:window navigationItems:items context:[SLDockContext defaultRightContext]];
      break;
  }
  [_configuration setDelegate:self];

  return self;
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
      [_configuration didTransitionToState:newState fromState:oldState];
      break;
    case SLDockStateHidden:
      if (oldState != SLDockStateDisabled) {
        if (_delegateRespondsToDidHide) {
          [_delegate didHideDockView:self];
        }
      }
      [_configuration didTransitionToState:newState fromState:oldState];
      break;
    case SLDockStateShowing:
    {
      if (oldState == SLDockStateVisible) {
        _state = SLDockStateVisible;
        return;
      }

      if (_delegateRespondsToWillShow) {
        [_delegate willShowDockView:self];
      }
      [_configuration didTransitionToState:newState fromState:oldState];
    }
      break;
    case SLDockStateVisible:
    {
      if (_delegateRespondsToDidShow) {
        [_delegate didShowDockView:self];
      }
      [_configuration didTransitionToState:newState fromState:oldState];
    }
      break;
    case SLDockStateHiding:
    {
      if (_delegateRespondsToWillHide) {
        [_delegate willHideDockView:self];
      }
      [_configuration didTransitionToState:newState fromState:oldState];
    }
      break;
    case SLDockStateSelected:
    {
      if (_delegateRespondsToWillHide) {
        [_delegate willHideDockView:self];
      }

      [_configuration didTransitionToState:newState fromState:oldState];
    }
      break;
  }
}

#pragma mark -
#pragma mark SLDockConfigurationDelegate

- (void)didSelectItem:(id<SLDockItem>)item
{
  [_delegate dockView:self didSelectItem:item];
}

- (BOOL)dockIsVisible
{
  return _state == SLDockStateVisible;
}

@end
