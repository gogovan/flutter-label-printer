import 'package:flutter/foundation.dart';
import 'package:flutter_label_printer/templating/string_replacer.dart';
import 'package:flutter_label_printer/templating/template.dart';

@immutable
class PrintQRCode implements CommandParameter {
  const PrintQRCode({
    required this.xPosition,
    required this.yPosition,
    required this.data,
    this.unitSize = 1,
    this.rotation = 0,
  });

  final double xPosition;
  final double yPosition;
  final double unitSize;
  final String data;
  final double rotation;

  PrintQRCode replaceString(Map<String, String> replace) => PrintQRCode(
        xPosition: xPosition,
        yPosition: yPosition,
        data: data.format(replace),
        unitSize: unitSize,
        rotation: rotation,
      );

  @override
  String toString() =>
      'QRCode{xPosition: $xPosition, yPosition: $yPosition, unitSize: $unitSize, data: $data}';

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
