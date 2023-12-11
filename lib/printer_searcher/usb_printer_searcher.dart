import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_label_printer/flutter_label_printer_platform_interface.dart';
import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';
import 'package:flutter_label_printer/printer_search_result/usb_result.dart';
import 'package:flutter_label_printer/printer_searcher/printer_searcher_interface.dart';
import 'package:flutter_label_printer/src/exception_codes.dart';

/// Search for Hanin (HPRT) printers using USB
class UsbPrinterSearcher extends PrinterSearcherInterface {
  @override
  Stream<List<PrinterSearchResult>> search() {
    try {
      return FlutterLabelPrinterPlatform.instance.searchBluetooth().map(
            (event) => event.map((e) {
              final data = jsonDecode(e) as Map<String, dynamic>;

              return UsbResult(
                data['deviceName'],
                data['vendorId'],
                data['productId'],
                data['serialNumber'],
                int.parse(data['deviceClass'].toString()),
                int.parse(data['deviceSubclass'].toString()),
                int.parse(data['deviceProtocol'].toString()),
              );
            }).toList(),
          );
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex.details),
        st,
      );
    }
  }
}
