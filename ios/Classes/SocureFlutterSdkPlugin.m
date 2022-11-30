#import "SocureFlutterSdkPlugin.h"
#if __has_include(<socure_flutter_sdk/socure_flutter_sdk-Swift.h>)
#import <socure_flutter_sdk/socure_flutter_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
//#import "socure_flutter_sdk-Swift.h"
#endif

@implementation SocureFlutterSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SocureFlutterSdkPlugin registerWithRegistrar:registrar];
}
@end
