import 'package:flutter/services.dart';
import 'package:flutter_device_searcher/device/device_interface.dart';
import 'package:flutter_device_searcher/search_result/bluetooth_result.dart';
import 'package:flutter_device_searcher/search_result/device_search_result.dart';
import 'package:flutter_label_printer/exception/invalid_connection_state_exception.dart';
import 'package:flutter_label_printer/flutter_label_printer_platform_interface.dart';
import 'package:flutter_label_printer/printer/hm_a300l_classes.dart';
import 'package:flutter_label_printer/src/exception_codes.dart';

/// Interface a Hanyin (HPRT) HM-A300L printer.
///
/// All printing commands (such as addText) are sent directly to the official Hanyin SDK. They are stored and managed by Hanyin SDK.
/// Only the function "print" would actually start printing.
///
/// For all functions, unless otherwise specified, returns true on success.
///
/// Before sending any print commands, the print area size should be set using `setPrintAreaSize` and paper type should be set using `setPaperType`.
/// `setPaperType` can be called once per session, however `setPrintAreaSize` should be called for every print command.
/// Failure of doing so may result in unexpected behavior in printing.
///
/// You should call `connect` first to connect the printer.
/// All commands throw InvalidConnectionStateException if the printer is not connected.
class HMA300LPrinter extends DeviceInterface {
  HMA300LPrinter(super.device);

  @override
  Future<bool> connectImpl(DeviceSearchResult device) {
    try {
      return FlutterLabelPrinterPlatform.instance
          .connectHMA300L((device as BluetoothResult).address);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  @override
  Future<bool> disconnectImpl() {
    try {
      return FlutterLabelPrinterPlatform.instance.disconnectHMA300L();
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  Future<bool> printTestPage() async {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    try {
      return FlutterLabelPrinterPlatform.instance.printTestPageHMA300L();
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  /// Set logging level.
  /// `level` should be from 0 to 5, indicating from VERBOSE, DEBUG, INFO, WARN, ERROR to ASSERT levels.
  Future<void> setLogLevel(int level) async =>
      FlutterLabelPrinterPlatform.instance.setLogLevel(level);

  Future<bool> setPrintAreaSizeParams(
    HMA300LPrintAreaSizeParams printAreaSizeParams,
  ) async {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    try {
      return FlutterLabelPrinterPlatform.instance
          .setPrintAreaSizeHMA300L(printAreaSizeParams);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  Future<bool> addTextParams(HMA300LTextParams params) async {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    try {
      return FlutterLabelPrinterPlatform.instance.addTextHMA300L(params);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  Future<bool> print() async {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    try {
      return FlutterLabelPrinterPlatform.instance.printHMA300L();
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  /// Command to set paper type currently used on the printer.
  Future<bool> setPaperType(HMA300LPaperType type) async {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    try {
      return FlutterLabelPrinterPlatform.instance.setPaperTypeHMA300L(type);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  /// Command to set boldness of text. Size should be within 0 to 5.
  Future<bool> setBold(int size) async {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    try {
      return FlutterLabelPrinterPlatform.instance.setBoldHMA300L(size);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  /// Command to set size of text. Size should be within 1 to 16.
  Future<bool> setTextSize(int width, int height) async {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    try {
      return FlutterLabelPrinterPlatform.instance
          .setTextSizeHMA300L(width, height);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  /// Get status of the printer. It may be unable to return a status while the printer is printing.
  /// Use when there are issues printing after print commands are sent.
  Future<HMA300LPrinterStatus> getStatus() async {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    try {
      final code =
          await FlutterLabelPrinterPlatform.instance.getStatusHMA300L();

      return HMA300LPrinterStatus(code);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  Future<bool> prefeed(int dot) async {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    try {
      return FlutterLabelPrinterPlatform.instance.prefeedHMA300L(dot);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  Future<bool> setPageWidth(int width) async {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    try {
      return FlutterLabelPrinterPlatform.instance.setPageWidthHMA300L(width);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  Future<bool> setAlign(HMA300LPrinterTextAlign align) async {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    try {
      return FlutterLabelPrinterPlatform.instance.setAlignHMA300L(align.code);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  Future<bool> addBarcodeParams(HMA300LBarcodeParams params) async {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    try {
      return FlutterLabelPrinterPlatform.instance.addBarcode(params);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  Future<bool> addQRCodeParams(HMA300LQRCodeParams params) async {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    try {
      return FlutterLabelPrinterPlatform.instance.addQRCode(params);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  Future<bool> addRectangleParam(Rect rect, int strokeWidth) async {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    try {
      return FlutterLabelPrinterPlatform.instance
          .addRectangle(rect, strokeWidth);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  Future<bool> addLineParam(Rect rect, int strokeWidth) async {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    try {
      return FlutterLabelPrinterPlatform.instance.addLine(rect, strokeWidth);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  Future<bool> addImageParams(HMA300LPrintImageParams params) {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    try {
      return FlutterLabelPrinterPlatform.instance.addImage(params);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }
}
