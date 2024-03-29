import 'dart:ui';

import 'package:barcode_image/barcode_image.dart';
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
import 'package:flutter_label_printer/templating/command_parameters/print_text_style.dart';
import 'package:flutter_label_printer/templating/printer_hints/text_align_hint.dart';
import 'package:flutter_label_printer/templating/templatable_printer_interface.dart';
import 'package:image/image.dart' as img;

/// A "printer" that print the template to an output PNG image instead of printer hardware.
class ImageTemplatePrinter implements TemplatablePrinterInterface {
  ImageTemplatePrinter(this.outputPath);

  String outputPath;

  @override
  PrinterSearchResult device = EmptyResult();

  img.Image? _image;
  final img.ColorRgb8 black = img.ColorRgb8(0, 0, 0);
  final img.ColorRgb8 white = img.ColorRgb8(255, 255, 255);

  double width = 0, height = 0;

  img.Image checkImageCommand() {
    final img = _image;
    if (img == null) {
      throw const InvalidArgumentException(
        'setPrintAreaSize has not been called.',
        '',
      );
    }
    return img;
  }

  @override
  Future<bool> addBarcode(PrintBarcode barcode) {
    final image = checkImageCommand();

    final barcodeImage = img.Image(
      width: (barcode.barLineWidth * 50 * barcode.data.length).toInt(),
      height: barcode.height.toInt(),
    );
    img.fill(barcodeImage, color: white);

    Barcode bc;
    switch (barcode.type) {
      case PrintBarcodeType.code39:
        bc = Barcode.code39();
        break;
      case PrintBarcodeType.code93:
        bc = Barcode.code93();
        break;
      case PrintBarcodeType.code128:
        bc = Barcode.code128();
        break;
      case PrintBarcodeType.codabar:
        bc = Barcode.codabar();
        break;
      case PrintBarcodeType.ean2:
        bc = Barcode.ean2();
        break;
      case PrintBarcodeType.ean5:
        bc = Barcode.ean5();
        break;
      case PrintBarcodeType.ean8:
        bc = Barcode.ean8();
        break;
      case PrintBarcodeType.ean13:
        bc = Barcode.ean13();
        break;
      case PrintBarcodeType.itf14:
        bc = Barcode.itf14();
        break;
      case PrintBarcodeType.telepen:
        bc = Barcode.telepen();
        break;
      case PrintBarcodeType.upca:
        bc = Barcode.upcA();
        break;
      case PrintBarcodeType.upce:
        bc = Barcode.upcE();
        break;
      default:
        throw InvalidArgumentException(
          'Unsupported Barcode type: ${barcode.type}',
          '',
        );
    }
    drawBarcode(barcodeImage, bc, barcode.data);

    img.compositeImage(
      image,
      barcodeImage,
      dstX: barcode.xPosition.toInt(),
      dstY: barcode.yPosition.toInt(),
    );

    return Future.value(true);
  }

  @override
  Future<bool> addQRCode(PrintQRCode qrCode) {
    final image = checkImageCommand();

    final qrImage = img.Image(
      width: (qrCode.unitSize * 50).toInt(),
      height: (qrCode.unitSize * 50).toInt(),
    );
    img.fill(qrImage, color: white);

    drawBarcode(qrImage, Barcode.qrCode(), qrCode.data);

    img.compositeImage(
      image,
      qrImage,
      dstX: qrCode.xPosition.toInt(),
      dstY: qrCode.yPosition.toInt(),
    );

    return Future.value(true);
  }

  @override
  Future<bool> addImage(PrintImage printImage) async {
    final image = checkImageCommand();

    final srcImage = await img.decodeImageFile(printImage.path);
    if (srcImage == null) {
      throw img.ImageException(
        'Unable to load source image ${printImage.path}',
      );
    }
    switch (printImage.monochromizationAlgorithm) {
      case MonochromizationAlgorithm.binary:
        img.luminanceThreshold(srcImage);
        break;
      case MonochromizationAlgorithm.cluster:
        img.dotScreen(srcImage);
        break;
      default:
        img.luminanceThreshold(srcImage);
        break;
    }

    img.compositeImage(
      image,
      srcImage,
      dstX: printImage.xPosition.toInt(),
      dstY: printImage.yPosition.toInt(),
    );

    return true;
  }

  @override
  Future<bool> addLine(PrintRect rect) {
    img.drawLine(
      checkImageCommand(),
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
    img.drawRect(
      checkImageCommand(),
      x1: rect.rect.left.toInt(),
      y1: rect.rect.top.toInt(),
      x2: rect.rect.right.toInt(),
      y2: rect.rect.bottom.toInt(),
      thickness: rect.strokeWidth,
      color: black,
    );

    return Future.value(true);
  }

  static Future<img.Image> getTextImage(PrintText printText) async {
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
      default:
        textAlign = TextAlign.left;
        break;
    }

    var blockWidth = printText.width;
    var blockHeight = printText.height;

    final reverse = printText.style?.reverse ?? false;

    final textWidth = (printText.style?.width ?? 1) * 16;
    final boldWeight =
        (printText.style?.bold ?? 0) > 0 ? FontWeight.w700 : FontWeight.w400;
    final paragraphBuilder = ParagraphBuilder(
      ParagraphStyle(
        textAlign: textAlign,
        fontSize: textWidth,
        fontFamily: printText.style?.font?.name ?? 'Roboto',
        fontWeight: boldWeight,
        height: printText.style?.lineSpacing ?? 0,
      ),
    )
      ..pushStyle(
        TextStyle(
          color: reverse
              ? const Color.fromARGB(255, 255, 255, 255)
              : const Color.fromARGB(255, 0, 0, 0),
        ),
      )
      ..addText(printText.text)
      ..pop();
    final paragraph = paragraphBuilder.build()
      ..layout(
        ParagraphConstraints(
          width: blockWidth > 0 ? blockWidth : double.infinity,
        ),
      );

    blockWidth = blockWidth > 0 ? blockWidth : paragraph.maxIntrinsicWidth;
    blockHeight = blockHeight > 0 ? blockHeight : paragraph.height;

    final padding = printText.style?.padding ?? 0;
    blockWidth += padding * 2;
    blockHeight += padding * 2;

    final recorder = PictureRecorder();
    Canvas(recorder)
      ..drawColor(
        reverse
            ? const Color.fromARGB(255, 0, 0, 0)
            : const Color.fromARGB(255, 255, 255, 255),
        BlendMode.srcOver,
      )
      ..drawParagraph(
        paragraph,
        Offset(padding, padding),
      );
    final picture = recorder.endRecording();
    final uiImage =
        await picture.toImage(blockWidth.toInt(), blockHeight.toInt());
    final byteData = await uiImage.toByteData();
    if (byteData == null) {
      throw const FormatException('Unable to convert canvas text image');
    }
    final textImage = img.Image.fromBytes(
      width: blockWidth.toInt(),
      height: blockHeight.toInt(),
      bytes: byteData.buffer,
      numChannels: 4,
    );

    return textImage;
  }

  @override
  Future<bool> addText(
    PrintText printText,
    TextAlignHint? textAlignHint,
  ) async {
    final image = checkImageCommand();

    final textImage = await getTextImage(printText);
    img.compositeImage(
      image,
      textImage,
      dstX: printText.xPosition.toInt(),
      dstY: printText.yPosition.toInt(),
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
    final image = checkImageCommand();
    await img.encodePngFile(outputPath, image);

    return true;
  }

  @override
  Future<bool> printTestPage() async {
    await setPrintAreaSize(const PrintAreaSize(width: 800, height: 800));
    await addText(
      const PrintText(
        text: 'Test Page',
        xPosition: 50,
        yPosition: 5,
        style: PrintTextStyle(width: 3, height: 100, bold: 2),
      ),
      null,
    );
    await addText(
      const PrintText(text: 'CODE128', xPosition: 0, yPosition: 66),
      null,
    );
    await addBarcode(
      const PrintBarcode(
        type: PrintBarcodeType.code128,
        xPosition: 0,
        yPosition: 100,
        data: '123456789',
        height: 50,
      ),
    );
    await addQRCode(
      const PrintQRCode(
        xPosition: 0,
        yPosition: 160,
        data: 'https://example.com',
        unitSize: 5,
      ),
    );
    await addRectangle(const PrintRect(rect: Rect.fromLTRB(10, 540, 110, 640)));
    await addLine(const PrintRect(rect: Rect.fromLTRB(10, 540, 110, 640)));
    await print();

    return true;
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

    final image = img.Image(width: width.toInt(), height: height.toInt());
    img.fill(image, color: white);
    _image = image;

    return Future.value(true);
  }
}
