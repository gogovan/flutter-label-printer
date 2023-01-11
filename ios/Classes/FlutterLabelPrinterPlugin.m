#import "FlutterLabelPrinterPlugin.h"
#if __has_include(<flutter_label_printer/flutter_label_printer-Swift.h>)
#import <flutter_label_printer/flutter_label_printer-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_label_printer-Swift.h"
#endif

@implementation FlutterLabelPrinterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterLabelPrinterPlugin registerWithRegistrar:registrar];
}
@end
