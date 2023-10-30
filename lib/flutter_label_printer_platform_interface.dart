import 'package:flutter/cupertino.dart';
import 'package:flutter_label_printer/flutter_label_printer_method_channel.dart';
import 'package:flutter_label_printer/printer/hanin_cpcl_classes.dart';
import 'package:flutter_label_printer/printer/hanin_tspl_classes.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class FlutterLabelPrinterPlatform extends PlatformInterface {
  /// Constructs a FlutterLabelPrinterPlatform.
  FlutterLabelPrinterPlatform() : super(token: token);

  @visibleForTesting
  // ignore: no-object-declaration, needed, directly from Flutter template code.
  static final Object token = Object();

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

  Future<void> setLogLevel(int level) {
    throw UnimplementedError(
      'setLogLevel() has not been implemented.',
    );
  }

  Stream<List<String>> searchBluetooth() {
    throw UnimplementedError('searchBluetooth() has not been implemented.');
  }

  Future<bool> stopSearchBluetooth() {
    throw UnimplementedError('stopSearchBluetooth() has not been implemented.');
  }

  Future<bool> connectHaninCPCL(String address) {
    throw UnimplementedError('connectHaninCPCL() has not been implemented.');
  }

  Future<bool> connectHaninTSPL(String address) {
    throw UnimplementedError('connectHaninTSPL() has not been implemented.');
  }

  Future<bool> disconnectHaninTSPL() {
    throw UnimplementedError('disconnectHaninTSPL() has not been implemented.');
  }

  Future<bool> disconnectHaninCPCL() {
    throw UnimplementedError('disconnectHaninCPCL() has not been implemented.');
  }

  Future<bool> clearHaninTSPL() {
    throw UnimplementedError('clearHaninTSPL() has not been implemented.');
  }

  Future<bool> printTestPageHaninTSPL() {
    throw UnimplementedError(
      'printTestPageHaninTSPL() has not been implemented.',
    );
  }

  Future<bool> printTestPageHaninCPCL() {
    throw UnimplementedError(
      'printTestPageHaninCPCL() has not been implemented.',
    );
  }

  Future<bool> setPrintAreaHaninTSPL(HaninTSPLPrintAreaSizeParams params) {
    throw UnimplementedError(
      'setPrintAreaHaninTSPL() has not been implemented.',
    );
  }

  Future<bool> setPrintAreaHaninCPCL(HaninCPCLPrintAreaSizeParams params) {
    throw UnimplementedError(
      'setPrintAreaHaninCPCL() has not been implemented.',
    );
  }

  Future<bool> addTextHaninTSPL(HaninTSPLTextParams params) {
    throw UnimplementedError(
      'addTextHaninTSPL() has not been implemented.',
    );
  }

  Future<bool> addTextHaninCPCL(HaninCPCLTextParams params) {
    throw UnimplementedError(
      'addTextHaninCPCL() has not been implemented.',
    );
  }

  Future<bool> printHaninTSPL() {
    throw UnimplementedError(
      'printHaninTSPL() has not been implemented.',
    );
  }

  Future<bool> printHaninCPCL() {
    throw UnimplementedError(
      'printHaninCPCL() has not been implemented.',
    );
  }

  Future<bool> setPaperTypeHaninCPCL(HaninCPCLPaperType type) {
    throw UnimplementedError(
      'setPaperTypeHaninCPCL() has not been implemented.',
    );
  }

  Future<bool> setBoldHaninCPCL(int size) {
    throw UnimplementedError(
      'setBoldHaninCPCL() has not been implemented.',
    );
  }

  Future<bool> setHaninCPCLTextSize(int width, int height) {
    throw UnimplementedError(
      'setHaninCPCLTextSize() has not been implemented.',
    );
  }

  Future<int> getStatusHaninTSPL() {
    throw UnimplementedError(
      'getStatusHaninTSPL() has not been implemented.',
    );
  }

  Future<int> getStatusHaninCPCL() {
    throw UnimplementedError(
      'getStatusHaninCPCL() has not been implemented.',
    );
  }

  Future<bool> addSpaceHaninTSPL(int dot) {
    throw UnimplementedError(
      'addSpaceHaninTSPL() has not been implemented.',
    );
  }

  Future<bool> addSpaceHaninCPCL(int dot) {
    throw UnimplementedError(
      'addSpaceHaninCPCL() has not been implemented.',
    );
  }

  Future<bool> setPageWidthHaninCPCL(int width) {
    throw UnimplementedError(
      'setPageWidthHaninCPCL() has not been implemented.',
    );
  }

  Future<bool> setAlignHaninCPCL(HaninCPCLTextAlign align) {
    throw UnimplementedError(
      'setAlignHaninCPCL() has not been implemented.',
    );
  }

  Future<bool> addBarcodeHaninTSPL(HaninTSPLBarcodeParams params) {
    throw UnimplementedError(
      'addBarcodeHaninTSPL() has not been implemented.',
    );
  }

  Future<bool> addBarcodeHaninCPCL(HaninCPCLBarcodeParams params) {
    throw UnimplementedError(
      'addBarcodeHaninCPCL() has not been implemented.',
    );
  }

  Future<bool> addQRCodeHaninTSPL(HaninTSPLQRCodeParams params) {
    throw UnimplementedError(
      'addQRCodeHaninTSPL() has not been implemented.',
    );
  }

  Future<bool> addQRCodeHaninCPCL(HaninCPCLQRCodeParams params) {
    throw UnimplementedError(
      'addQRCodeHaninCPCL() has not been implemented.',
    );
  }

  Future<bool> addRectangleHaninTSPL(Rect rect, int strokeWidth) {
    throw UnimplementedError(
      'addRectangle() has not been implemented.',
    );
  }

  Future<bool> addRectangleHaninCPCL(Rect rect, int strokeWidth) {
    throw UnimplementedError(
      'addRectangleHaninCPCL() has not been implemented.',
    );
  }

  Future<bool> addLineHaninTSPL(Rect rect) {
    throw UnimplementedError(
      'addLineHaninTSPL() has not been implemented.',
    );
  }

  Future<bool> addLineHaninCPCL(Rect rect, int strokeWidth) {
    throw UnimplementedError(
      'addLineHaninCPCL() has not been implemented.',
    );
  }

  Future<bool> addImageHaninTSPL(HaninTSPLImageParams params) {
    throw UnimplementedError(
      'addImage() has not been implemented.',
    );
  }

  Future<bool> addImageHaninCPCL(HaninCPCLImageParams params) {
    throw UnimplementedError(
      'addImage() has not been implemented.',
    );
  }
}
