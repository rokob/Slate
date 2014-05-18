//  Copyright (c) 2014 rokob. All rights reserved.

@import Foundation;

@interface SLKeys : NSObject

+ (instancetype)sharedKeys;

- (NSString *)secret;

@end
