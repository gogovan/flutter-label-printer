import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';

class BluetoothResult implements PrinterSearchResult {
  BluetoothResult(this.address, this.name);

  final String address;
  final String name;

  @override
  String toString() => 'BluetoothResult{address: $address, name: $name}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BluetoothResult &&
          runtimeType == other.runtimeType &&
          address == other.address &&
          name == other.name;

  @override
  int get hashCode => address.hashCode ^ name.hashCode;
}
