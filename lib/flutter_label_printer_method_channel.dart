import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter_label_printer/flutter_label_printer_platform_interface.dart';

/// An implementation of [FlutterLabelPrinterPlatform] that uses method channels.
class MethodChannelFlutterLabelPrinter extends FlutterLabelPrinterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel =
      const MethodChannel('com.gogovan/flutter_label_printer');

  final _scanBluetoothEventChannel =
      const EventChannel('com.gogovan/bluetoothScan');

  @override
  Stream<List<String>> searchHMA300L() =>
      _scanBluetoothEventChannel.receiveBroadcastStream().map(
            (event) =>
                (event as List<dynamic>).map((e) => e.toString()).toList(),
          );
}
