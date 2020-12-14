#import "AdnetQqPlugin.h"
#if __has_include(<adnet_qq/adnet_qq-Swift.h>)
#import <adnet_qq/adnet_qq-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "adnet_qq-Swift.h"
#endif

@implementation AdnetQqPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAdnetQqPlugin registerWithRegistrar:registrar];
}
@end
