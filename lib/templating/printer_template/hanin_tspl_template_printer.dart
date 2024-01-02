import 'dart:io';

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
import 'package:flutter_label_printer/templating/printer_hints/text_align_hint.dart';
import 'package:flutter_label_printer/templating/printer_template/image_template_printer.dart';
import 'package:flutter_label_printer/templating/templatable_printer_interface.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Interface for Templating for the Hanin Printers using TSPL.
class HaninTSPLTemplatePrinter extends HaninTSPLPrinter
    implements TemplatablePrinterInterface {
  HaninTSPLTemplatePrinter(super.device);

  static const String _tempImagePrefix =
      '_flutter_label_printer_temp_image_file_9U1ZR38S3F3KJ6XE';
  Directory? _tempTempDir;
  int _currentTempFileIndex = 0;

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
  Future<bool> addText(
    PrintText printText,
    TextAlignHint? textAlignHint,
  ) async {
    checkConnected();

    if (printText.useImage) {
      final image = await ImageTemplatePrinter.getTextImage(
        printText,
      );

      // store the image into a temp file
      final tempDir = await getTemporaryDirectory();
      final tempTempDir = await tempDir.createTemp(_tempImagePrefix);
      final path = '${tempTempDir.path}/img$_currentTempFileIndex.png';
      await img.encodePngFile(path, image);
      _tempTempDir = tempTempDir;
      _currentTempFileIndex++;

      final imageParams = HaninTSPLImageParams(
        imagePath: path,
        xPosition: printText.xPosition.toInt(),
        yPosition: printText.yPosition.toInt(),
      );

      return addImageParams(imageParams);
    } else {
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
        default:
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
        default:
          align = HaninTSPLTextAlign.left;
          break;
      }

      if (printText.width > 0) {
        var xPosition = printText.xPosition.toInt();
        var usedAlign = align;
        if (textAlignHint != null && textAlignHint.enabled) {
          if (align == HaninTSPLTextAlign.center) {
            xPosition = (xPosition +
                    printText.width / 2 -
                    printText.text.length *
                        textAlignHint.charWidth *
                        (printText.style?.width ?? 1) /
                        2)
                .toInt();
          } else if (align == HaninTSPLTextAlign.right) {
            xPosition = (xPosition +
                    printText.width -
                    printText.text.length *
                        textAlignHint.charWidth *
                        (printText.style?.width ?? 1))
                .toInt();
          }
          usedAlign = HaninTSPLTextAlign.left;
        }

        final params = HaninTSPLTextBlockParams(
          xPosition: xPosition,
          yPosition: printText.yPosition.toInt(),
          text: printText.text,
          width: printText.width.toInt(),
          height: printText.height.toInt(),
          rotate: Rotation90.fromAngle(printText.rotation),
          alignment: usedAlign,
          charWidth: printText.style?.width?.toInt() ?? 1,
          charHeight: printText.style?.height?.toInt() ?? 1,
          bold: printText.style?.bold?.toInt() ?? 0,
          lineSpacing: printText.style?.lineSpacing.toInt() ?? 0,
        );

        return addTextBlockParams(params);
      } else {
        final params = HaninTSPLTextParams(
          xPosition: printText.xPosition.toInt(),
          yPosition: printText.yPosition.toInt(),
          text: printText.text,
          font: font,
          rotate: Rotation90.fromAngle(printText.rotation),
          alignment: align,
          charWidth: printText.style?.width?.toInt() ?? 1,
          charHeight: printText.style?.height?.toInt() ?? 1,
          bold: printText.style?.bold?.toInt() ?? 0,
        );

        return addTextParams(params);
      }
    }
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
      barLineWidth: barcode.barLineWidth.toInt(),
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

  @override
  Future<bool> print() async {
    final result = await super.print();

    await _tempTempDir?.delete(recursive: true);

    return result;
  }
}
