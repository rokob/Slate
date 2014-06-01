//  Copyright (c) 2014 rokob. All rights reserved.

#import "SLDockViewButton.h"

#import "SLDockDelegate.h"
#import "SLDockItem.h"
#import "SLDockViewDraggableButton.h"
#import "SLDockWindow.h"

#import <Pop/POP.h>

static const CGFloat kViewSize = 50.0f;
static const CGFloat kExtraOffsetY = 10.0f;
//static const CGFloat kSpacingY = 5.0f;
//static const CGFloat kItemSpacingY = (kViewSize + kSpacingY) / 2.0f;
//static const CGFloat kMaxOffsetX = kViewSize / 2.0f;

@interface SLDockViewButton () <SLDockViewDraggableButtonDelegate>
{
  UIWindow *_window;
  NSArray *_navigationItems;

  NSArray *_navigationViews;
  SLDockViewDraggableButton *_button;
  CGPoint _buttonHome;

  UISwipeGestureRecognizer *_swipeUpRecognizer;
  UISwipeGestureRecognizer *_swipeDownRecognizer;

  NSUInteger _selectedIndex;

  SLDockContext *_context;
  BOOL _left;
  BOOL _bottom;
  CGPoint _shift;
}
@end

@implementation SLDockViewButton

@synthesize delegate = _delegate;

- (id)initWithWindow:(UIWindow *)window navigationItems:(NSArray *)items context:(SLDockContext *)context
{
  if ((self = [super init])) {
    _window = window;
    _navigationItems = [items copy];
    _context = context;

    _selectedIndex = NSNotFound;

    _left = context.location & SLDockLocationLeft;
    _bottom = context.location & SLDockLocationBottom;
    if ((_context.location & SLDockLocationLeft) == 0) {
      _shift.x = _window.frame.size.width;
    }
    if (_context.location & SLDockLocationBottom) {
      _shift.y = _window.frame.size.height;
    }

    _swipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeUpWithVelocity:)];
    _swipeDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeDownWithVelocity:)];
    _swipeUpRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    _swipeDownRecognizer.direction = UISwipeGestureRecognizerDirectionDown;

    [self constructButton];
  }
  return self;
}

#pragma mark -
#pragma mark State Machine

- (void)didTransitionToState:(SLDockState)newState fromState:(SLDockState)oldState
{
  switch (newState) {
    case SLDockStateDisabled:
      break;
    case SLDockStateHidden:
      if (oldState == SLDockStateDisabled) {
        _navigationViews = [self constructNavigationViewsWithItems:_navigationItems];
        //[_window addGestureRecognizer:_swipeUpRecognizer];
        //[_window addGestureRecognizer:_swipeDownRecognizer];
      }
      break;
    case SLDockStateShowing:
      break;
    case SLDockStateVisible:
      break;
    case SLDockStateSelected:
      break;
    case SLDockStateHiding:
      break;
  }
}

#pragma mark -
#pragma mark Lazy Construction

- (NSArray *)constructNavigationViewsWithItems:(NSArray *)items
{
  CGRect navFrame = CGRectZero;
  NSMutableArray *navViews = [NSMutableArray array];
  CGFloat y = _bottom ? _shift.y : 0;
  for (NSInteger i=0; i < (NSInteger)[items count]; i++) {
    navFrame.size = CGSizeMake(kViewSize, kViewSize);
    UIView *navView = [[UIView alloc] initWithFrame:navFrame];
    y += (_bottom ? 1 : -1)*(kExtraOffsetY + kViewSize);
    CGFloat x = _left ? kViewSize : _shift.x-kViewSize;
    navView.center = CGPointMake(x, y+kViewSize);
    [navView setBackgroundColor:_context.backgroundColor];
    navView.layer.cornerRadius = kViewSize/2.0f;
    [navViews addObject:navView];
    if (i!=4) {
      [_window addSubview:navView];
    }
  }
  return [navViews copy];
}

- (void)constructButton
{
  _button = [[SLDockViewDraggableButton alloc] init];
  _button.backgroundColor = _context.backgroundColor;
  _button.frame = CGRectMake(0, 0, kViewSize, kViewSize);
  _button.layer.cornerRadius = kViewSize/2.0f;
  CGFloat width = _button.frame.size.width;
  CGFloat x = _left ? width : _shift.x - width;
  CGFloat height = _button.frame.size.height;
  CGFloat y = _bottom ? _shift.y - height : height;
  _button.center = CGPointMake(x, y);
  _buttonHome = _button.center;
  [(SLDockWindow *)_window configureWithButton:_button];
  _button.delegate = self;
  [_window addSubview:_button];
}

- (void)addAnimationToView:(UIView *)view target:(CGPoint)target velocity:(CGPoint)velocity
{
  POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
  animation.toValue = [NSValue valueWithCGPoint:target];
  animation.velocity = [NSValue valueWithCGPoint:velocity];
  animation.springBounciness = 9.0f;
  animation.springSpeed = 3.0f;
  [view.layer pop_addAnimation:animation forKey:@"spring"];
}

- (void)didSwipeUpWithVelocity:(CGPoint)velocity
{
  [self toggleViews:_navigationViews visible:YES velocity:velocity];
}

- (void)didSwipeDownWithVelocity:(CGPoint)velocity
{
  [self toggleViews:_navigationViews visible:NO velocity:velocity];
}

- (void)toggleViews:(NSArray *)views visible:(BOOL)visible velocity:(CGPoint)velocity
{
  CGFloat __block y = _bottom ? _shift.y : 0;
  CGFloat targetX = _left ? kViewSize : _shift.x - kViewSize;
  [views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
    POPSpringAnimation *animation = [view.layer pop_animationForKey:@"spring"];
    y += (visible ? 1 : -1)*(self->_bottom ? -1 : 1)*(kExtraOffsetY + kViewSize);
    CGPoint target = CGPointMake(targetX, y); // + (visible ? 1 : 0)*idx*idx*2.5f
    if (animation) {
      animation.toValue = [NSValue valueWithCGPoint:target];
      animation.velocity = [NSValue valueWithCGPoint:velocity];
    } else {
      [self addAnimationToView:view target:target velocity:velocity];
    }
    if (idx == 4) {
      POPSpringAnimation *buttonAnimation = [self->_button.layer pop_animationForKey:@"spring"];
      if (buttonAnimation) {
        buttonAnimation.toValue = [NSValue valueWithCGPoint:(visible ? target : self->_buttonHome)];
        buttonAnimation.velocity = [NSValue valueWithCGPoint:velocity];
      } else {
        if (visible) {
          [self addAnimationToView:self->_button target:target velocity:velocity];
        } else {
          [self addAnimationToView:self->_button target:self->_buttonHome velocity:velocity];
        }
      }
    }
  }];
}

- (void)moveMenuViews:(NSArray *)views withAnchorPoint:(CGPoint)point
{
  CGFloat y = point.y;
  CGFloat x = point.x;
  CGFloat spacing = (point.x - kViewSize) / (CGFloat)[views count];
  CGFloat targetX = _left ? kViewSize : _shift.x - kViewSize;
  BOOL first = YES;
  for (UIView *view in [views reverseObjectEnumerator]) {
    if (!first) {
      view.center = CGPointMake(MAX(targetX, x), y);
    } else {
      first = NO;
    }
    x -= spacing;
    y += (self->_bottom ? 1 : -1)*(kExtraOffsetY + kViewSize);
  }
}

#pragma mark -
#pragma mark SLDockViewDraggableButtonDelegate

- (void)draggableButtonDidBeginDragging:(SLDockViewDraggableButton *)button { }

- (void)draggableButton:(SLDockViewDraggableButton *)button didDragToPoint:(CGPoint)point
{
  [self moveMenuViews:_navigationViews withAnchorPoint:point];
}

- (void)draggableButton:(SLDockViewDraggableButton *)button didEndDraggingWithVelocity:(CGPoint)velocity
{
  if ((velocity.y < 0 && _bottom) || (velocity.y > 0 && !_bottom)) {
    [self didSwipeUpWithVelocity:velocity];
  } else {
    [self didSwipeDownWithVelocity:velocity];
  }
}

@end
