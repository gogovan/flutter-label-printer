import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter_label_printer/flutter_label_printer_platform_interface.dart';

/// An implementation of [FlutterLabelPrinterPlatform] that uses method channels.
class MethodChannelFlutterLabelPrinter extends FlutterLabelPrinterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_label_printer');

  @override
  Future<List<String>> searchHMA300L() async {
    final result = await methodChannel.invokeMethod<List<dynamic>>('searchHMA300L');

    return result?.cast() ?? [];
  }

}
