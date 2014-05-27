//  Copyright (c) 2014 rokob. All rights reserved.

#ifndef _SL_DOCK_VIEW_INTERNAL_H_
#define _SL_DOCK_VIEW_INTERNAL_H_

typedef NS_ENUM(NSUInteger, SLDockState) {
  SLDockStateDisabled = 0,
  SLDockStateHidden,
  SLDockStateShowing,
  SLDockStateVisible,
  SLDockStateSelected,
  SLDockStateHiding
};

struct DockAnimation {
  struct Showing {
    CGFloat duration;
    CGFloat damping;
    CGFloat velocity;
  } showing;
  struct Hiding {
    CGFloat duration;
    CGFloat damping;
    CGFloat velocity;
  } hiding;
  struct Selected {
    CGFloat duration;
    CGFloat scaleUp;
    CGFloat scaleUpDuration;
    CGFloat scaleDown;
    CGFloat scaleDownDuration;
  } selected;
};

#endif // _SL_DOCK_VIEW_INTERNAL_H_
