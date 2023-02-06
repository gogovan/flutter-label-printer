import 'package:flutter_label_printer/flutter_label_printer_method_channel.dart';
import 'package:flutter_label_printer/printer/hm_a300l_classes.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class FlutterLabelPrinterPlatform extends PlatformInterface {
  /// Constructs a FlutterLabelPrinterPlatform.
  FlutterLabelPrinterPlatform() : super(token: _token);

  // ignore: no-object-declaration, needed, directly from Flutter template code.
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

  Future<bool> setPrintAreaSizeHMA300L(PrintAreaSizeParams params) {
    throw UnimplementedError(
      'setPrintAreaSizeHMA300L() has not been implemented.',
    );
  }

  Future<bool> addText(TextParams params) {
    throw UnimplementedError(
      'addText() has not been implemented.',
    );
  }

  Future<bool> print() {
    throw UnimplementedError(
      'print() has not been implemented.',
    );
  }

  Future<bool> setPaperType(PaperType type) {
    throw UnimplementedError(
      'print() has not been implemented.',
    );
  }

  /// Command to set boldness of text. Size should be within 0 to 5.
  Future<bool> setBold(int size) {
    throw UnimplementedError(
      'print() has not been implemented.',
    );
  }

  /// Command to set size of text. Size should be within 1 to 16.
  Future<bool> setTextSize(int width, int height) {
    throw UnimplementedError(
      'setSize() has not been implemented.',
    );
  }
}
