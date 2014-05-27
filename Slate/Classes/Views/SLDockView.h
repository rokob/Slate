//  Copyright (c) 2014 rokob. All rights reserved.

@import UIKit;

@protocol SLDockItem;

@interface SLDockView : NSObject

- (instancetype)initWithWindow:(UIWindow *)window navigationItems:(NSArray *)items;

- (void)setEnabled:(BOOL)enabled;

@property (nonatomic, readonly, strong) UILongPressGestureRecognizer *revealGestureRecognizer;

@end


@protocol SLDockItem <NSObject>

@property (nonatomic, readonly, strong) NSString *title;

@end
