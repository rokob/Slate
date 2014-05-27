//  Copyright (c) 2014 rokob. All rights reserved.

@import UIKit;

@protocol SLDockItem;
@protocol SLDockDelegate;

@interface SLDockView : NSObject

/**
 @param window The window to show the dock and where to place the gesture recognizer
 @param items An array of objects that conform to @protocol(SLDockItem)
 */
- (instancetype)initWithWindow:(UIWindow *)window navigationItems:(NSArray *)items;

/**
 The dock is initially disabled, so this must be set to YES before the receiver
 will do anything. Setting this to YES has a side effect of adding a gesture 
 recognizer to the window passed into the designated initalizer.
 */
- (void)setEnabled:(BOOL)enabled;

@property (nonatomic, readwrite, weak) id<SLDockDelegate> delegate;

@end

@protocol SLDockDelegate <NSObject>

- (void)dockView:(SLDockView *)dockView didSelectItem:(id<SLDockItem>)item;

@optional

- (void)willShowDockView:(SLDockView *)dockView;
- (void)didShowDockView:(SLDockView *)dockView;
- (void)willHideDockView:(SLDockView *)dockView;
- (void)didHideDockView:(SLDockView *)dockView;

@end
