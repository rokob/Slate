//  Copyright (c) 2014 rokob. All rights reserved.

#import "SLDockViewLongPress.h"
#import "SLDockViewLongPressInternal.h"

#import "SLDockDelegate.h"

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

@interface SLDockViewLongPress () <UIGestureRecognizerDelegate>
{
  UIWindow *_window;
  NSArray *_navigationItems;

  NSArray *_navigationViews;
  UILongPressGestureRecognizer *_revealGestureRecognizer;
  UITapGestureRecognizer *_tapGestureRecgonizer;

  NSUInteger _selectedIndex;

  SLDockContext *_context;
  BOOL _left;
  CGFloat _shift;
}
@end

@implementation SLDockViewLongPress

@synthesize delegate = _delegate;

#pragma mark -
#pragma mark NSObject

- (id)initWithWindow:(UIWindow *)window navigationItems:(NSArray *)items context:(SLDockContext *)context
{
  if ((self = [super init])) {
    _navigationItems = [items copy];
    _window = window;
    _selectedIndex = NSNotFound;
    _context = context;
    _left = _context.location & SLDockLocationLeft;
    if ((_context.location & SLDockLocationLeft) == 0) {
      _shift = _window.frame.size.width;
    }
  }
  return self;
}

- (void)dealloc
{
  [_window removeGestureRecognizer:_revealGestureRecognizer];
  [_window removeGestureRecognizer:_tapGestureRecgonizer];
}

#pragma mark -
#pragma mark State Machine

- (void)didTransitionToState:(SLDockState)newState fromState:(SLDockState)oldState
{
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
      [UIView animateWithDuration:DockAnimation.showing.duration
                            delay:0
           usingSpringWithDamping:DockAnimation.showing.damping
            initialSpringVelocity:DockAnimation.showing.velocity
                          options:UIViewAnimationOptionCurveEaseInOut
                       animations:^{
                         [self->_navigationViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
                           BOOL even = idx%2==0;
                           CGFloat offset = idx==0 ? kMaxOffsetX : kMaxOffsetX - (kMaxOffsetX/2.0f)*(idx - (even ? 1 : 0));
                           CGFloat x = self->_left ? kViewSize+offset : self->_shift - (kViewSize+offset);
                           view.center = CGPointMake(x, view.center.y);
                         }];
                       }
                       completion:^(BOOL finished){
                         [self->_delegate transitionToState:SLDockStateVisible];
                       }];
    }
      break;
    case SLDockStateVisible:
      [_window addGestureRecognizer:self.tapGestureRecognizer];
      break;
    case SLDockStateHiding:
    {
      [_window removeGestureRecognizer:self.tapGestureRecognizer];
      [UIView animateWithDuration:DockAnimation.hiding.duration
                            delay:0
           usingSpringWithDamping:DockAnimation.hiding.damping
            initialSpringVelocity:DockAnimation.hiding.velocity
                          options:UIViewAnimationOptionCurveEaseInOut
                       animations:^{
                         [self->_navigationViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
                           CGFloat x = self->_left ? -kViewSize : self->_shift+kViewSize;
                           view.center = CGPointMake(x, view.center.y);
                         }];
                       }
                       completion:^(BOOL finished){
                         [self->_navigationViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
                           [view setBackgroundColor:self->_context.backgroundColor];
                         }];
                         [self->_delegate transitionToState:SLDockStateHidden];
                       }];
    }
      break;
    case SLDockStateSelected:
    {
      id<SLDockItem> selectedItem = (id<SLDockItem>)[_navigationItems objectAtIndex:_selectedIndex];
      [self->_delegate didSelectItem:selectedItem];
      [_window removeGestureRecognizer:self.tapGestureRecognizer];

      UIView *selectedView = (UIView *)[_navigationViews objectAtIndex:_selectedIndex];
      UIColor *colorToRestore = selectedView.backgroundColor;
      [UIView animateKeyframesWithDuration:DockAnimation.selected.duration
                                     delay:0.0
                                   options:UIViewKeyframeAnimationOptionCalculationModeCubic
                                animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:DockAnimation.selected.scaleUpDuration animations:^{
                                    selectedView.transform = CGAffineTransformScale(CGAffineTransformIdentity, DockAnimation.selected.scaleUp, DockAnimation.selected.scaleUp);
                                    [selectedView setBackgroundColor:self->_context.selectedColor];
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:DockAnimation.selected.scaleUpDuration relativeDuration:DockAnimation.selected.scaleDownDuration animations:^{
                                    selectedView.transform = CGAffineTransformScale(CGAffineTransformIdentity, DockAnimation.selected.scaleDown, DockAnimation.selected.scaleDown);
                                  }];
                                  CGFloat hideStart = DockAnimation.selected.scaleUpDuration + DockAnimation.selected.scaleDownDuration;
                                  CGFloat hideDuration = 1.0f - hideStart;
                                  [UIView addKeyframeWithRelativeStartTime:hideStart relativeDuration:hideDuration animations:^{
                                    selectedView.transform = CGAffineTransformIdentity;
                                    [self->_navigationViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
                                      CGFloat x = self->_left ? -kViewSize : self->_shift+kViewSize;
                                      view.center = CGPointMake(x, view.center.y);
                                    }];
                                  }];
                                }
                                completion:^(BOOL finished) {
                                  [selectedView setBackgroundColor:colorToRestore];
                                  [self->_delegate transitionToState:SLDockStateHidden];
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
    CGFloat x = _left ? -kViewSize : _shift+kViewSize;
    navView.center = CGPointMake(x, _window.center.y+kExtraOffsetY+offset);
    [navView setBackgroundColor:_context.backgroundColor];
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

- (UITapGestureRecognizer *)tapGestureRecognizer
{
  if (!_tapGestureRecgonizer) {
    _tapGestureRecgonizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(didTap)];
    _tapGestureRecgonizer.delegate = self;
  }
  return _tapGestureRecgonizer;
}

#pragma mark -
#pragma mark Handle Gestures

- (void)didLongPress
{
  if (self.revealGestureRecognizer.state == UIGestureRecognizerStateBegan) {
    [_delegate transitionToState:SLDockStateShowing];
  } else if (self.revealGestureRecognizer.state == UIGestureRecognizerStateEnded) {
    CGPoint location = [self.revealGestureRecognizer locationInView:_window];
    [self handleActionAtLocation:location hideIfNotSelected:NO];
  }
}

- (void)didTap
{
  CGPoint location = [self.tapGestureRecognizer locationOfTouch:0 inView:_window];
  [self handleActionAtLocation:location hideIfNotSelected:YES];
}

- (void)handleActionAtLocation:(CGPoint)location hideIfNotSelected:(BOOL)shouldHide
{
  NSUInteger selectedIndex = [_navigationViews indexOfObjectPassingTest:^BOOL(UIView *view, NSUInteger idx, BOOL *stop) {
    return CGRectContainsPoint(view.frame, location) ? YES : NO; // CGRectContainsPoint -> bool (not BOOL)
  }];
  if (selectedIndex != NSNotFound) {
    _selectedIndex = selectedIndex;
    [_delegate transitionToState:SLDockStateSelected];
  } else if (shouldHide) {
    [_delegate transitionToState:SLDockStateHiding];
  }
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
  if (self.tapGestureRecognizer == gestureRecognizer) {
    return [_delegate dockIsVisible];
  }

  if (self.revealGestureRecognizer != gestureRecognizer) { return NO; }
  CGPoint location = [gestureRecognizer locationInView:_window];
  BOOL yHit = fabsf(location.y - _window.frame.size.height/2) < kRecognitionHeight;
  BOOL xHit = _left ? location.x < kRecognitionWidth : location.x > _shift - kRecognitionWidth;
  return xHit && yHit;
}

@end
