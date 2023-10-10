import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_label_printer/flutter_label_printer_method_channel.dart';
import 'package:flutter_label_printer/printer/hm_a300l_classes.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class FlutterLabelPrinterPlatform extends PlatformInterface {
  /// Constructs a FlutterLabelPrinterPlatform.
  FlutterLabelPrinterPlatform() : super(token: token);
  
  // ignore: no-object-declaration, needed, directly from Flutter template code.
  @visibleForTesting static final Object token = Object();

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
    PlatformInterface.verifyToken(instance, token);
    _instance = instance;
  }

  Stream<List<String>> searchHMA300L() {
    throw UnimplementedError('searchHMA300L() has not been implemented.');
  }

  Future<bool> stopSearchHMA300L() {
    throw UnimplementedError('stopSearchHMA300L() has not been implemented.');
  }

  Future<bool> connectHMA300L(String address) {
    throw UnimplementedError('connectHMA300L() has not been implemented.');
  }

  Future<bool> disconnectHMA300L() {
    throw UnimplementedError('disconnectHMA300L() has not been implemented.');
  }

  Future<bool> printTestPageHMA300L() {
    throw UnimplementedError(
      'printTestPageHMA300L() has not been implemented.',
    );
  }

  Future<void> setLogLevel(int level) {
    throw UnimplementedError(
      'setLogLevel() has not been implemented.',
    );
  }

  Future<bool> setPrintAreaSizeHMA300L(HMA300LPrintAreaSizeParams params) {
    throw UnimplementedError(
      'setPrintAreaSizeHMA300L() has not been implemented.',
    );
  }

  Future<bool> addTextHMA300L(HMA300LTextParams params) {
    throw UnimplementedError(
      'addTextHMA300L() has not been implemented.',
    );
  }

  Future<bool> printHMA300L() {
    throw UnimplementedError(
      'printHMA300L() has not been implemented.',
    );
  }

  Future<bool> setPaperTypeHMA300L(HMA300LPaperType type) {
    throw UnimplementedError(
      'setPaperTypeHMA300L() has not been implemented.',
    );
  }

  Future<bool> setBoldHMA300L(int size) {
    throw UnimplementedError(
      'setBoldHMA300L() has not been implemented.',
    );
  }

  Future<bool> setTextSizeHMA300L(int width, int height) {
    throw UnimplementedError(
      'setTextSizeHMA300L() has not been implemented.',
    );
  }

  Future<int> getStatusHMA300L() {
    throw UnimplementedError(
      'getStatusHMA300L() has not been implemented.',
    );
  }

  Future<bool> prefeedHMA300L(int dot) {
    throw UnimplementedError(
      'prefeedHMA300L() has not been implemented.',
    );
  }

  Future<bool> setPageWidthHMA300L(int width) {
    throw UnimplementedError(
      'setPageWidthHMA300L() has not been implemented.',
    );
  }

  Future<bool> setAlignHMA300L(int align) {
    throw UnimplementedError(
      'setAlignHMA300L() has not been implemented.',
    );
  }

  Future<bool> addBarcode(HMA300LBarcodeParams params) {
    throw UnimplementedError(
      'addBarcode() has not been implemented.',
    );
  }

  Future<bool> addQRCode(HMA300LQRCodeParams params) {
    throw UnimplementedError(
      'addQRCode() has not been implemented.',
    );
  }

  Future<bool> addRectangle(Rect rect, int strokeWidth) {
    throw UnimplementedError(
      'addRectangle() has not been implemented.',
    );
  }

  Future<bool> addLine(Rect rect, int strokeWidth) {
    throw UnimplementedError(
      'addLine() has not been implemented.',
    );
  }

  Future<bool> addImage(HMA300LPrintImageParams params) {
    throw UnimplementedError(
      'addImage() has not been implemented.',
    );
  }
}
