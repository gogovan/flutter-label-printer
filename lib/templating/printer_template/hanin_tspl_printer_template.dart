import 'package:flutter_label_printer/exception/invalid_argument_exception.dart';
import 'package:flutter_label_printer/printer/common_classes.dart';
import 'package:flutter_label_printer/printer/hanin_tspl_classes.dart';
import 'package:flutter_label_printer/printer/hanin_tspl_printer.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_area_size.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_barcode.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_image.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_qr_code.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_rect.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_text.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_text_align.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_text_font.dart';
import 'package:flutter_label_printer/templating/templatable_printer_interface.dart';

class HaninTSPLPrinterTemplate extends HaninTSPLPrinter
    implements TemplatablePrinterInterface {
  HaninTSPLPrinterTemplate(super.device);

  @override
  Future<bool> setPrintAreaSize(PrintAreaSize printAreaSize) async {
    checkConnected();

    final width = printAreaSize.width?.toInt();
    final height = printAreaSize.height?.toInt();

    if (width == null || height == null) {
      throw InvalidArgumentException(
        'Width and Height must not be null',
        StackTrace.current.toString(),
      );
    }

    final params = HaninTSPLPrintAreaSizeParams(
      width: width,
      height: height,
    );

    return setPrintAreaSizeParams(params);
  }

  @override
  Future<bool> addText(PrintText printText) {
    checkConnected();

    final HaninTSPLFont font;
    switch (printText.style?.font) {
      case PrintTextFont.small:
        font = HaninTSPLFont.font1;
        break;
      case PrintTextFont.medium:
        font = HaninTSPLFont.font2;
        break;
      case PrintTextFont.large:
        font = HaninTSPLFont.font3;
        break;
      case PrintTextFont.vlarge:
        font = HaninTSPLFont.font4;
        break;
      case PrintTextFont.vvlarge:
        font = HaninTSPLFont.font5;
        break;
      case PrintTextFont.chinese:
        font = HaninTSPLFont.fontChinese;
        break;
      case PrintTextFont.chineseLarge:
        font = HaninTSPLFont.fontChinese;
        break;
      case PrintTextFont.ocrSmall:
        font = HaninTSPLFont.font6;
        break;
      case PrintTextFont.ocrLarge:
        font = HaninTSPLFont.font7;
        break;
      case PrintTextFont.square:
        font = HaninTSPLFont.fontChinese;
        break;
      case PrintTextFont.triumvirate:
        font = HaninTSPLFont.fontTriumvirate;
        break;
      case null:
        font = HaninTSPLFont.fontChinese;
        break;
    }

    final HaninTSPLTextAlign align;
    switch (printText.style?.align) {
      case PrintTextAlign.left:
        align = HaninTSPLTextAlign.left;
        break;
      case PrintTextAlign.center:
        align = HaninTSPLTextAlign.center;
        break;
      case PrintTextAlign.right:
        align = HaninTSPLTextAlign.right;
        break;
      case null:
        align = HaninTSPLTextAlign.left;
        break;
    }

    final params = HaninTSPLTextParams(
      xPosition: printText.xPosition.toInt(),
      yPosition: printText.yPosition.toInt(),
      text: printText.text,
      font: font,
      rotate: Rotation90.fromAngle(printText.rotation),
      alignment: align,
      charWidth: printText.style?.width?.toInt() ?? 1,
      charHeight: printText.style?.height?.toInt() ?? 1,
    );

    return addTextParams(params);
  }

  @override
  Future<bool> addBarcode(PrintBarcode barcode) {
    checkConnected();

    final HaninTSPLBarcodeType barcodeType;
    switch (barcode.type) {
      case PrintBarcodeType.code128:
        barcodeType = HaninTSPLBarcodeType.code128;
        break;
      case PrintBarcodeType.code128m:
        barcodeType = HaninTSPLBarcodeType.code128m;
        break;
      case PrintBarcodeType.ean128:
        barcodeType = HaninTSPLBarcodeType.ean128;
        break;
      case PrintBarcodeType.code39:
        barcodeType = HaninTSPLBarcodeType.code39;
        break;
      case PrintBarcodeType.code93:
        barcodeType = HaninTSPLBarcodeType.code93;
        break;
      case PrintBarcodeType.upca:
        barcodeType = HaninTSPLBarcodeType.upca;
        break;
      case PrintBarcodeType.msi:
        barcodeType = HaninTSPLBarcodeType.msi;
        break;
      case PrintBarcodeType.itf14:
        barcodeType = HaninTSPLBarcodeType.itf14;
        break;
      case PrintBarcodeType.ean13:
        barcodeType = HaninTSPLBarcodeType.ean13;
        break;
      default:
        throw UnsupportedError(
          'Barcode format ${barcode.type} is unsupported on Hanin TSPL',
        );
    }

    final params = HaninTSPLBarcodeParams(
      xPosition: barcode.xPosition.toInt(),
      yPosition: barcode.yPosition.toInt(),
      barcodeType: barcodeType,
      height: barcode.height.toInt(),
      data: barcode.data,
      rotate: Rotation90.fromAngle(barcode.rotation),
    );

    return addBarcodeParams(params);
  }

  @override
  Future<bool> addQRCode(PrintQRCode qrCode) {
    checkConnected();

    final params = HaninTSPLQRCodeParams(
      xPosition: qrCode.xPosition.toInt(),
      yPosition: qrCode.yPosition.toInt(),
      unitSize: qrCode.unitSize.toInt(),
      data: qrCode.data,
    );

    return addQRCodeParams(params);
  }

  @override
  Future<bool> addLine(PrintRect rect) {
    checkConnected();

    return addLineParam(rect.rect);
  }

  @override
  Future<bool> addRectangle(PrintRect rect) {
    checkConnected();

    return addRectangleParam(rect.rect, rect.strokeWidth.toInt());
  }

  @override
  Future<bool> addImage(PrintImage printImage) {
    checkConnected();

    checkConnected();

    final algo = printImage.monochromizationAlgorithm ??
        MonochromizationAlgorithm.binary;
    final ImageMode printImageMode =
    ImageMode.fromMonochromizationAlgorithm(algo);

    final imageParams = HaninTSPLImageParams(
      imagePath: printImage.path,
      xPosition: printImage.xPosition.toInt(),
      yPosition: printImage.yPosition.toInt(),
      imageMode: printImageMode,
    );

    return addImageParams(imageParams);
  }
}