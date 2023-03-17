import 'package:flutter/foundation.dart';
import 'package:flutter_label_printer/templating/template.dart';

@immutable
class PrintBarcode implements CommandParameter {
  const PrintBarcode({
    required this.type,
    required this.xPosition,
    required this.yPosition,
    required this.data,
    this.barLineWidth = 1,
    required this.height,
    this.rotation = 0,
  });

  final PrintBarcodeType type;
  final double xPosition;
  final double yPosition;
  final double barLineWidth;
  final double height;
  final String data;
  final double rotation;

  @override
  String toString() => 'Barcode{type: $type, xPosition: $xPosition, yPosition: $yPosition, barLineWidth: $barLineWidth, height: $height, data: $data}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrintBarcode &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          xPosition == other.xPosition &&
          yPosition == other.yPosition &&
          barLineWidth == other.barLineWidth &&
          height == other.height &&
          data == other.data;

  @override
  int get hashCode =>
      type.hashCode ^
      xPosition.hashCode ^
      yPosition.hashCode ^
      barLineWidth.hashCode ^
      height.hashCode ^
      data.hashCode;
}

enum PrintBarcodeType {
  code11, code39, code93, code128, codabar, ean2, ean5, ean8, ean13, interleaved2of5, msi, patchCode, pharmacode, plessey, telepen, upca, upce
}