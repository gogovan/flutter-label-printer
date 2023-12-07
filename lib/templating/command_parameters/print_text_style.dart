import 'package:flutter/foundation.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_text_align.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_text_font.dart';
import 'package:flutter_label_printer/templating/template.dart';

@immutable
class PrintTextStyle implements CommandParameter {
  const PrintTextStyle({
    this.bold,
    this.width,
    this.height,
    this.align,
    this.font,
    this.reverse = false,
    this.padding = 0,
    this.lineSpacing = 0,
  });

  final double? bold;
  final double? width;
  final double? height;
  final PrintTextAlign? align;
  final PrintTextFont? font;
  final bool reverse;
  final double padding;
  final double lineSpacing;

  @override
  String toString() =>
      'PrintTextStyle{bold: $bold, width: $width, height: $height, align: $align, font: $font, reverse: $reverse, padding: $padding, lineSpacing: $lineSpacing}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrintTextStyle &&
          runtimeType == other.runtimeType &&
          bold == other.bold &&
          width == other.width &&
          height == other.height &&
          align == other.align &&
          font == other.font &&
          reverse == other.reverse &&
          padding == other.padding &&
          lineSpacing == other.lineSpacing;

  @override
  int get hashCode =>
      bold.hashCode ^
      width.hashCode ^
      height.hashCode ^
      align.hashCode ^
      font.hashCode ^
      reverse.hashCode ^
      padding.hashCode ^
      lineSpacing.hashCode;
}
