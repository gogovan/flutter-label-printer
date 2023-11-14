import 'dart:ui';

import 'package:flutter_label_printer/exception/invalid_argument_exception.dart';
import 'package:flutter_label_printer/printer_search_result/empty_result.dart';
import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_area_size.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_barcode.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_image.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_qr_code.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_rect.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_text.dart';
import 'package:flutter_label_printer/templating/templatable_printer_interface.dart';

/// A "printer" that print the template to an output PNG image instead of printer hardware.
class ImageTemplatePrinter implements TemplatablePrinterInterface {
  ImageTemplatePrinter(this.outputPath);

  String outputPath;

  @override
  PrinterSearchResult device = EmptyResult();

  Canvas? _canvas;
  double width = 0, height = 0;

  @override
  Future<bool> addBarcode(PrintBarcode barcode) {
    // TODO: implement addBarcode
    throw UnimplementedError();
  }

  @override
  Future<bool> addImage(PrintImage printImage) {
    // TODO: implement addImage
    throw UnimplementedError();
  }

  @override
  Future<bool> addLine(PrintRect rect) {
    // TODO: implement addLine
    throw UnimplementedError();
  }

  @override
  Future<bool> addQRCode(PrintQRCode qrCode) {
    // TODO: implement addQRCode
    throw UnimplementedError();
  }

  @override
  Future<bool> addRectangle(PrintRect rect) {
    // TODO: implement addRectangle
    throw UnimplementedError();
  }

  @override
  Future<bool> addText(PrintText printText) {
    // TODO: implement addText
    throw UnimplementedError();
  }

  @override
  void checkConnected() => true;

  @override
  Future<bool> connect() async => true;

  @override
  Future<bool> connectImpl(PrinterSearchResult device) async => true;

  @override
  Future<bool> disconnect() async => true;

  @override
  Future<bool> disconnectImpl() async => true;

  @override
  bool isConnected() => true;

  @override
  Future<bool> print() {
    // TODO: implement print
    throw UnimplementedError();
  }

  @override
  Future<bool> printTestPage() {
    // TODO: implement printTestPage
    throw UnimplementedError();
  }

  @override
  Future<bool> setPrintAreaSize(PrintAreaSize printAreaSize) async {
    _canvas = Canvas(PictureRecorder());
    width = printAreaSize.width ?? 0;
    height = printAreaSize.height ?? 0;

    if (width <= 0) {
      throw InvalidArgumentException(
        'Invalid width: $width',
        '',
      );
    }
    if (height <= 0) {
      throw InvalidArgumentException(
        'Invalid height: $height',
        '',
      );
    }

    return true;
  }
}
