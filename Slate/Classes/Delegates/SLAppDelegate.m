//  Copyright (c) 2014 rokob. All rights reserved.

#import "SLAppDelegate.h"

#import "SLCreateNavigationController.h"
#import "SLDockView.h"

@interface SLAppDelegate ()
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

  _dock = [[SLDockView alloc] initWithWindow:self.window navigationItems:@[]];
  [_dock setEnabled:YES];

  [self.window setRootViewController:navController];

  [self.window makeKeyAndVisible];

  return YES;
}

@end
