//  Copyright (c) 2014 rokob. All rights reserved.

#import "SLAppDelegate.h"

#import "SLCreateNavigationController.h"
#import "SLDockView.h"
#import "SLDockItem.h"

@interface SLAppDelegate () <SLDockDelegate>
{
  SLDockView *_dock;
}
@end

@implementation SLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.backgroundColor = [UIColor whiteColor];

  SLCreateNavigationController *navController = [[SLCreateNavigationController alloc] init];

  _dock = [[SLDockView alloc] initWithWindow:self.window
                             navigationItems:[self navigationItems]
                                   dockStyle:SLDockStyleRightLongPress];
  _dock.delegate = self;
  [_dock setEnabled:YES];

  [self.window setRootViewController:navController];

  [self.window makeKeyAndVisible];

  return YES;
}

#pragma mark -
#pragma mark SLDockDelegate

- (void)dockView:(SLDockView *)dockView didSelectItem:(id<SLDockItem>)item
{
  NSLog(@"SELECTED: %@", [item title]);
}

#pragma mark -
#pragma mark Configuration

- (NSArray *)navigationItems
{
  return @[
           [SLDockItem newWithTitle:@"A"]
         , [SLDockItem newWithTitle:@"B"]
         , [SLDockItem newWithTitle:@"C"]
         , [SLDockItem newWithTitle:@"D"]
         , [SLDockItem newWithTitle:@"E"]
          ];
}

@end
