import 'package:flutter/services.dart';
import 'package:flutter_label_printer/exception/invalid_connection_state_exception.dart';
import 'package:flutter_label_printer/flutter_label_printer_platform_interface.dart';
import 'package:flutter_label_printer/printer/hm_a300l_classes.dart';
import 'package:flutter_label_printer/printer/printer_interface.dart';
import 'package:flutter_label_printer/printer_search_result/bluetooth_result.dart';
import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';
import 'package:flutter_label_printer/src/exception_codes.dart';

/// Interface a Hanyin (HPRT) HM-A300L printer.
///
/// All printing commands (such as addText) are sent directly to the official Hanyin SDK. They are stored and managed by Hanyin SDK.
/// Only the function "print" would actually start printing.
///
/// For all functions, unless otherwise specified, returns true on success.
///
/// You should call `connect` first to connect the printer.
/// All commands throw InvalidConnectionStateException if the printer is not connected.
class HMA300LPrinter extends PrinterInterface {
  HMA300LPrinter(super.device);

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
      throw InvalidConnectionStateException('Device not connected.', StackTrace.current.toString());
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
      throw InvalidConnectionStateException('Device not connected.', StackTrace.current.toString());
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
      throw InvalidConnectionStateException('Device not connected.', StackTrace.current.toString());
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

  Future<bool> print() async {
    if (!isConnected()) {
      throw InvalidConnectionStateException('Device not connected.', StackTrace.current.toString());
    }

    try {
      return FlutterLabelPrinterPlatform.instance.print();
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  Future<bool> setPaperType(PaperType type) async {
    if (!isConnected()) {
      throw InvalidConnectionStateException('Device not connected.', StackTrace.current.toString());
    }

    try {
      return FlutterLabelPrinterPlatform.instance.setPaperType(type);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  Future<bool> setBold(int size) async {
    if (!isConnected()) {
      throw InvalidConnectionStateException('Device not connected.', StackTrace.current.toString());
    }

    try {
      return FlutterLabelPrinterPlatform.instance.setBold(size);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  Future<bool> setTextSize(int width, int height) async {
    if (!isConnected()) {
      throw InvalidConnectionStateException('Device not connected.', StackTrace.current.toString());
    }

    try {
      return FlutterLabelPrinterPlatform.instance.setTextSize(width, height);
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }
}
