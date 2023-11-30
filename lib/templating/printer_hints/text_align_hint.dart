import 'package:flutter_label_printer/templating/template.dart';

class TextAlignHint extends PrinterHint {
  const TextAlignHint({required super.enabled, required this.charWidth})
      : super(PrinterHintType.textAlign);

  final int charWidth;
}
