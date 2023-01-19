import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';

class BluetoothResult implements PrinterSearchResult {
  BluetoothResult(this.address);

  final String address;

  @override
  String toString() => 'BluetoothResult{address: $address}';
}
