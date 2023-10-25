import 'package:flutter/services.dart';
import 'package:flutter_label_printer/flutter_label_printer_platform_interface.dart';
import 'package:flutter_label_printer/printer/hanin_tspl_classes.dart';
import 'package:flutter_label_printer/printer/printer_interface.dart';
import 'package:flutter_label_printer/printer_search_result/bluetooth_result.dart';
import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';
import 'package:flutter_label_printer/src/exception_codes.dart';

class HaninTSPLPrinter extends PrinterInterface {
  HaninTSPLPrinter(super.device);

  @override
  Future<bool> connectImpl(PrinterSearchResult device) {
    try {
      return FlutterLabelPrinterPlatform.instance
          .connectHaninTSPL((device as BluetoothResult).address);
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
      return FlutterLabelPrinterPlatform.instance.disconnectHaninTSPL();
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  @override
  Future<bool> printTestPage() {
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

  Future<bool> setPrintAreaSizeParams(
      HaninTSPLPrintAreaSizeParams printAreaSizeParams,
      ) async {
    checkConnected();

    try {
      return FlutterLabelPrinterPlatform.instance
          .setPrintAreaHaninTSPL(printAreaSizeParams);
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
      return FlutterLabelPrinterPlatform.instance.printHaninTSPL();
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  Future<bool> addTextParams(HaninTSPLTextParams params) async {
    checkConnected();

    try {
      return FlutterLabelPrinterPlatform.instance.addTextHaninTSPL(params);
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

  /// Get status of the printer. It may be unable to return a status while the printer is printing.
  /// Use when there are issues printing after print commands are sent.
  Future<HaninTSPLPrinterStatus> getStatus() async {
    checkConnected();

    try {
      final code =
      await FlutterLabelPrinterPlatform.instance.getStatusHaninTSPL();

      return HaninTSPLPrinterStatus(code);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }
}