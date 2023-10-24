import 'package:flutter_label_printer/exception/invalid_argument_exception.dart';
import 'package:flutter_label_printer/exception/invalid_connection_state_exception.dart';
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
import 'package:flutter_label_printer/templating/templatable_printer_interface.dart';

/// Interface for Templating for the Hanin (HPRT) HM-A300L Printer.
class HaninCPCLPrinterTemplate extends HaninCPCLPrinter
    implements TemplatablePrinterInterface {
  HaninCPCLPrinterTemplate(super.device);

  @override
  Future<bool> setPrintAreaSize(PrintAreaSize printAreaSize) async {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

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

  Rotation90 getHMA300LRotation(double angle) {
    final roundedRotation = (angle / 90).round() * 90 % 360;
    switch (roundedRotation) {
      case 0:
        return Rotation90.text;
      // ignore: no-magic-number, well-formed angles.
      case 90:
        return Rotation90.text90;
      // ignore: no-magic-number, well-formed angles.
      case 180:
        return Rotation90.text180;
      // ignore: no-magic-number, well-formed angles.
      case 270:
        return Rotation90.text270;
      default:
        return Rotation90.text;
    }
  }

  HaninCPCLOrientation getHMA300LPrintOrientation(double angle) {
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
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    final style = printText.style;

    bool sizeResult;
    bool boldResult;
    bool alignResult;
    if (style != null) {
      sizeResult = await setTextSize(
        style.width?.toInt() ?? 1,
        style.height?.toInt() ?? 1,
      );
      boldResult = await setBold(style.bold?.toInt() ?? 0);

      HaninCPCLTextAlign hmA300lAlign;
      switch (style.align) {
        case PrintTextAlign.left:
          hmA300lAlign = HaninCPCLTextAlign.left;
          break;
        case PrintTextAlign.center:
          hmA300lAlign = HaninCPCLTextAlign.center;
          break;
        case PrintTextAlign.right:
          hmA300lAlign = HaninCPCLTextAlign.right;
          break;
        default:
          hmA300lAlign = HaninCPCLTextAlign.left;
      }
      alignResult = await setAlign(hmA300lAlign);
    } else {
      sizeResult = true;
      boldResult = true;
      alignResult = true;
    }

    final textParams = HaninCPCLTextParams(
      xPosition: printText.xPosition.toInt(),
      yPosition: printText.yPosition.toInt(),
      text: printText.text,
      rotate: getHMA300LRotation(printText.rotation),
    );
    final textResult = await addTextParams(textParams);

    if (style != null) {
      sizeResult = sizeResult && await setTextSize(1, 1);
      boldResult = boldResult && await setBold(0);
      alignResult = alignResult && await setAlign(HaninCPCLTextAlign.left);
    }

    return sizeResult && boldResult && alignResult && textResult;
  }

  @override
  Future<bool> addBarcode(PrintBarcode barcode) {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

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
          'Barcode format ${barcode.type} is unsupported on the HM-A300L.',
        );
    }

    final barcodeParams = HaninCPCLBarcodeParams(
      orientation: getHMA300LPrintOrientation(barcode.rotation),
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
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    final qrCodeParams = HaninCPCLQRCodeParams(
      orientation: getHMA300LPrintOrientation(qrCode.rotation),
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
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    return addLineParam(rect.rect, rect.strokeWidth.toInt());
  }

  @override
  Future<bool> addRectangle(PrintRect rect) {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    return addRectangleParam(rect.rect, rect.strokeWidth.toInt());
  }

  @override
  Future<bool> addImage(PrintImage printImage) {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    final ImageMode printImageMode;
    switch (printImage.monochromizationAlgorithm) {
      case MonochromizationAlgorithm.binary:
        printImageMode = ImageMode.binary;
        break;
      case MonochromizationAlgorithm.dithering:
        printImageMode = ImageMode.dithering;
        break;
      case MonochromizationAlgorithm.cluster:
        printImageMode = ImageMode.cluster;
        break;
      default:
        throw UnsupportedError(
          'Monochromization Algorithm ${printImage.monochromizationAlgorithm} is unsupported on the HM-A300L.',
        );
    }

    final imageParams = HaninCPCLPrintImageParams(
      imagePath: printImage.path,
      xPosition: printImage.xPosition.toInt(),
      yPosition: printImage.yPosition.toInt(),
      mode: printImageMode,
    );

    return addImageParams(imageParams);
  }
}
