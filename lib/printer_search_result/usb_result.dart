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

  @override
  String toString() => 'UsbResult{deviceName: $deviceName, vendorId: $vendorId, productId: $productId, serialNumber: $serialNumber, deviceClass: $deviceClass, deviceSubclass: $deviceSubclass, deviceProtocol: $deviceProtocol}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsbResult &&
          runtimeType == other.runtimeType &&
          deviceName == other.deviceName &&
          vendorId == other.vendorId &&
          productId == other.productId &&
          serialNumber == other.serialNumber &&
          deviceClass == other.deviceClass &&
          deviceSubclass == other.deviceSubclass &&
          deviceProtocol == other.deviceProtocol;

  @override
  int get hashCode =>
      deviceName.hashCode ^
      vendorId.hashCode ^
      productId.hashCode ^
      serialNumber.hashCode ^
      deviceClass.hashCode ^
      deviceSubclass.hashCode ^
      deviceProtocol.hashCode;
}
