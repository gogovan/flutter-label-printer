import 'package:flutter/foundation.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_text_align.dart';
import 'package:flutter_label_printer/templating/template.dart';

@immutable
class PrintTextStyle implements CommandParameter {
  const PrintTextStyle({
    this.bold,
    this.width,
    this.height,
    this.align,
  });

  final double? bold;
  final double? width;
  final double? height;
  final PrintTextAlign? align;

  @override
  String toString() => 'PrintTextStyle{bold: $bold, width: $width, height: $height, align: $align}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrintTextStyle &&
          runtimeType == other.runtimeType &&
          bold == other.bold &&
          width == other.width &&
          height == other.height &&
          align == other.align;

  @override
  int get hashCode =>
      bold.hashCode ^ width.hashCode ^ height.hashCode ^ align.hashCode;
}
