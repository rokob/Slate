//  Copyright (c) 2014 rokob. All rights reserved.

@import Foundation;

typedef NS_ENUM(NSUInteger, SLDockState) {
  SLDockStateDisabled = 0,
  SLDockStateHidden,
  SLDockStateShowing,
  SLDockStateVisible,
  SLDockStateSelected,
  SLDockStateHiding
};

@protocol SLDockItem;

@protocol SLDockViewConfigurationDelegate <NSObject>

- (void)transitionToState:(SLDockState)state;
- (void)didSelectItem:(id<SLDockItem>)item;
- (BOOL)dockIsVisible;

@end

@protocol SLDockViewConfiguration <NSObject>

- (instancetype)initWithWindow:(UIWindow *)window navigationItems:(NSArray *)items;
- (void)didTransitionToState:(SLDockState)newState fromState:(SLDockState)oldState;

@property (nonatomic, readwrite, weak) id<SLDockViewConfigurationDelegate> delegate;

@end
