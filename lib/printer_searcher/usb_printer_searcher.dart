import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_label_printer/flutter_label_printer_platform_interface.dart';
import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';
import 'package:flutter_label_printer/printer_search_result/usb_result.dart';
import 'package:flutter_label_printer/printer_searcher/printer_searcher_interface.dart';
import 'package:flutter_label_printer/src/exception_codes.dart';

/// Search for Hanin (HPRT) printers using USB
class UsbPrinterSearcher extends PrinterSearcherInterface {
  Stream<String> test() {
    try {
      return FlutterLabelPrinterPlatform.instance.searchUsb().asStream();
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }

  Stream<List<PrinterSearchResult>> _search() async* {
    while (true) {
      final event = await FlutterLabelPrinterPlatform.instance.searchUsb();

      final data =
          (jsonDecode(event) as Map<String, dynamic>).map((key, value) {
        final obj = value as Map<String, dynamic>;

        final result = UsbResult(
          obj['deviceName'],
          obj['vendorId'],
          obj['productId'],
          obj['serialNumber'],
          int.parse(obj['deviceClass'].toString()),
          int.parse(obj['deviceSubclass'].toString()),
          int.parse(obj['deviceProtocol'].toString()),
        );

        return MapEntry(key, result);
      });

      yield data.values.toList();

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  Stream<List<PrinterSearchResult>> search() {
    try {
      return _search().asBroadcastStream();
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }
}
