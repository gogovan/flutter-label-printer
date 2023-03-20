import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_label_printer/templating/template.dart';

@immutable
class PrintRect implements CommandParameter {
  const PrintRect({
    required this.rect,
    this.strokeWidth = 1,
  });

  final Rect rect;
  final double strokeWidth;

  @override
  String toString() => 'PrintRect{rect: $rect, strokeWidth: $strokeWidth}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrintRect &&
          runtimeType == other.runtimeType &&
          rect == other.rect &&
          strokeWidth == other.strokeWidth;

  @override
  int get hashCode => rect.hashCode ^ strokeWidth.hashCode;
}
