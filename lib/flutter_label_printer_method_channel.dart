import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter_label_printer/flutter_label_printer_platform_interface.dart';
import 'package:flutter_label_printer/printer/hm_a300l_classes.dart';

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

  @override
  Future<bool> stopSearchHMA300L() async {
    final result =
        await methodChannel.invokeMethod<bool>('com.gogovan/stopSearchHMA300L');

    return result ?? false;
  }

  @override
  Future<bool> connectHMA300L(String address) async {
    final result = await methodChannel
        .invokeMethod<bool>('com.gogovan/connectHMA300L', <String, dynamic>{
      'address': address,
    });

    return result ?? false;
  }

  @override
  Future<bool> disconnectHMA300L() async {
    final result =
        await methodChannel.invokeMethod<bool>('com.gogovan/disconnectHMA300L');

    return result ?? false;
  }

  @override
  Future<bool> printTestPageHMA300L() async {
    final result = await methodChannel.invokeMethod<bool>('com.gogovan/printTestPageHMA300L');

    return result ?? false;
  }

  @override
  Future<bool> setPrintAreaSizeHMA300L(
    PrintAreaSizeParams params,
  ) async {
    final result = await methodChannel.invokeMethod<bool>(
      'com.gogovan/setPrintAreaSizeHMA300L',
      <String, dynamic>{
        'offset': params.offset,
        'horizontalRes': params.horizontalRes.res,
        'verticalRes': params.verticalRes.res,
        'height': params.height,
        'quantity': params.quantity,
      },
    );

    return result ?? false;
  }

  @override
  Future<bool> addText(TextParams params) async {
    final result = await methodChannel.invokeMethod<bool>(
      'com.gogovan/addText',
      <String, dynamic>{
        'rotate': params.rotate.rot,
        'font': params.font.code,
        'x': params.x,
        'y': params.y,
        'text': params.text,
      },
    );

    return result ?? false;
  }
}
