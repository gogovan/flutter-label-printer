import 'package:flutter_label_printer/templating/template.dart';

enum PrintTextAlign implements CommandParameter {
  left(0),
  center(1),
  right(2);

  const PrintTextAlign(this.code);

  final int code;
}
