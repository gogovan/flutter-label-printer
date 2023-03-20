import 'dart:ui';

import 'package:flutter_label_printer/printer/printer_interface.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_area_size.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_barcode.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_image.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_qr_code.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_rect.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_text.dart';

abstract class TemplatablePrinterInterface extends PrinterInterface {
  TemplatablePrinterInterface(super.device);

  Future<bool> setPrintAreaSize(PrintAreaSize printAreaSize);

  Future<bool> addText(PrintText printText);

  Future<bool> addBarcode(PrintBarcode barcode);

  Future<bool> addQRCode(PrintQRCode qrCode);

  Future<bool> addRectangle(PrintRect rect);

  Future<bool> addLine(PrintRect rect);

  Future<bool> addImage(PrintImage printImage);

  Future<bool> print();
}
