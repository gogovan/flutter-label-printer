import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';

class UsbResult implements PrinterSearchResult {
  UsbResult(
    this.deviceName,
    this.vendorId,
    this.productId,
    this.serialNumber,
    this.deviceClass,
    this.deviceSubclass,
    this.deviceProtocol,
  );

  final String deviceName;
  final String vendorId;
  final String productId;
  final String serialNumber;
  final int deviceClass;
  final int deviceSubclass;
  final int deviceProtocol;
}
