import 'package:flutter/services.dart';
import 'package:flutter_label_printer/flutter_label_printer_platform_interface.dart';
import 'package:flutter_label_printer/printer_search_result/bluetooth_result.dart';
import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';
import 'package:flutter_label_printer/printer_searcher/printer_searcher_interface.dart';
import 'package:flutter_label_printer/src/exception_codes.dart';

/// Searcher for Hanyin (HPRT) HM-A300L printers.
class HMA300LSearcher implements PrinterSearcherInterface {
  @override
  Future<List<PrinterSearchResult>> search() async {
    try {
      final addresses =
          await FlutterLabelPrinterPlatform.instance.searchHMA300L();

      return addresses.map(BluetoothResult.new).toList();
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex),
        st,
      );
    }
  }
}
