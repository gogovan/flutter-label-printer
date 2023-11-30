import 'package:flutter/foundation.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_text_style.dart';
import 'package:flutter_label_printer/templating/string_replacer.dart';
import 'package:flutter_label_printer/templating/template.dart';

@immutable
class PrintText implements CommandParameter {
  const PrintText({
    required this.text,
    required this.xPosition,
    required this.yPosition,
    this.rotation = 0,
    this.width = 0,
    this.height = 0,
    this.style,
  });

  final String text;
  final double xPosition;
  final double yPosition;
  final double rotation;
  final double width;
  final double height;
  final PrintTextStyle? style;

  PrintText replaceString(Map<String, String> replace) => PrintText(
        text: text.format(replace),
        xPosition: xPosition,
        yPosition: yPosition,
        rotation: rotation,
        width: width,
        height: height,
        style: style,
      );

  @override
  String toString() =>
      'PrintText{text: $text, xPosition: $xPosition, yPosition: $yPosition, rotation: $rotation, width: $width, height: $height, style: $style}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrintText &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          xPosition == other.xPosition &&
          yPosition == other.yPosition &&
          rotation == other.rotation &&
          width == other.width &&
          height == other.height &&
          style == other.style;

  @override
  int get hashCode =>
      text.hashCode ^
      xPosition.hashCode ^
      yPosition.hashCode ^
      rotation.hashCode ^
      width.hashCode ^
      height.hashCode ^
      style.hashCode;
}
