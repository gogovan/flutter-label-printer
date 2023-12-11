import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';
import 'package:flutter_label_printer/printer_searcher/printer_searcher_interface.dart';

/// Search for Hanin (HPRT) printers using USB
class UsbPrinterSearcher extends PrinterSearcherInterface {
  @override
  Stream<List<PrinterSearchResult>> search() {
    throw UnimplementedError();
  }

}
