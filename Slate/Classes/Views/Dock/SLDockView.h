//  Copyright (c) 2014 rokob. All rights reserved.

@import UIKit;

#import "SLDockDelegate.h"

@protocol SLDockItem;

typedef NS_ENUM(NSUInteger, SLDockStyle) {
  SLDockStyleLeftLongPress,
  SLDockStyleRightLongPress,
  SLDockStyleLowerRightButton,
  SLDockStyleLowerLeftButton,
};

@interface SLDockView : NSObject

/**
 @param window The window to show the dock and where to place the gesture recognizer
 @param items An array of objects that conform to @protocol(SLDockItem)
 @param dockStyle One of the SLDockStyle values which determines the behaviour of
        the dock view
 */
- (instancetype)initWithWindow:(UIWindow *)window
               navigationItems:(NSArray *)items
                     dockStyle:(SLDockStyle)dockStyle;

/**
 The dock is initially disabled, so this must be set to YES before the receiver
 will do anything. The behaviour of this method is dependent on the dockStyle
 of the receiver.
 */
- (void)setEnabled:(BOOL)enabled;

@property (nonatomic, readwrite, weak) id<SLDockDelegate> delegate;

@end
