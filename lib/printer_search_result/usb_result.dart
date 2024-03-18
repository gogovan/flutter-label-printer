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
    this.interfaceClass,
    this.interfaceSubclass,
  );

  final String deviceName;
  final String vendorId;
  final String productId;
  final String serialNumber;
  final int deviceClass;
  final int deviceSubclass;
  final int deviceProtocol;
  final int interfaceClass;
  final int interfaceSubclass;

  @override
  String toString() => 'UsbResult{deviceName: $deviceName, vendorId: $vendorId, productId: $productId, serialNumber: $serialNumber, deviceClass: $deviceClass, deviceSubclass: $deviceSubclass, deviceProtocol: $deviceProtocol, interfaceClass: $interfaceClass, interfaceSubclass: $interfaceSubclass}';

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
          deviceProtocol == other.deviceProtocol &&
          interfaceClass == other.interfaceClass &&
          interfaceSubclass == other.interfaceSubclass;

  @override
  int get hashCode =>
      deviceName.hashCode ^
      vendorId.hashCode ^
      productId.hashCode ^
      serialNumber.hashCode ^
      deviceClass.hashCode ^
      deviceSubclass.hashCode ^
      deviceProtocol.hashCode ^
      interfaceClass.hashCode ^
      interfaceSubclass.hashCode;
}
