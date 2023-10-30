import 'package:flutter_label_printer/exception/invalid_argument_exception.dart';
import 'package:flutter_label_printer/printer/common_classes.dart';
import 'package:flutter_label_printer/printer/hanin_cpcl_classes.dart';
import 'package:flutter_label_printer/printer/hanin_cpcl_printer.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_area_size.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_barcode.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_image.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_qr_code.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_rect.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_text.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_text_align.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_text_font.dart';
import 'package:flutter_label_printer/templating/templatable_printer_interface.dart';

/// Interface for Templating for the Hanin (HPRT) HM-A300L Printer.
class HaninCPCLPrinterTemplate extends HaninCPCLPrinter
    implements TemplatablePrinterInterface {
  HaninCPCLPrinterTemplate(super.device);

  @override
  Future<bool> setPrintAreaSize(PrintAreaSize printAreaSize) async {
    checkConnected();

    final height = printAreaSize.height;
    if (height == null) {
      throw InvalidArgumentException(
        'Height must not be null',
        StackTrace.current.toString(),
      );
    }

    final HaninCPCLPaperType paperType;
    switch (printAreaSize.paperType) {
      case PrintPaperType.continuous:
        paperType = HaninCPCLPaperType.continuous;
        break;
      case PrintPaperType.label:
        paperType = HaninCPCLPaperType.label;
        break;
      default:
        paperType = HaninCPCLPaperType.continuous;
        break;
    }

    final typeResult = await setPaperType(paperType);

    final HaninCPCLPrintAreaSizeParams params = HaninCPCLPrintAreaSizeParams(
      offset: printAreaSize.originX?.toInt() ?? 0,
      height: height.toInt(),
    );

    final sizeResult = await setPrintAreaSizeParams(params);

    return typeResult && sizeResult;
  }

  HaninCPCLOrientation _getOrientation(double angle) {
    final roundedRotation = (angle / 90).round() * 90 % 180;
    switch (roundedRotation) {
      case 0:
        return HaninCPCLOrientation.horizontal;
      // ignore: no-magic-number, well-formed angles.
      case 90:
        return HaninCPCLOrientation.vertical;
      default:
        return HaninCPCLOrientation.horizontal;
    }
  }

  @override
  Future<bool> addText(PrintText printText) async {
    checkConnected();

    final style = printText.style;

    bool sizeResult = true;
    bool boldResult = true;
    bool alignResult = true;
    if (style != null) {
      sizeResult = await setTextSize(
        style.width?.toInt() ?? 1,
        style.height?.toInt() ?? 1,
      );
      boldResult = await setBold(style.bold?.toInt() ?? 0);

      HaninCPCLTextAlign align;
      switch (style.align) {
        case PrintTextAlign.left:
          align = HaninCPCLTextAlign.left;
          break;
        case PrintTextAlign.center:
          align = HaninCPCLTextAlign.center;
          break;
        case PrintTextAlign.right:
          align = HaninCPCLTextAlign.right;
          break;
        default:
          align = HaninCPCLTextAlign.left;
      }
      alignResult = await setAlign(align);
    }

    final HaninCPCLFont font;
    switch (printText.style?.font) {
      case PrintTextFont.small:
        font = HaninCPCLFont.font2;
        break;
      case PrintTextFont.medium:
        font = HaninCPCLFont.font0;
        break;
      case PrintTextFont.large:
        font = HaninCPCLFont.font28;
        break;
      case PrintTextFont.vlarge:
        font = HaninCPCLFont.font4;
        break;
      case PrintTextFont.vvlarge:
        font = HaninCPCLFont.font4;
        break;
      case PrintTextFont.chinese:
        font = HaninCPCLFont.font1;
        break;
      case PrintTextFont.chineseLarge:
        font = HaninCPCLFont.font28;
        break;
      case PrintTextFont.ocrSmall:
        font = HaninCPCLFont.font0;
        break;
      case PrintTextFont.ocrLarge:
        font = HaninCPCLFont.font4;
        break;
      case PrintTextFont.square:
        font = HaninCPCLFont.font3;
        break;
      case PrintTextFont.triumvirate:
        font = HaninCPCLFont.font0;
        break;
      case null:
        font = HaninCPCLFont.font0;
        break;
    }

    final textParams = HaninCPCLTextParams(
      xPosition: printText.xPosition.toInt(),
      yPosition: printText.yPosition.toInt(),
      text: printText.text,
      font: font,
      rotate: Rotation90.fromAngle(printText.rotation),
    );
    final textResult = await addTextParams(textParams);

    if (style != null) {
      // Reset style.
      sizeResult = sizeResult && await setTextSize(1, 1);
      boldResult = boldResult && await setBold(0);
      alignResult = alignResult && await setAlign(HaninCPCLTextAlign.left);
    }

    return sizeResult && boldResult && alignResult && textResult;
  }

  @override
  Future<bool> addBarcode(PrintBarcode barcode) {
    checkConnected();

    final HaninCPCLBarcodeType barcodeType;
    switch (barcode.type) {
      case PrintBarcodeType.upca:
        barcodeType = HaninCPCLBarcodeType.upca;
        break;
      case PrintBarcodeType.upce:
        barcodeType = HaninCPCLBarcodeType.upce;
        break;
      case PrintBarcodeType.ean13:
        barcodeType = HaninCPCLBarcodeType.ean13;
        break;
      case PrintBarcodeType.ean8:
        barcodeType = HaninCPCLBarcodeType.ean8;
        break;
      case PrintBarcodeType.code39:
        barcodeType = HaninCPCLBarcodeType.code39;
        break;
      case PrintBarcodeType.code93:
        barcodeType = HaninCPCLBarcodeType.code93;
        break;
      case PrintBarcodeType.code128:
        barcodeType = HaninCPCLBarcodeType.code128;
        break;
      case PrintBarcodeType.codabar:
        barcodeType = HaninCPCLBarcodeType.codabar;
        break;
      default:
        throw UnsupportedError(
          'Barcode format ${barcode.type} is unsupported on Hanin CPCL',
        );
    }

    final barcodeParams = HaninCPCLBarcodeParams(
      orientation: _getOrientation(barcode.rotation),
      type: barcodeType,
      ratio: HaninCPCLBarcodeRatio.ratio0,
      barWidthUnit: barcode.barLineWidth.toInt(),
      height: barcode.height.toInt(),
      xPosition: barcode.xPosition.toInt(),
      yPosition: barcode.yPosition.toInt(),
      data: barcode.data,
    );

    return addBarcodeParams(barcodeParams);
  }

  @override
  Future<bool> addQRCode(PrintQRCode qrCode) {
    checkConnected();

    final qrCodeParams = HaninCPCLQRCodeParams(
      orientation: _getOrientation(qrCode.rotation),
      xPosition: qrCode.xPosition.toInt(),
      yPosition: qrCode.yPosition.toInt(),
      model: HaninCPCLQRCodeModel.normal,
      unitSize: qrCode.unitSize.toInt(),
      data: qrCode.data,
    );

    return addQRCodeParams(qrCodeParams);
  }

  @override
  Future<bool> addLine(PrintRect rect) {
    checkConnected();

    return addLineParam(rect.rect, rect.strokeWidth.toInt());
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

    final imageParams = HaninCPCLImageParams(
      imagePath: printImage.path,
      xPosition: printImage.xPosition.toInt(),
      yPosition: printImage.yPosition.toInt(),
      mode: printImageMode,
    );

    return addImageParams(imageParams);
  }
}
