import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter_label_printer/flutter_label_printer_platform_interface.dart';
import 'package:flutter_label_printer/printer/hm_a300l_classes.dart';

/// An implementation of [FlutterLabelPrinterPlatform] that uses method channels.
class MethodChannelFlutterLabelPrinter extends FlutterLabelPrinterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel =
      const MethodChannel('hk.gogovan.flutter_label_printer');

  final _scanBluetoothEventChannel =
      const EventChannel('hk.gogovan.bluetoothScan');

  @override
  Stream<List<String>> searchHMA300L() =>
      _scanBluetoothEventChannel.receiveBroadcastStream().map(
            (event) =>
                (event as List<dynamic>).map((e) => e.toString()).toList(),
          );

  @override
  Future<bool> stopSearchHMA300L() async {
    final result =
        await methodChannel.invokeMethod<bool>('hk.gogovan.stopSearchHMA300L');

    return result ?? false;
  }

  @override
  Future<bool> connectHMA300L(String address) async {
    final result = await methodChannel
        .invokeMethod<bool>('hk.gogovan.connectHMA300L', <String, dynamic>{
      'address': address,
    });

    return result ?? false;
  }

  @override
  Future<bool> disconnectHMA300L() async {
    final result =
        await methodChannel.invokeMethod<bool>('hk.gogovan.disconnectHMA300L');

    return result ?? false;
  }

  @override
  Future<bool> printTestPageHMA300L() async {
    final result = await methodChannel.invokeMethod<bool>('hk.gogovan.printTestPageHMA300L');

    return result ?? false;
  }

  @override
  Future<bool> setPrintAreaSizeHMA300L(
    PrintAreaSizeParams params,
  ) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.setPrintAreaSizeHMA300L',
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
      'hk.gogovan.addText',
      <String, dynamic>{
        'rotate': params.rotate.rot,
        'font': params.font.code,
        'x': params.xPosition,
        'y': params.yPosition,
        'text': params.text,
      },
    );

    return result ?? false;
  }

  @override
  Future<bool> print() async {
    final result = await methodChannel.invokeMethod<bool>('hk.gogovan.print');

    return result ?? false;
  }

  @override
  Future<bool> setPaperType(PaperType type) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.setPaperType',
      <String, dynamic> {
        'paperType': type.code,
      },
    );

    return result ?? false;
  }

  @override
  Future<bool> setBold(int size) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.setBold',
      <String, dynamic> {
        'size': size,
      },
    );

    return result ?? false;
  }

  @override
  Future<bool> setTextSize(int width, int height) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.setTextSize',
      <String, dynamic> {
        'width': width,
        'height': height,
      },
    );

    return result ?? false;
  }
}
