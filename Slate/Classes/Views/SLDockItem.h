//  Copyright (c) 2014 rokob. All rights reserved.

@import Foundation;

@protocol SLDockItem <NSObject>

@property (nonatomic, readonly, strong) NSString *title;

@end

@interface SLDockItem : NSObject <SLDockItem>

+ (instancetype)newWithTitle:(NSString *)title;

@end
