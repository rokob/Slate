//  Copyright (c) 2014 rokob. All rights reserved.

#ifndef _SL_DOCK_VIEW_LONG_PRESS_INTERNAL_H_
#define _SL_DOCK_VIEW_LONG_PRESS_INTERNAL_H_

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

#endif // _SL_DOCK_VIEW_LONG_PRESS_INTERNAL_H_
