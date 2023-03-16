import 'package:flutter/foundation.dart';
import 'package:flutter_label_printer/templating/model/print_barcode_type.dart';

@immutable
class PrintBarcode {
  const PrintBarcode({
    required this.type,
    required this.xPosition,
    required this.yPosition,
    required this.data,
    this.barLineWidth = 1,
    required this.height,
  });

  final PrintBarcodeType type;
  final double xPosition;
  final double yPosition;
  final double barLineWidth;
  final double height;
  final String data;

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
