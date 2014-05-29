//  Copyright (c) 2014 rokob. All rights reserved.

@import Foundation;

@class SLDockView;
@protocol SLDockItem;

@protocol SLDockDelegate <NSObject>

- (void)dockView:(SLDockView *)dockView didSelectItem:(id<SLDockItem>)item;

@optional

- (void)willShowDockView:(SLDockView *)dockView;
- (void)didShowDockView:(SLDockView *)dockView;
- (void)willHideDockView:(SLDockView *)dockView;
- (void)didHideDockView:(SLDockView *)dockView;

@end
