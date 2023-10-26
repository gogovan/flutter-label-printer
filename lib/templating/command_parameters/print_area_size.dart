import 'package:flutter/foundation.dart';
import 'package:flutter_label_printer/templating/template.dart';

@immutable
class PrintAreaSize implements CommandParameter {
  const PrintAreaSize({
    this.paperType,
    this.originX,
    this.originY,
    this.width,
    this.height,
  });

  final PrintPaperType? paperType;
  final double? originX;
  final double? originY;
  final double? width;
  final double? height;

  @override
  String toString() =>
      'PrintAreaSize{paperType: $paperType, originX: $originX, originY: $originY, width: $width, height: $height}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrintAreaSize &&
          runtimeType == other.runtimeType &&
          paperType == other.paperType &&
          originX == other.originX &&
          originY == other.originY &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode =>
      paperType.hashCode ^
      originX.hashCode ^
      originY.hashCode ^
      width.hashCode ^
      height.hashCode;
}

enum PrintPaperType { continuous, label }
