import 'package:flutter/services.dart';
import 'package:flutter_label_printer/flutter_label_printer_platform_interface.dart';
import 'package:flutter_label_printer/printer/hanin_cpcl_classes.dart';
import 'package:flutter_label_printer/printer/printer_interface.dart';
import 'package:flutter_label_printer/printer_search_result/bluetooth_result.dart';
import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';
import 'package:flutter_label_printer/src/exception_codes.dart';

/// Interface a Hanin (HPRT) HM-A300L printer.
///
/// All printing commands (such as addText) are sent directly to the official Hanin SDK. They are stored and managed by Hanin SDK.
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
class HaninCPCLPrinter extends PrinterInterface {
  HaninCPCLPrinter(super.device);

  @override
  Future<bool> connectImpl(PrinterSearchResult device) {
    try {
      return FlutterLabelPrinterPlatform.instance
          .connectHaninCPCL((device as BluetoothResult).address);
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
      return FlutterLabelPrinterPlatform.instance.disconnectHaninCPCL();
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  @override
  Future<bool> printTestPage() async {
    checkConnected();

    try {
      return FlutterLabelPrinterPlatform.instance.printTestPageHaninCPCL();
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
    HaninCPCLPrintAreaSizeParams printAreaSizeParams,
  ) async {
    checkConnected();

    try {
      return FlutterLabelPrinterPlatform.instance
          .setPrintAreaHaninCPCL(printAreaSizeParams);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  Future<bool> addTextParams(HaninCPCLTextParams params) async {
    checkConnected();

    try {
      return FlutterLabelPrinterPlatform.instance.addTextHaninCPCL(params);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  Future<bool> print() async {
    checkConnected();

    try {
      return FlutterLabelPrinterPlatform.instance.printHaninCPCL();
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  /// Command to set paper type currently used on the printer.
  Future<bool> setPaperType(HaninCPCLPaperType type) async {
    checkConnected();

    try {
      return FlutterLabelPrinterPlatform.instance.setPaperTypeHaninCPCL(type);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  /// Command to set boldness of text. Size should be within 0 to 5.
  Future<bool> setBold(int size) async {
    checkConnected();

    try {
      return FlutterLabelPrinterPlatform.instance.setBoldHaninCPCL(size);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  /// Command to set size of text. Size should be within 1 to 16.
  Future<bool> setTextSize(int width, int height) async {
    checkConnected();

    try {
      return FlutterLabelPrinterPlatform.instance
          .setHaninCPCLTextSize(width, height);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  /// Get status of the printer. It may be unable to return a status while the printer is printing.
  /// Use when there are issues printing after print commands are sent.
  Future<HaninCPCLPrinterStatus> getStatus() async {
    checkConnected();

    try {
      final code =
          await FlutterLabelPrinterPlatform.instance.getStatusHaninCPCL();

      return HaninCPCLPrinterStatus(code);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  Future<bool> prefeed(int dot) async {
    checkConnected();

    try {
      return FlutterLabelPrinterPlatform.instance.addSpaceHaninCPCL(dot);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  Future<bool> setPageWidth(int width) async {
    checkConnected();

    try {
      return FlutterLabelPrinterPlatform.instance.setPageWidthHaninCPCL(width);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  Future<bool> setAlign(HaninCPCLTextAlign align) async {
    checkConnected();

    try {
      return FlutterLabelPrinterPlatform.instance.setAlignHaninCPCL(align);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  Future<bool> addBarcodeParams(HaninCPCLBarcodeParams params) async {
    checkConnected();

    try {
      return FlutterLabelPrinterPlatform.instance.addBarcodeHaninCPCL(params);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  Future<bool> addQRCodeParams(HaninCPCLQRCodeParams params) async {
    checkConnected();

    try {
      return FlutterLabelPrinterPlatform.instance.addQRCodeHaninCPCL(params);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  Future<bool> addRectangleParam(Rect rect, int strokeWidth) async {
    checkConnected();

    try {
      return FlutterLabelPrinterPlatform.instance
          .addRectangleHaninCPCL(rect, strokeWidth);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  Future<bool> addLineParam(Rect rect, int strokeWidth) async {
    checkConnected();

    try {
      return FlutterLabelPrinterPlatform.instance
          .addLineHaninCPCL(rect, strokeWidth);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  Future<bool> addImageParams(HaninCPCLImageParams params) {
    checkConnected();

    try {
      return FlutterLabelPrinterPlatform.instance.addImageHaninCPCL(params);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }
}
