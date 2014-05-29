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

@class SLDockContext;
@protocol SLDockItem;

@protocol SLDockViewConfigurationDelegate <NSObject>

- (void)transitionToState:(SLDockState)state;
- (void)didSelectItem:(id<SLDockItem>)item;
- (BOOL)dockIsVisible;

@end

@protocol SLDockViewConfiguration <NSObject>

- (instancetype)initWithWindow:(UIWindow *)window navigationItems:(NSArray *)items context:(SLDockContext *)context;
- (void)didTransitionToState:(SLDockState)newState fromState:(SLDockState)oldState;

@property (nonatomic, readwrite, weak) id<SLDockViewConfigurationDelegate> delegate;

@end

typedef NS_OPTIONS(NSUInteger, SLDockLocation) {
  SLDockLocationLeft = 1 << 0,
  SLDockLocationRight = 1 << 1,
  SLDockLocationTop = 1 << 2,
  SLDockLocationBottom = 1 << 3
};

@interface SLDockContext : NSObject

- (instancetype)initWithBackgroundColor:(UIColor *)backgroundColor
                          selectedColor:(UIColor *)selectedColor
                        maxDisplayCount:(NSInteger)maxDisplayCount
                               location:(SLDockLocation)location;

@property (nonatomic, readonly, strong) UIColor *backgroundColor;
@property (nonatomic, readonly, strong) UIColor *selectedColor;
@property (nonatomic, readonly, assign) NSInteger maxDisplayCount;
@property (nonatomic, readonly, assign) SLDockLocation location;

+ (instancetype)defaultLeftContext;
+ (instancetype)defaultLeftBottomContext;
+ (instancetype)defaultLeftTopContext;

+ (instancetype)defaultRightContext;
+ (instancetype)defaultRightBottomContext;
+ (instancetype)defaultRightTopContext;

@end
