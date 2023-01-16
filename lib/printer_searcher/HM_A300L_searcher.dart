import 'package:flutter_label_printer/flutter_label_printer_platform_interface.dart';
import 'package:flutter_label_printer/printer_search_result/bluetooth_result.dart';
import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';
import 'package:flutter_label_printer/printer_searcher/printer_searcher_interface.dart';

class HMA300LSearcher implements PrinterSearcherInterface {
  @override
  Future<List<PrinterSearchResult>> search() async {
    final addresses = await FlutterLabelPrinterPlatform.instance.searchHMA300L();

    return addresses.map(BluetoothResult.new).toList();
  }

}
