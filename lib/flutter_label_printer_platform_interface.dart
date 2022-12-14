import 'package:flutter_label_printer/flutter_label_printer_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class FlutterLabelPrinterPlatform extends PlatformInterface {
  /// Constructs a FlutterLabelPrinterPlatform.
  FlutterLabelPrinterPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterLabelPrinterPlatform _instance =
      MethodChannelFlutterLabelPrinter();

  /// The default instance of [FlutterLabelPrinterPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterLabelPrinter].
  static FlutterLabelPrinterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterLabelPrinterPlatform] when
  /// they register themselves.
  static set instance(FlutterLabelPrinterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
