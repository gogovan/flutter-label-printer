import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter_label_printer/flutter_label_printer_platform_interface.dart';
import 'package:flutter_label_printer/printer/hm_a300l_classes.dart';

/// An implementation of [FlutterLabelPrinterPlatform] that uses method channels.
class MethodChannelFlutterLabelPrinter extends FlutterLabelPrinterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel =
      const MethodChannel('hk.gogovan.label_printer.flutter_label_printer');

  final _scanBluetoothEventChannel =
      const EventChannel('hk.gogovan.label_printer.bluetoothScan');

  @override
  Stream<List<String>> searchHMA300L() =>
      _scanBluetoothEventChannel.receiveBroadcastStream().map(
            (event) =>
                (event as List<dynamic>).map((e) => e.toString()).toList(),
          );

  @override
  Future<bool> stopSearchHMA300L() async {
    final result =
        await methodChannel.invokeMethod<bool>('hk.gogovan.label_printer.stopSearchHMA300L');

    return result ?? false;
  }

  @override
  Future<bool> connectHMA300L(String address) async {
    final result = await methodChannel
        .invokeMethod<bool>('hk.gogovan.label_printer.connectHMA300L', <String, dynamic>{
      'address': address,
    });

    return result ?? false;
  }

  @override
  Future<bool> disconnectHMA300L() async {
    final result =
        await methodChannel.invokeMethod<bool>('hk.gogovan.label_printer.disconnectHMA300L');

    return result ?? false;
  }

  @override
  Future<bool> printTestPageHMA300L() async {
    final result = await methodChannel.invokeMethod<bool>('hk.gogovan.label_printer.printTestPageHMA300L');

    return result ?? false;
  }

  @override
  Future<bool> setPrintAreaSizeHMA300L(
    PrintAreaSizeParams params,
  ) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.setPrintAreaSizeHMA300L',
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
      'hk.gogovan.label_printer.addText',
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
    final result = await methodChannel.invokeMethod<bool>('hk.gogovan.label_printer.print');

    return result ?? false;
  }

  @override
  Future<bool> setPaperType(PaperType type) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.setPaperType',
      <String, dynamic> {
        'paperType': type.code,
      },
    );

    return result ?? false;
  }

  @override
  Future<bool> setBold(int size) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.setBold',
      <String, dynamic> {
        'size': size,
      },
    );

    return result ?? false;
  }

  @override
  Future<bool> setTextSize(int width, int height) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.setTextSize',
      <String, dynamic> {
        'width': width,
        'height': height,
      },
    );

    return result ?? false;
  }
}
