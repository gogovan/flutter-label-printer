import 'package:flutter/services.dart';
import 'package:flutter_label_printer/flutter_label_printer_platform_interface.dart';
import 'package:flutter_label_printer/printer/printer_interface.dart';
import 'package:flutter_label_printer/printer_search_result/bluetooth_result.dart';
import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';
import 'package:flutter_label_printer/src/exception_codes.dart';

/// Interface a Hanyin (HPRT) HM-A300L printer.
class HMA300L extends PrinterInterface {
  @override
  Future<bool> connect(PrinterSearchResult device) async {
    try {
      final result = await FlutterLabelPrinterPlatform.instance.connectHMA300L((device as BluetoothResult).address);
      if (result) {
        connected = true;
      }

      return result;
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  @override
  Future<bool> disconnect() async {
    try {
      final result = await FlutterLabelPrinterPlatform.instance.disconnectHMA300L();
      if (result) {
        connected = false;
      }

      return result;
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

}