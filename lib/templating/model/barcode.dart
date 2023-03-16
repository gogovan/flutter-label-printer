import 'package:flutter_label_printer/templating/model/barcode_type.dart';

class Barcode {
  Barcode({
    required this.type,
    required this.xPosition,
    required this.yPosition,
    required this.data,
    this.barLineWidth = 1,
    required this.height,
  });

  final BarcodeType type;
  final double xPosition;
  final double yPosition;
  final double barLineWidth;
  final double height;
  final String data;
}