import 'package:flutter/foundation.dart';
import 'package:flutter_label_printer/templating/model/print_text_style.dart';

@immutable
class PrintText {
  const PrintText({
    required this.text,
    required this.xPosition,
    required this.yPosition,
    this.rotation = 0,
    this.style,
  });

  final String text;
  final double xPosition;
  final double yPosition;
  final double rotation;
  final PrintTextStyle? style;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrintText &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          xPosition == other.xPosition &&
          yPosition == other.yPosition &&
          style == other.style;

  @override
  int get hashCode =>
      text.hashCode ^ xPosition.hashCode ^ yPosition.hashCode ^ style.hashCode;

  @override
  String toString() => 'PrintText{text: $text, xPosition: $xPosition, yPosition: $yPosition, style: $style}';
}
