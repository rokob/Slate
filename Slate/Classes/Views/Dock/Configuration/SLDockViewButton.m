//  Copyright (c) 2014 rokob. All rights reserved.

#import "SLDockViewButton.h"

#import "SLDockDelegate.h"
#import "SLDockItem.h"

#import <Pop/POP.h>

static const CGFloat kViewSize = 50.0f;
static const CGFloat kExtraOffsetY = 10.0f;
//static const CGFloat kSpacingY = 5.0f;
//static const CGFloat kItemSpacingY = (kViewSize + kSpacingY) / 2.0f;
//static const CGFloat kMaxOffsetX = kViewSize / 2.0f;

@interface SLDockViewButton ()
{
  UIWindow *_window;
  NSArray *_navigationItems;

  NSArray *_navigationViews;
  UIView *_button;

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

    _swipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeUp)];
    _swipeDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeDown)];
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
        [_window addGestureRecognizer:_swipeUpRecognizer];
        [_window addGestureRecognizer:_swipeDownRecognizer];
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
    [_window addSubview:navView];
  }
  return [navViews copy];
}

- (void)constructButton
{
  _button = [UIButton buttonWithType:UIButtonTypeSystem];
  _button.backgroundColor = _context.backgroundColor;
  _button.frame = CGRectMake(0, 0, kViewSize, kViewSize);
  _button.layer.cornerRadius = kViewSize/2.0f;
  CGFloat width = _button.frame.size.width;
  CGFloat x = _left ? width : _shift.x - width;
  CGFloat height = _button.frame.size.height;
  CGFloat y = _bottom ? _shift.y - height : height;
  _button.center = CGPointMake(x, y);
  [_window addSubview:_button];

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [self didSwipeUp];
  });
}

- (void)addAnimationToView:(UIView *)view target:(CGPoint)target
{
  POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
  animation.toValue = [NSValue valueWithCGPoint:target];
  animation.velocity = [NSValue valueWithCGPoint:CGPointMake(0.0f, 100.0f)];
  animation.springBounciness = 9.0f;
  animation.springSpeed = 3.0f;
  [view.layer pop_addAnimation:animation forKey:@"spring"];
}

- (void)didSwipeUp
{
  [self toggleViews:_navigationViews visible:YES];
}

- (void)didSwipeDown
{
  [self toggleViews:_navigationViews visible:NO];
}

- (void)toggleViews:(NSArray *)views visible:(BOOL)visible
{
  CGFloat __block y = _bottom ? _shift.y : 0;
  [views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
    POPSpringAnimation *animation = [view.layer pop_animationForKey:@"spring"];
    y += (visible ? 1 : -1)*(self->_bottom ? -1 : 1)*(kExtraOffsetY + kViewSize);
    CGPoint target = CGPointMake(view.layer.position.x, y); // + (visible ? 1 : 0)*idx*idx*2.5f
    if (animation) {
      animation.toValue = [NSValue valueWithCGPoint:target];
    } else {
      [self addAnimationToView:view target:target];
    }
  }];
}

@end
