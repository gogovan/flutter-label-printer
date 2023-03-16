import 'package:flutter/foundation.dart';

@immutable
class PrintQRCode {
  const PrintQRCode({
    required this.xPosition,
    required this.yPosition,
    required this.data,
    this.unitSize = 1,
  });

  final double xPosition;
  final double yPosition;
  final double unitSize;
  final String data;

  @override
  String toString() => 'QRCode{xPosition: $xPosition, yPosition: $yPosition, unitSize: $unitSize, data: $data}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrintQRCode &&
          runtimeType == other.runtimeType &&
          xPosition == other.xPosition &&
          yPosition == other.yPosition &&
          unitSize == other.unitSize &&
          data == other.data;

  @override
  int get hashCode =>
      xPosition.hashCode ^
      yPosition.hashCode ^
      unitSize.hashCode ^
      data.hashCode;
}
