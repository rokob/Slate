//  Copyright (c) 2014 rokob. All rights reserved.

@import UIKit;

@protocol SLDockViewDraggableButtonDelegate;

@interface SLDockViewDraggableButton : UIView

@property (nonatomic, readwrite, weak) id<SLDockViewDraggableButtonDelegate> delegate;

@end

@protocol SLDockViewDraggableButtonDelegate <NSObject>

- (void)draggableButtonDidBeginDragging:(SLDockViewDraggableButton *)button;
- (void)draggableButton:(SLDockViewDraggableButton *)button didDragToPoint:(CGPoint)point;
- (void)draggableButton:(SLDockViewDraggableButton *)button didEndDraggingWithVelocity:(CGPoint)velocity;

@end
