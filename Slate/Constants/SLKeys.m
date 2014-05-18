//  Copyright (c) 2014 rokob. All rights reserved.

#import "SLKeys.h"

static NSString * const kKeysConfigPlistFilename = @"slate-config";
static NSString * const kKeysConfigPlistExtension = @"plist";

static NSString * const kKeysConfigPlistSecret = @"secret";

@interface SLKeys ()
@property (nonatomic, readonly, copy) NSString *secret;
@end

@implementation SLKeys

+ (instancetype)sharedKeys
{
  static SLKeys *keys = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    keys = [[self alloc] init];
  });
  return keys;
}

- (id)init
{
  if ((self = [super init])) {
    NSString *path = [[NSBundle mainBundle] pathForResource:kKeysConfigPlistFilename ofType:kKeysConfigPlistExtension];
    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:path];

    _secret = [config objectForKey:kKeysConfigPlistSecret];
  }
  return self;
}

@end
