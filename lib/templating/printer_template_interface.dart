import 'dart:ui';

import 'package:flutter_label_printer/printer/printer_interface.dart';
import 'package:flutter_label_printer/templating/model/print_area_size.dart';
import 'package:flutter_label_printer/templating/model/print_barcode.dart';
import 'package:flutter_label_printer/templating/model/print_qr_code.dart';
import 'package:flutter_label_printer/templating/model/print_text.dart';
import 'package:flutter_label_printer/templating/model/print_text_style.dart';

abstract class PrinterTemplateInterface extends PrinterInterface {
  PrinterTemplateInterface(super.device);

  Future<bool> setPrintAreaSize(PrintAreaSize printAreaSize);

  Future<bool> addText(PrintText printText, PrintTextStyle style);

  Future<bool> addBarcode(PrintBarcode barcode);

  Future<bool> addQRCode(PrintQRCode qrCode);

  Future<bool> addRectangle(Rect rect, int strokeWidth);

  Future<bool> addLine(Rect rect, int strokeWidth);


}
