import 'package:flutter/services.dart';
import 'package:flutter_label_printer/flutter_label_printer_platform_interface.dart';
import 'package:flutter_label_printer/printer_search_result/bluetooth_result.dart';
import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';
import 'package:flutter_label_printer/printer_searcher/printer_searcher_interface.dart';
import 'package:flutter_label_printer/src/exception_codes.dart';

/// Searcher for Hanyin (HPRT) HM-A300L printers.
class HMA300LSearcher implements PrinterSearcherInterface {
  /// Scan for Bluetooth printers.
  /// Will request for Bluetooth permission if none was granted yet.
  @override
  Stream<List<PrinterSearchResult>> search() {
    try {
      return FlutterLabelPrinterPlatform.instance
          .searchHMA300L()
          .map((event) => event.map(BluetoothResult.new).toList());
    } on PlatformException catch (ex, st) {
      Error.throwWithStackTrace(
        getExceptionFromCode(int.parse(ex.code), ex.message ?? '', ex),
        st,
      );
    }
  }
}
