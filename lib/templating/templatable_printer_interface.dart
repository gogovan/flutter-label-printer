import 'package:flutter_label_printer/printer/hm_a300l_printer.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_area_size.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_barcode.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_image.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_qr_code.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_rect.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_text.dart';

abstract class TemplatablePrinterInterface extends HMA300LPrinter {
  TemplatablePrinterInterface(super.device);

  Future<bool> setPrintAreaSize(PrintAreaSize printAreaSize);

  Future<bool> addText(PrintText printText);

  Future<bool> addBarcode(PrintBarcode barcode);

  Future<bool> addQRCode(PrintQRCode qrCode);

  Future<bool> addRectangle(PrintRect rect);

  Future<bool> addLine(PrintRect rect);

  Future<bool> addImage(PrintImage printImage);
}
