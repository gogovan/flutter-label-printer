import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter_label_printer/flutter_label_printer_platform_interface.dart';
import 'package:flutter_label_printer/printer/hanin_cpcl_classes.dart';
import 'package:flutter_label_printer/printer/hanin_tspl_classes.dart';

/// An implementation of [FlutterLabelPrinterPlatform] that uses method channels.
class MethodChannelFlutterLabelPrinter extends FlutterLabelPrinterPlatform {
  MethodChannelFlutterLabelPrinter()
      : methodChannel = const MethodChannel(
          'hk.gogovan.label_printer.flutter_label_printer',
        ),
        scanBluetoothEventChannel =
            const EventChannel('hk.gogovan.label_printer.bluetoothScan');

  @visibleForTesting
  MethodChannelFlutterLabelPrinter.mocked(
    this.methodChannel,
    this.scanBluetoothEventChannel,
  );

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final MethodChannel methodChannel;

  @visibleForTesting
  final EventChannel scanBluetoothEventChannel;

  @override
  Future<void> setLogLevel(int level) async {
    await methodChannel.invokeMethod<void>(
      'hk.gogovan.label_printer.setLogLevel',
      <String, dynamic>{'level': level},
    );
  }

  @override
  Stream<List<String>> searchBluetooth() =>
      scanBluetoothEventChannel.receiveBroadcastStream().map(
            (event) =>
                (event as List<dynamic>).map((e) => e.toString()).toList(),
          );

  @override
  Future<bool> stopSearchBluetooth() async {
    final result = await methodChannel
        .invokeMethod<bool>('hk.gogovan.label_printer.stopSearchBluetooth');

    return result ?? false;
  }

  @override
  Future<bool> connectHaninCPCL(String address) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.hanin.cpcl.connect',
      <String, dynamic>{
        'address': address,
      },
    );

    return result ?? false;
  }

  @override
  Future<bool> connectHaninTSPL(String address) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.hanin.tspl.connect',
      <String, dynamic>{
        'address': address,
      },
    );

    return result ?? false;
  }

  @override
  Future<bool> disconnectHaninTSPL() async {
    final result = await methodChannel
        .invokeMethod<bool>('hk.gogovan.label_printer.hanin.tspl.disconnect');

    return result ?? false;
  }

  @override
  Future<bool> disconnectHaninCPCL() async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.hanin.cpcl.disconnect',
    );

    return result ?? false;
  }

  @override
  Future<bool> printTestPageHaninTSPL() async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.hanin.tspl.printTestPage',
    );

    return result ?? false;
  }

  @override
  Future<bool> printTestPageHaninCPCL() async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.hanin.cpcl.printTestPage',
    );

    return result ?? false;
  }

  @override
  Future<bool> setPrintAreaHaninTSPL(
    HaninTSPLPrintAreaSizeParams params,
  ) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.hanin.tspl.setPrintAreaSize',
      <String, dynamic>{
        'width': params.width,
        'height': params.height,
      },
    );

    return result ?? false;
  }

  @override
  Future<bool> setPrintAreaHaninCPCL(
    HaninCPCLPrintAreaSizeParams params,
  ) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.hanin.cpcl.setPrintAreaSize',
      <String, dynamic>{
        'offset': params.offset,
        'height': params.height,
        'quantity': params.quantity,
      },
    );

    return result ?? false;
  }

  @override
  Future<bool> addTextHaninTSPL(HaninTSPLTextParams params) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.hanin.tspl.addText',
      <String, dynamic>{
        'rotate': params.rotate.rot,
        'font': params.font.code,
        'x': params.xPosition,
        'y': params.yPosition,
        'text': params.text,
        'alignment': params.alignment.code,
        'characterWidth': params.charWidth,
        'characterHeight': params.charHeight,
      },
    );

    return result ?? false;
  }

  @override
  Future<bool> addTextHaninCPCL(HaninCPCLTextParams params) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.hanin.cpcl.addText',
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
  Future<bool> printHaninTSPL() async {
    final result = await methodChannel
        .invokeMethod<bool>('hk.gogovan.label_printer.hanin.tspl.print');

    return result ?? false;
  }

  @override
  Future<bool> printHaninCPCL() async {
    final result = await methodChannel
        .invokeMethod<bool>('hk.gogovan.label_printer.hanin.cpcl.print');

    return result ?? false;
  }

  @override
  Future<bool> setPaperTypeHaninCPCL(HaninCPCLPaperType type) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.hanin.cpcl.setPaperType',
      <String, dynamic>{
        'paperType': type.code,
      },
    );

    return result ?? false;
  }

  @override
  Future<bool> setBoldHaninCPCL(int size) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.hanin.cpcl.setBold',
      <String, dynamic>{
        'size': size,
      },
    );

    return result ?? false;
  }

  @override
  Future<bool> setBoldHaninTSPL(int size) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.hanin.tspl.setBold',
      <String, dynamic>{
        'size': size,
      },
    );

    return result ?? false;
  }

  @override
  Future<bool> setHaninCPCLTextSize(int width, int height) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.hanin.cpcl.setTextSize',
      <String, dynamic>{
        'width': width,
        'height': height,
      },
    );

    return result ?? false;
  }

  @override
  Future<int> getStatusHaninTSPL() async {
    final result = await methodChannel
        .invokeMethod<int>('hk.gogovan.label_printer.hanin.tspl.getStatus');

    return result ?? -1;
  }

  @override
  Future<int> getStatusHaninCPCL() async {
    final result = await methodChannel
        .invokeMethod<int>('hk.gogovan.label_printer.hanin.cpcl.getStatus');

    return result ?? -1;
  }

  @override
  Future<bool> addSpaceHaninTSPL(int dot) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.hanin.tspl.space',
      <String, dynamic>{
        'mm': dot,
      },
    );

    return result ?? false;
  }

  @override
  Future<bool> addSpaceHaninCPCL(int dot) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.hanin.cpcl.space',
      <String, dynamic>{
        'dot': dot,
      },
    );

    return result ?? false;
  }

  @override
  Future<bool> setPageWidthHaninCPCL(int width) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.hanin.cpcl.setPageWidth',
      <String, dynamic>{
        'width': width,
      },
    );

    return result ?? false;
  }

  @override
  Future<bool> setAlignHaninCPCL(HaninCPCLTextAlign align) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.hanin.cpcl.setAlign',
      <String, dynamic>{
        'align': align.code,
      },
    );

    return result ?? false;
  }

  @override
  Future<bool> addBarcodeHaninTSPL(HaninTSPLBarcodeParams params) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.hanin.tspl.addBarcode',
      <String, dynamic>{
        'x': params.xPosition,
        'y': params.yPosition,
        'type': params.barcodeType.code,
        'height': params.height,
        'barLineWidth': params.barLineWidth,
        'showData': params.showData,
        'rotate': params.rotate.rot,
        'data': params.data,
      },
    );

    return result ?? false;
  }

  @override
  Future<bool> addBarcodeHaninCPCL(HaninCPCLBarcodeParams params) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.hanin.cpcl.addBarcode',
      <String, dynamic>{
        'orientation': params.orientation.code,
        'type': params.type.code,
        'width': params.barWidthUnit,
        'ratio': params.ratio.code,
        'height': params.height,
        'x': params.xPosition,
        'y': params.yPosition,
        'data': params.data,
        'showData': params.dataTextParams != null,
        'dataFont': params.dataTextParams?.font.code,
        'dataTextSize': params.dataTextParams?.size,
        'dataTextOffset': params.dataTextParams?.offset,
      },
    );

    return result ?? false;
  }

  @override
  Future<bool> addQRCodeHaninTSPL(HaninTSPLQRCodeParams params) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.hanin.tspl.addQRCode',
      <String, dynamic>{
        'x': params.xPosition,
        'y': params.yPosition,
        'eccLevel': params.eccLevel.code,
        'unitSize': params.unitSize,
        'mode': params.mode.code,
        'rotate': params.rotate.rot,
        'data': params.data,
      },
    );

    return result ?? false;
  }

  @override
  Future<bool> addQRCodeHaninCPCL(HaninCPCLQRCodeParams params) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.hanin.cpcl.addQRCode',
      <String, dynamic>{
        'orientation': params.orientation.code,
        'x': params.xPosition,
        'y': params.yPosition,
        'model': params.model.code,
        'unitSize': params.unitSize,
        'data': params.data,
      },
    );

    return result ?? false;
  }

  @override
  Future<bool> addRectangleHaninTSPL(Rect rect, int strokeWidth) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.hanin.tspl.addRectangle',
      <String, dynamic>{
        'x0': rect.left.round(),
        'y0': rect.top.round(),
        'x1': rect.right.round(),
        'y1': rect.bottom.round(),
        'width': strokeWidth,
      },
    );

    return result ?? false;
  }

  @override
  Future<bool> addRectangleHaninCPCL(Rect rect, int strokeWidth) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.hanin.cpcl.addRectangle',
      <String, dynamic>{
        'x0': rect.left.round(),
        'y0': rect.top.round(),
        'x1': rect.right.round(),
        'y1': rect.bottom.round(),
        'width': strokeWidth,
      },
    );

    return result ?? false;
  }

  @override
  Future<bool> addLineHaninTSPL(Rect rect) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.hanin.tspl.addLine',
      <String, dynamic>{
        'x': rect.left.round(),
        'y': rect.top.round(),
        'width': rect.width.round(),
        'height': rect.height.round(),
      },
    );

    return result ?? false;
  }

  @override
  Future<bool> addLineHaninCPCL(Rect rect, int strokeWidth) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.hanin.cpcl.addLine',
      <String, dynamic>{
        'x0': rect.left.round(),
        'y0': rect.top.round(),
        'x1': rect.right.round(),
        'y1': rect.bottom.round(),
        'width': strokeWidth,
      },
    );

    return result ?? false;
  }

  @override
  Future<bool> addImageHaninTSPL(HaninTSPLImageParams params) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.hanin.tspl.addImage',
      <String, dynamic>{
        'imagePath': params.imagePath,
        'x': params.xPosition,
        'y': params.yPosition,
        'type': params.imageMode.code,
      },
    );

    return result ?? false;
  }

  @override
  Future<bool> addImageHaninCPCL(HaninCPCLImageParams params) async {
    final result = await methodChannel.invokeMethod<bool>(
      'hk.gogovan.label_printer.hanin.cpcl.addImage',
      <String, dynamic>{
        'imagePath': params.imagePath,
        'x': params.xPosition,
        'y': params.yPosition,
        'mode': params.mode.code,
        'compress': params.compress,
        'package': params.package,
      },
    );

    return result ?? false;
  }
}
