import 'package:flutter/services.dart';
import 'package:flutter_label_printer/exception/invalid_connection_state_exception.dart';
import 'package:flutter_label_printer/flutter_label_printer_platform_interface.dart';
import 'package:flutter_label_printer/printer/hm_a300l_classes.dart';
import 'package:flutter_label_printer/printer/printer_interface.dart';
import 'package:flutter_label_printer/printer_search_result/bluetooth_result.dart';
import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';
import 'package:flutter_label_printer/src/exception_codes.dart';

/// Interface a Hanyin (HPRT) HM-A300L printer.
class HMA300L extends PrinterInterface {
  HMA300L(super.device);

  @override
  Future<bool> connectImpl(PrinterSearchResult device) {
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

  @override
  Future<bool> printTestPage() async {
    if (!isConnected()) {
      throw InvalidConnectionStateException("Device not connected.", StackTrace.current.toString());
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

  Future<bool> setPrintAreaSize(PrintAreaSizeParams params) async {
    if (!isConnected()) {
      throw InvalidConnectionStateException("Device not connected.", StackTrace.current.toString());
    }

    try {
      return FlutterLabelPrinterPlatform.instance.setPrintAreaSizeHMA300L(params);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  Future<bool> addText(TextParams params) async {
    if (!isConnected()) {
      throw InvalidConnectionStateException("Device not connected.", StackTrace.current.toString());
    }

    try {
      return FlutterLabelPrinterPlatform.instance.addText(params);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }
}
