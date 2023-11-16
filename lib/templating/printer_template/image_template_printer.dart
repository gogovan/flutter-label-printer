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
import 'package:image/image.dart' as image2;

/// A "printer" that print the template to an output PNG image instead of printer hardware.
class ImageTemplatePrinter implements TemplatablePrinterInterface {
  ImageTemplatePrinter(this.outputPath);

  String outputPath;

  @override
  PrinterSearchResult device = EmptyResult();

  image2.Command? _imageCommand;
  final image2.ColorRgb8 black = image2.ColorRgb8(0, 0, 0);

  double width = 0, height = 0;

  image2.Command checkImageCommand() {
    final command = _imageCommand;
    if (command == null) {
      throw const InvalidArgumentException(
        'setPrintAreaSize has not been called.',
        '',
      );
    }
    return command;
  }

  @override
  Future<bool> addBarcode(PrintBarcode barcode) {
    // TODO: implement addBarcode
    throw UnimplementedError();
  }

  @override
  Future<bool> addQRCode(PrintQRCode qrCode) {
    // TODO: implement addQRCode
    throw UnimplementedError();
  }

  @override
  Future<bool> addImage(PrintImage printImage) {
    // TODO: implement addImage
    throw UnimplementedError();
  }

  @override
  Future<bool> addLine(PrintRect rect) {
    checkImageCommand().drawLine(
      x1: rect.rect.left.toInt(),
      y1: rect.rect.top.toInt(),
      x2: rect.rect.right.toInt(),
      y2: rect.rect.bottom.toInt(),
      thickness: rect.strokeWidth,
      color: black,
    );

    return Future.value(true);
  }

  @override
  Future<bool> addRectangle(PrintRect rect) {
    checkImageCommand().drawRect(
      x1: rect.rect.left.toInt(),
      y1: rect.rect.top.toInt(),
      x2: rect.rect.right.toInt(),
      y2: rect.rect.bottom.toInt(),
      thickness: rect.strokeWidth,
      color: black,
    );

    return Future.value(true);
  }

  @override
  Future<bool> addText(PrintText printText) async {
    final command = checkImageCommand();

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

    final textWidth = (printText.style?.width ?? 0) + 16;
    final boldWeight = (printText.style?.bold ?? 0) / 10.0;
    final paragraphBuilder = ParagraphBuilder(
      ParagraphStyle(
        textAlign: textAlign,
        fontSize: textWidth,
        fontWeight:
            FontWeight.lerp(FontWeight.w400, FontWeight.w900, boldWeight),
      ),
    )
      ..pushStyle(TextStyle(color: const Color.fromARGB(255, 0, 0, 0)))
      ..addText(printText.text)
      ..pop();
    final paragraph = paragraphBuilder.build()
      ..layout(ParagraphConstraints(width: width - printText.xPosition));

    final recorder = PictureRecorder();
    Canvas(recorder).drawParagraph(paragraph, Offset.zero);
    final picture = recorder.endRecording();
    final uiImage = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await uiImage.toByteData();
    if (byteData == null) {
      throw const FormatException('Unable to convert canvas text image');
    }
    final image = image2.Image.fromBytes(
      width: width.toInt(),
      height: height.toInt(),
      bytes: byteData.buffer,
      numChannels: 4,
    );
    command.compositeImage(
      image2.Command()..image(image),
      dstX: printText.xPosition.toInt(),
      dstY: printText.yPosition.toInt(),
      blend: image2.BlendMode.overlay,
    );

    return true;
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
    final command = checkImageCommand()
      ..encodePngFile(outputPath)
      ..writeToFile(outputPath);
    await command.execute();

    return true;
  }

  @override
  Future<bool> printTestPage() {
    // TODO: implement printTestPage
    throw UnimplementedError();
  }

  @override
  Future<bool> setPrintAreaSize(PrintAreaSize printAreaSize) {
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

    _imageCommand = image2.Command()
      ..createImage(
        width: width.toInt(),
        height: height.toInt(),
      )
      ..fill(color: image2.ColorRgb8(255, 255, 255));

    return Future.value(true);
  }
}
