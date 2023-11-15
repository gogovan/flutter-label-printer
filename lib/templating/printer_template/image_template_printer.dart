import 'dart:io';
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
import 'package:flutter_label_printer/templating/command_parameters/print_text_align.dart';
import 'package:flutter_label_printer/templating/templatable_printer_interface.dart';

/// A "printer" that print the template to an output PNG image instead of printer hardware.
class ImageTemplatePrinter implements TemplatablePrinterInterface {
  ImageTemplatePrinter(this.outputPath);

  String outputPath;

  @override
  PrinterSearchResult device = EmptyResult();

  Canvas? _canvas;
  PictureRecorder? _recorder;
  double width = 0, height = 0;

  Canvas checkCanvas() {
    final canvas = _canvas;
    if (canvas == null) {
      throw const InvalidArgumentException(
        'setPrintAreaSize has not been called.',
        '',
      );
    }
    return canvas;
  }

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
    final canvas = checkCanvas();

    final paint = Paint()
      ..color = const Color.fromARGB(255, 0, 0, 0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = rect.strokeWidth;

    canvas.drawLine(rect.rect.topLeft, rect.rect.bottomRight, paint);

    return Future.value(true);
  }

  @override
  Future<bool> addQRCode(PrintQRCode qrCode) {
    // TODO: implement addQRCode
    throw UnimplementedError();
  }

  @override
  Future<bool> addRectangle(PrintRect rect) {
    final canvas = checkCanvas();

    final paint = Paint()
      ..color = const Color.fromARGB(255, 0, 0, 0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = rect.strokeWidth;

    canvas.drawRect(rect.rect, paint);

    return Future.value(true);
  }

  @override
  Future<bool> addText(PrintText printText) {
    final canvas = checkCanvas();

    TextAlign textAlign;
    switch (printText.style?.align) {
      case PrintTextAlign.left:
        textAlign = TextAlign.left;
        break;
      case PrintTextAlign.center:
        textAlign = TextAlign.center;
        break;
      case PrintTextAlign.right:
        textAlign = TextAlign.right;
        break;
      case null:
        textAlign = TextAlign.left;
        break;
    }

    final textWidth = (printText.style?.width ?? 1) * 16;
    final textHeight = (printText.style?.height ?? 1) * 16;
    final boldWeight = (printText.style?.bold ?? 0) / 10.0;
    final paragraphBuilder = ParagraphBuilder(
      ParagraphStyle(
        textAlign: textAlign,
        fontSize: textWidth,
        height: textHeight,
        fontWeight:
            FontWeight.lerp(FontWeight.w100, FontWeight.w900, boldWeight),
      ),
    );
    final paragraph = paragraphBuilder.build()
      ..layout(ParagraphConstraints(width: width - printText.xPosition));

    canvas.drawParagraph(
      paragraph,
      Offset(printText.xPosition, printText.yPosition),
    );

    return Future.value(true);
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
  Future<bool> print() async {
    final recorder = _recorder;
    if (recorder == null) {
      throw const InvalidArgumentException(
        'setPrintAreaSize has not been called.',
        '',
      );
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    if (byteData == null) {
      throw const FormatException('Unable to convert canvas image to PNG');
    }

    final buffer = byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    await File(outputPath).writeAsBytes(buffer);

    return true;
  }

  @override
  Future<bool> printTestPage() {
    // TODO: implement printTestPage
    throw UnimplementedError();
  }

  @override
  Future<bool> setPrintAreaSize(PrintAreaSize printAreaSize) {
    final recorder = PictureRecorder();
    _recorder = recorder;
    _canvas = Canvas(recorder);
    _canvas?.drawColor(
      const Color.fromARGB(255, 255, 255, 255),
      BlendMode.srcOver,
    );
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

    return Future.value(true);
  }
}
